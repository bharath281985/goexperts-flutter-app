import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import '../errors/failures.dart';
import 'api_response.dart';
import 'app_error_messages.dart';

/// Maps Dio and API envelope errors to domain [Failure]s.
class ApiExceptionHandler {
  ApiExceptionHandler._();

  static Failure mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return _mapResponse(error.response);
      case DioExceptionType.cancel:
        return const UnknownFailure('Request cancelled.');
      default:
        return UnknownFailure(error.message ?? 'Something went wrong.');
    }
  }

  static Failure mapException(Object error) {
    if (error is DioException) return mapDioError(error);
    if (error is ServerException) {
      return ServerFailure(error.message, code: error.code, errorCode: error.errorCode);
    }
    if (error is NetworkException) return NetworkFailure(error.message);
    if (error is AuthException) {
      return AuthFailure(error.message, code: error.code, errorCode: error.errorCode);
    }
    return UnknownFailure(error.toString());
  }

  static Failure _mapResponse(Response<dynamic>? response) {
    final status = response?.statusCode ?? 0;
    final body = response?.data;

    String? serverMessage;
    String? errorCode;

    if (body is Map<String, dynamic>) {
      serverMessage = body['message'] as String?;
      errorCode = body['code'] as String?;
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        serverMessage = errors.map((e) => e.toString()).join('\n');
      }

      if (status == 401) {
        return AuthFailure(
          serverMessage ?? 'Session expired. Please login again.',
          code: status,
          errorCode: errorCode,
        );
      }
    }
    final message = AppErrorMessages.forStatus(status, serverMessage: serverMessage);

    if (status == 403) return ServerFailure(message, code: status);
    if (status == 404) return NotFoundFailure(message);
    if (status == 409) {
      return ServerFailure(message, code: status, errorCode: errorCode);
    }
    if (status == 422) return ValidationFailure(message);
    if (status == 429) return NetworkFailure(message);
    if (status == 503) return ServerFailure(message, code: status);
    if (status >= 500) return ServerFailure(message, code: status);
    return ServerFailure(message, code: status);
  }

  static void ensureSuccess(ApiResponse<dynamic> response) {
    if (!response.success) {
      throw ServerException(
        response.message ?? 'Request failed',
        errorCode: response.code,
      );
    }
  }
}
