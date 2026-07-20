import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../errors/failures.dart';
import '../utils/result.dart';
import 'api_exception_handler.dart';
import 'api_response.dart';
import 'dio_client.dart';

/// Multipart uploads with progress, retry, and large-file support.
class FileUploadHelper {
  FileUploadHelper(this._dioClient);

  final DioClient _dioClient;

  static const int maxRetries = 2;
  static const Duration retryDelay = Duration(seconds: 2);

  Future<Result<Map<String, dynamic>>> upload({
    required String path,
    required String endpoint,
    String fileField = 'file',
    String method = 'post',
    Map<String, dynamic>? fields,
    void Function(int sent, int total)? onProgress,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return const Err(ValidationFailure('File not found on device.'));
    }

    DioException? lastError;
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(retryDelay);
      }
      try {
        final formData = FormData.fromMap({
          ...?fields,
          fileField: await MultipartFile.fromFile(
            path,
            filename: p.basename(path),
          ),
        });

        final usePut = method.toLowerCase() == 'put';
        final response = usePut
            ? await _dioClient.raw.put<Map<String, dynamic>>(
                endpoint,
                data: formData,
                options: Options(
                  contentType: 'multipart/form-data',
                  sendTimeout: const Duration(minutes: 5),
                  receiveTimeout: const Duration(minutes: 5),
                ),
                onSendProgress: onProgress,
              )
            : await _dioClient.raw.post<Map<String, dynamic>>(
                endpoint,
                data: formData,
                options: Options(
                  contentType: 'multipart/form-data',
                  sendTimeout: const Duration(minutes: 5),
                  receiveTimeout: const Duration(minutes: 5),
                ),
                onSendProgress: onProgress,
              );

        final envelope = ApiResponse.parse(
          response.data ?? {},
          (data) => Map<String, dynamic>.from(data as Map),
        );
        ApiExceptionHandler.ensureSuccess(envelope);
        final data = envelope.data;
        if (data is Map<String, dynamic>) {
          return Success(data);
        }
        return Success(<String, dynamic>{'url': envelope.message});
      } on DioException catch (e) {
        lastError = e;
        final retryable =
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError ||
            (e.response?.statusCode ?? 0) >= 500;
        if (!retryable || attempt == maxRetries) break;
      } catch (e) {
        return Err(ApiExceptionHandler.mapException(e));
      }
    }
    return Err(ApiExceptionHandler.mapException(lastError!));
  }

  Future<Result<String>> uploadUrl({
    required String path,
    required String endpoint,
    String fileField = 'file',
    String method = 'post',
    Map<String, dynamic>? fields,
    void Function(int sent, int total)? onProgress,
  }) async {
    final res = await upload(
      path: path,
      endpoint: endpoint,
      fileField: fileField,
      method: method,
      fields: fields,
      onProgress: onProgress,
    );
    return res.fold(
      Err.new,
      (json) => Success(
        json['url']?.toString() ??
            json['fileUrl']?.toString() ??
            json['avatarUrl']?.toString() ??
            json['logoUrl']?.toString() ??
            '',
      ),
    );
  }
}
