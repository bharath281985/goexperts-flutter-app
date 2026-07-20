import '../utils/paginated.dart';

/// Standard backend envelope: `{ success, message, data, meta, timestamp }`.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.meta,
    this.errors,
    this.code,
    this.timestamp,
  });

  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? meta;
  final List<dynamic>? errors;
  final String? code;
  final String? timestamp;

  static ApiResponse<T> parse<T>(
    Map<String, dynamic> json,
    T Function(dynamic raw)? dataParser,
  ) {
    final rawData = json['data'];
    T? parsed;
    if (dataParser != null && rawData != null) {
      parsed = dataParser(rawData);
    } else if (rawData is T) {
      parsed = rawData;
    }

    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: parsed,
      meta: json['meta'] as Map<String, dynamic>?,
      errors: json['errors'] as List<dynamic>?,
      code: json['code'] as String?,
      timestamp: json['timestamp'] as String?,
    );
  }

  static List<T> parseList<T>(
    dynamic raw,
    T Function(Map<String, dynamic> json) itemParser,
  ) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => itemParser(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Paginated<T> parsePaginated<T>(
    dynamic raw,
    Map<String, dynamic>? meta,
    T Function(Map<String, dynamic> json) itemParser, {
    int fallbackPage = 1,
  }) {
    final items = parseList(raw, itemParser);

    // Parse current page supporting various formats
    final page =
        meta?['page'] as int? ??
        meta?['currentPage'] as int? ??
        meta?['current_page'] as int? ??
        fallbackPage;

    // Parse page size / limit supporting various formats
    final limit =
        meta?['limit'] as int? ??
        meta?['pageSize'] as int? ??
        meta?['page_size'] as int? ??
        15;

    // Parse total pages supporting various formats
    int totalPages =
        meta?['totalPages'] as int? ??
        meta?['total_pages'] as int? ??
        meta?['lastPage'] as int? ??
        meta?['last_page'] as int? ??
        meta?['pageCount'] as int? ??
        meta?['page_count'] as int? ??
        1;

    // Parse total count supporting various formats
    final total =
        meta?['total'] as int? ??
        meta?['totalCount'] as int? ??
        meta?['total_count'] as int? ??
        meta?['totalItems'] as int? ??
        meta?['total_items'] as int? ??
        meta?['count'] as int? ??
        items.length;

    // Fallback: If totalPages is not explicitly set (or equals 1) but we fetched
    // a full page of items, there is likely a next page. Enable scroll pagination.
    if (totalPages <= page &&
        items.isNotEmpty &&
        (items.length >= limit || items.length >= 10)) {
      totalPages = page + 1;
    }

    return Paginated(
      items: items,
      page: page,
      totalPages: totalPages,
      totalItems: total,
    );
  }
}
