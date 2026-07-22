import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../errors/failures.dart';
import '../utils/enums.dart';
import '../utils/paginated.dart';
import '../utils/result.dart';

/// A reusable, generic listing BLoC that every list screen builds upon.
///
/// It provides search, advanced filters, sorting, pagination, refresh and the
/// full loading/success/empty/failure lifecycle out of the box — so concrete
/// feature blocs (ProjectListBloc, StartupListBloc, …) are tiny wrappers.
typedef ListFetcher<T> =
    Future<Result<Paginated<T>>> Function(QueryParams params);

// ----- Events -----
sealed class ListEvent extends Equatable {
  const ListEvent();
  @override
  List<Object?> get props => [];
}

class ListStarted extends ListEvent {
  const ListStarted();
}

class ListRefreshed extends ListEvent {
  const ListRefreshed();
}

class ListLoadMore extends ListEvent {
  const ListLoadMore();
}

class ListSearchChanged extends ListEvent {
  const ListSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class ListFiltersChanged extends ListEvent {
  const ListFiltersChanged({this.filters, this.sortBy, this.ascending});
  final Map<String, dynamic>? filters;
  final String? sortBy;
  final bool? ascending;
  @override
  List<Object?> get props => [filters, sortBy, ascending];
}

class ListItemUpdated extends ListEvent {
  const ListItemUpdated(this.item, this.matcher);
  final dynamic item;
  final bool Function(dynamic existing, dynamic updated) matcher;
  @override
  List<Object?> get props => [item];
}

// ----- State -----
class ListState<T> extends Equatable {
  const ListState({
    this.status = ViewStatus.initial,
    this.items = const [],
    this.query = const QueryParams(),
    this.hasMore = false,
    this.totalItems = 0,
    this.errorMessage,
  });

  final ViewStatus status;
  final List<T> items;
  final QueryParams query;
  final bool hasMore;
  final int totalItems;
  final String? errorMessage;

  int get activeFilterCount =>
      query.filters.values.fold<int>(0, (sum, v) {
        if (v is Iterable) return sum + v.length;
        return v == null ? sum : sum + 1;
      }) +
      (query.sortBy != null ? 1 : 0);

  ListState<T> copyWith({
    ViewStatus? status,
    List<T>? items,
    QueryParams? query,
    bool? hasMore,
    int? totalItems,
    String? errorMessage,
  }) {
    return ListState<T>(
      status: status ?? this.status,
      items: items ?? this.items,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      totalItems: totalItems ?? this.totalItems,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    query,
    hasMore,
    totalItems,
    errorMessage,
  ];
}

// ----- Bloc -----
class ListBloc<T> extends Bloc<ListEvent, ListState<T>> {
  ListBloc({required this.fetcher, QueryParams? initialQuery})
    : super(ListState<T>(query: initialQuery ?? const QueryParams())) {
    on<ListStarted>(_onStarted);
    on<ListRefreshed>(_onRefreshed);
    on<ListLoadMore>(_onLoadMore);
    on<ListSearchChanged>(_onSearchChanged);
    on<ListFiltersChanged>(_onFiltersChanged);
    on<ListItemUpdated>((event, emit) {
      if (event.item is! T) return;
      final updatedList = state.items
          .map((e) => event.matcher(e, event.item) ? event.item as T : e)
          .toList();
      emit(state.copyWith(items: updatedList));
    });
  }

  final ListFetcher<T> fetcher;

  Future<void> _load(
    Emitter<ListState<T>> emit, {
    required QueryParams query,
    required ViewStatus loadingStatus,
    bool append = false,
  }) async {
    emit(state.copyWith(status: loadingStatus, query: query));
    final result = await fetcher(query);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ViewStatus.failure,
          errorMessage: _messageFor(failure),
        ),
      ),
      (page) {
        final items = append ? [...state.items, ...page.items] : page.items;
        emit(
          state.copyWith(
            status: items.isEmpty ? ViewStatus.empty : ViewStatus.success,
            items: items,
            hasMore: page.hasMore,
            totalItems: page.totalItems,
            query: query,
          ),
        );
      },
    );
  }

  Future<void> _onStarted(ListStarted event, Emitter<ListState<T>> emit) {
    return _load(
      emit,
      query: state.query.copyWith(page: 1),
      loadingStatus: ViewStatus.loading,
    );
  }

  Future<void> _onRefreshed(ListRefreshed event, Emitter<ListState<T>> emit) {
    return _load(
      emit,
      query: state.query.copyWith(page: 1),
      loadingStatus: ViewStatus.refreshing,
    );
  }

  Future<void> _onLoadMore(ListLoadMore event, Emitter<ListState<T>> emit) {
    if (!state.hasMore || state.status == ViewStatus.loadingMore)
      return Future.value();
    return _load(
      emit,
      query: state.query.copyWith(page: state.query.page + 1),
      loadingStatus: ViewStatus.loadingMore,
      append: true,
    );
  }

  Future<void> _onSearchChanged(
    ListSearchChanged event,
    Emitter<ListState<T>> emit,
  ) {
    return _load(
      emit,
      query: state.query.copyWith(search: event.query, page: 1),
      loadingStatus: ViewStatus.loading,
    );
  }

  Future<void> _onFiltersChanged(
    ListFiltersChanged event,
    Emitter<ListState<T>> emit,
  ) {
    return _load(
      emit,
      query: state.query.copyWith(
        filters: event.filters,
        sortBy: event.sortBy,
        ascending: event.ascending,
        page: 1,
      ),
      loadingStatus: ViewStatus.loading,
    );
  }

  String _messageFor(Failure failure) => failure.message;
}
