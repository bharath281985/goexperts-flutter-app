import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/enums.dart';
import '../utils/result.dart';

/// Fetches a single entity of type [T] (API-ready via a repository fetcher).
typedef DetailFetcher<T> = Future<Result<T>> Function();

/// Immutable state for a single-entity detail screen.
class DetailState<T> extends Equatable {
  const DetailState({this.status = ViewStatus.loading, this.item, this.errorMessage});

  final ViewStatus status;
  final T? item;
  final String? errorMessage;

  DetailState<T> copyWith({ViewStatus? status, T? item, String? errorMessage}) => DetailState<T>(
        status: status ?? this.status,
        item: item ?? this.item,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, item, errorMessage];
}

/// Generic cubit powering every standalone detail page with a consistent
/// loading → success / empty / failure lifecycle.
class DetailCubit<T> extends Cubit<DetailState<T>> {
  DetailCubit(this.fetcher) : super(DetailState<T>());

  final DetailFetcher<T> fetcher;

  Future<void> load() async {
    emit(DetailState<T>(status: ViewStatus.loading));
    final result = await fetcher();
    result.fold(
      (failure) => emit(DetailState<T>(status: ViewStatus.failure, errorMessage: failure.message)),
      (value) => value == null
          ? emit(DetailState<T>(status: ViewStatus.empty))
          : emit(DetailState<T>(status: ViewStatus.success, item: value)),
    );
  }
}
