import '../../app/config/app_config.dart';
import 'paginated.dart';
import 'result.dart';

/// Helpers used by mock repositories to emulate a paginated, searchable,
/// filterable backend. Swapped out entirely when real datasources are wired.
class MockUtils {
  MockUtils._();

  /// Emulates a network call: applies search + filters, then paginates.
  static Future<Result<Paginated<T>>> paginate<T>(
    List<T> source,
    QueryParams params, {
    bool Function(T item, String query)? searchMatcher,
    bool Function(T item, Map<String, dynamic> filters)? filterMatcher,
    int Function(T a, T b)? sorter,
  }) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    var list = List<T>.from(source);

    final q = params.search?.trim().toLowerCase();
    if (q != null && q.isNotEmpty && searchMatcher != null) {
      list = list.where((e) => searchMatcher(e, q)).toList();
    }

    if (params.filters.isNotEmpty && filterMatcher != null) {
      list = list.where((e) => filterMatcher(e, params.filters)).toList();
    }

    if (sorter != null) {
      list.sort(sorter);
      if (params.ascending) {
        list = list.reversed.toList();
      }
    }

    final total = list.length;
    final totalPages = (total / params.pageSize).ceil().clamp(1, 9999);
    final start = (params.page - 1) * params.pageSize;
    final end = (start + params.pageSize).clamp(0, total);
    final pageItems = start >= total ? <T>[] : list.sublist(start, end);

    return Success(
      Paginated<T>(
        items: pageItems,
        page: params.page,
        totalPages: totalPages,
        totalItems: total,
      ),
    );
  }

  /// Emulates a single-item fetch.
  static Future<Result<T>> single<T>(T value) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    return Success(value);
  }

  /// Emulates a mutating call that returns success.
  static Future<Result<bool>> action() async {
    await Future<void>.delayed(AppConfig.mockLatency);
    return const Success(true);
  }
}
