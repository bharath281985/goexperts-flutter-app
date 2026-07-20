import 'package:dio/dio.dart';

import '../errors/failures.dart';
import '../utils/result.dart';
import 'api_exception_handler.dart';
import 'api_response.dart';
import 'dio_client.dart';

/// Shared HTTP helpers used by remote datasources.
class ApiClientHelper {
  ApiClientHelper(this._dioClient);

  final DioClient _dioClient;

  Dio get _dio => _dioClient.raw;

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
      );
      final envelope = ApiResponse.parse(response.data ?? {}, parser);
      ApiExceptionHandler.ensureSuccess(envelope);
      if (envelope.data == null) {
        return const Err(NotFoundFailure('No data returned.'));
      }
      return Success(envelope.data as T);
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }

  Future<Result<T>> getEnvelope<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(ApiResponse<dynamic> envelope) parser,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
      );
      final envelope = ApiResponse.parse(response.data ?? {}, null);
      ApiExceptionHandler.ensureSuccess(envelope);
      return Success(parser(envelope));
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }

  Future<Result<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(dynamic data) parser,
    bool allowNullData = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final envelope = ApiResponse.parse(response.data ?? {}, parser);
      ApiExceptionHandler.ensureSuccess(envelope);
      if (envelope.data == null && !allowNullData) {
        return const Err(NotFoundFailure('No data returned.'));
      }
      return Success(envelope.data as T);
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }

  Future<Result<T>> postEnvelope<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(ApiResponse<dynamic> envelope) parser,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final envelope = ApiResponse.parse(response.data ?? {}, null);
      ApiExceptionHandler.ensureSuccess(envelope);
      return Success(parser(envelope));
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }

  Future<Result<T>> postEnvelopeAcceptingHttpSuccess<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(ApiResponse<dynamic> envelope) parser,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final responseBody = response.data ?? {};
      final envelope = ApiResponse.parse(responseBody, null);
      if (responseBody.containsKey('success')) {
        ApiExceptionHandler.ensureSuccess(envelope);
      }
      return Success(parser(envelope));
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }

  Future<Result<bool>> postAction(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final envelope = ApiResponse.parse(response.data ?? {}, null);
      ApiExceptionHandler.ensureSuccess(envelope);
      return const Success(true);
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }

  Future<Result<bool>> patchAction(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(path, data: body);
      final envelope = ApiResponse.parse(response.data ?? {}, null);
      ApiExceptionHandler.ensureSuccess(envelope);
      return const Success(true);
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }

  Future<Result<T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(path, data: body);
      final envelope = ApiResponse.parse(response.data ?? {}, parser);
      ApiExceptionHandler.ensureSuccess(envelope);
      if (envelope.data == null) {
        return const Err(NotFoundFailure('No data returned.'));
      }
      return Success(envelope.data as T);
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }

  Future<Result<T>> putEnvelope<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(ApiResponse<dynamic> envelope) parser,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(path, data: body);
      final envelope = ApiResponse.parse(response.data ?? {}, null);
      ApiExceptionHandler.ensureSuccess(envelope);
      return Success(parser(envelope));
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }

  Future<Result<T>> uploadBytesEnvelope<T>(
    String path, {
    required List<int> bytes,
    required String filename,
    String fileField = 'file',
    Map<String, dynamic>? fields,
    required T Function(ApiResponse<dynamic> envelope) parser,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?fields,
        fileField: MultipartFile.fromBytes(bytes, filename: filename),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final envelope = ApiResponse.parse(response.data ?? {}, null);
      ApiExceptionHandler.ensureSuccess(envelope);
      return Success(parser(envelope));
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }

  Future<Result<bool>> deleteAction(String path) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(path);
      final envelope = ApiResponse.parse(response.data ?? {}, null);
      ApiExceptionHandler.ensureSuccess(envelope);
      return const Success(true);
    } catch (e) {
      return Err(ApiExceptionHandler.mapException(e));
    }
  }
}
