import 'package:dio/dio.dart';

import '../../app/config/app_config.dart';
import '../errors/failures.dart';
import '../utils/result.dart';
import 'api_exception_handler.dart';

/// Client for public catalog APIs (categories, skills, etc.).
///
/// Uses the mobile API host (`AppConfig.baseUrl`) with GET endpoints that
/// return `{ success, data, meta }`. Also accepts legacy `{ rows, total }`.
class PublicCatalogClient {
  PublicCatalogClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.baseUrl,
              connectTimeout: AppConfig.connectTimeout,
              receiveTimeout: AppConfig.receiveTimeout,
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );

  final Dio _dio;

  /// GET list from `{ success, data: [...] }` (also accepts `rows`).
  Future<Result<PublicCatalogPage<T>>> getList<T>({
    required String path,
    Map<String, dynamic>? query,
    required T Function(Map<String, dynamic> json) itemParser,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
      );
      return _parsePage(response.data ?? {}, itemParser);
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }

  /// POST list (legacy AI catalog host). Prefer [getList] for mobileapi.
  Future<Result<PublicCatalogPage<T>>> postPage<T>({
    required String path,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic> json) itemParser,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      return _parsePage(response.data ?? {}, itemParser);
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }

  Result<PublicCatalogPage<T>> _parsePage<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) itemParser,
  ) {
    if (json['success'] == false) {
      return Err(
        ServerFailure(json['message'] as String? ?? 'Request failed'),
      );
    }

    final rawList = json['data'] ?? json['rows'];
    final rows = (rawList is List ? rawList : const [])
        .whereType<Map>()
        .map((item) => itemParser(Map<String, dynamic>.from(item)))
        .toList();

    final meta = json['meta'];
    final metaTotal = meta is Map ? meta['total'] : null;
    final totalRaw = metaTotal ?? json['total'];
    final total = totalRaw is num ? totalRaw.toInt() : rows.length;

    return Success(PublicCatalogPage<T>(rows: rows, total: total));
  }
}

class PublicCatalogPage<T> {
  const PublicCatalogPage({required this.rows, required this.total});

  final List<T> rows;
  final int total;
}
