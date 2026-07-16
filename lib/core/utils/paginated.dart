import 'package:equatable/equatable.dart';

/// Query parameters every listing screen sends to repositories.
/// Keeps search / filters / sort / pagination consistent + API-ready.
class QueryParams extends Equatable {
  const QueryParams({
    this.page = 1,
    this.pageSize = 15,
    this.search,
    this.sortBy,
    this.ascending = false,
    this.filters = const {},
  });

  final int page;
  final int pageSize;
  final String? search;
  final String? sortBy;
  final bool ascending;
  final Map<String, dynamic> filters;

  QueryParams copyWith({
    int? page,
    int? pageSize,
    String? search,
    String? sortBy,
    bool? ascending,
    Map<String, dynamic>? filters,
  }) {
    return QueryParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      filters: filters ?? this.filters,
    );
  }

  Map<String, dynamic> toQuery() => {
        'page': page,
        'page_size': pageSize,
        if (search != null && search!.isNotEmpty) 'q': search,
        if (sortBy != null) 'sort_by': sortBy,
        'order': ascending ? 'asc' : 'desc',
        ...filters,
      };

  /// Query map aligned with backend (`page`, `limit`, `search`).
  Map<String, dynamic> toApiQuery() {
    final query = <String, dynamic>{
      'page': page,
      'limit': pageSize,
      if (search != null && search!.isNotEmpty) 'q': search,
      if (search != null && search!.isNotEmpty) 'search': search,
      if (sortBy != null && sortBy!.isNotEmpty) 'sort': sortBy,
      if (sortBy != null && sortBy!.isNotEmpty) 'sort_by': sortBy,
      'order': ascending ? 'asc' : 'desc',
    };

    for (final entry in filters.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is Iterable) {
        final parts = value
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList();
        if (parts.isEmpty) continue;
        query[entry.key] = parts.join(',');
      } else {
        final text = value.toString().trim();
        if (text.isEmpty) continue;
        query[entry.key] = text;
      }
    }
    return query;
  }


  @override
  List<Object?> get props => [page, pageSize, search, sortBy, ascending, filters];
}

/// A page of results with metadata for infinite scroll / pagination.
class Paginated<T> extends Equatable {
  const Paginated({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
  });

  final List<T> items;
  final int page;
  final int totalPages;
  final int totalItems;

  bool get hasMore => page < totalPages;

  Paginated<T> copyWithMore(List<T> more) => Paginated(
        items: [...items, ...more],
        page: page,
        totalPages: totalPages,
        totalItems: totalItems,
      );

  @override
  List<Object?> get props => [items, page, totalPages, totalItems];
}
