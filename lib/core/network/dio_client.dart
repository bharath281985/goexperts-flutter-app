import 'package:dio/dio.dart';

import '../../app/config/app_config.dart';
import '../auth/session_handler.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';
import 'app_error_messages.dart';
import 'global_error_bus.dart';

/// Configured Dio instance with auth, token refresh, and logging interceptors.
class DioClient {
  DioClient(this._secureStorage, this._sessionHandler) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(_AuthInterceptor(_secureStorage));
    _dio.interceptors.add(
      _RefreshInterceptor(_dio, _secureStorage, _sessionHandler),
    );
    _dio.interceptors.add(_GlobalErrorInterceptor());
    _dio.interceptors.add(_LoggingInterceptor());
  }

  final SecureStorage _secureStorage;
  final SessionHandler _sessionHandler;
  late final Dio _dio;

  Dio get raw => _dio;
}

const _sessionExpiredCodes = {
  'TOKEN_EXPIRED',
  'INVALID_TOKEN',
  'REFRESH_TOKEN_EXPIRED',
  'TOKEN_REVOKED',
};

String _messageFromResponse(Response<dynamic>? response) {
  final body = response?.data;
  if (body is Map<String, dynamic>) {
    final message = body['message'] as String?;
    if (message != null && message.isNotEmpty) return message;
  }
  return 'Session expired. Please login again.';
}

String? _codeFromResponse(Response<dynamic>? response) {
  final body = response?.data;
  if (body is Map<String, dynamic>) {
    return body['code'] as String?;
  }
  return null;
}

bool _isSessionExpiredCode(String? code) =>
    code != null && _sessionExpiredCodes.contains(code);

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage);
  final SecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.accessToken;
    print(
      'DEBUG: API Hit - Request: ${options.method} ${options.path} - Token: $token',
    );
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _RefreshInterceptor extends Interceptor {
  _RefreshInterceptor(this._dio, this._storage, this._sessionHandler);

  final Dio _dio;
  final SecureStorage _storage;
  final SessionHandler _sessionHandler;
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
  _queue = [];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;
    final isAuthRoute =
        path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');

    if (status != 401 || isAuthRoute) {
      return handler.next(err);
    }

    final errorCode = _codeFromResponse(err.response);
    if (_isSessionExpiredCode(errorCode) && path.contains('/auth/refresh')) {
      await _handleExpired(_messageFromResponse(err.response));
      return handler.next(err);
    }

    if (_isRefreshing) {
      _queue.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _storage.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        await _handleExpired();
        return handler.next(err);
      }

      final refreshDio = Dio(_dio.options);
      final response = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      final newAccess = data?['accessToken'] as String?;
      final newRefresh = data?['refreshToken'] as String?;

      if (newAccess == null) {
        await _handleExpired(_messageFromResponse(response));
        return handler.next(err);
      }

      await _storage.saveAccessToken(newAccess);
      if (newRefresh != null) await _storage.saveRefreshToken(newRefresh);
      await _sessionHandler.notifyTokenRefreshed();

      final retry = await _retry(err.requestOptions, newAccess);
      handler.resolve(retry);

      for (final pending in _queue) {
        final retried = await _retry(pending.options, newAccess);
        pending.handler.resolve(retried);
      }
      _queue.clear();
    } on DioException catch (refreshErr) {
      await _handleExpired(_messageFromResponse(refreshErr.response));
      handler.next(err);
      for (final pending in _queue) {
        pending.handler.next(err);
      }
      _queue.clear();
    } catch (_) {
      await _handleExpired();
      handler.next(err);
      for (final pending in _queue) {
        pending.handler.next(err);
      }
      _queue.clear();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options, String token) {
    final headers = Map<String, dynamic>.from(options.headers);
    headers['Authorization'] = 'Bearer $token';
    return _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: headers,
        responseType: options.responseType,
        contentType: options.contentType,
      ),
    );
  }

  Future<void> _handleExpired([
    String message = 'Session expired. Please login again.',
  ]) async {
    await _storage.deleteAll();
    await _sessionHandler.notifyExpired(message);
  }
}

class _GlobalErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;
    final isAuthRoute =
        path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');

    if (status != null && !isAuthRoute) {
      String? serverMessage;
      final body = err.response?.data;
      if (body is Map<String, dynamic>) {
        serverMessage = body['message'] as String?;
      }
      final message = AppErrorMessages.forStatus(
        status,
        serverMessage: serverMessage,
      );

      final isChatRoute =
          path.contains('/chat') ||
          path.contains('/messages') ||
          path.contains('/conversations');
      final isExpectedChatError =
          isChatRoute && (status == 404 || status == 400);

      if (status != 401 && !isExpectedChatError) {
        GlobalErrorBus.instance.emit(message);
      }
    } else if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      GlobalErrorBus.instance.emit(
        AppErrorMessages.forStatus(
          null,
          serverMessage: 'No internet connection. Please try again.',
        ),
      );
    }

    handler.next(err);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print("--- Dio Request Log Start ---");
    print("URI: ${options.uri}");
    print("Method: ${options.method}");
    print("Headers: ${options.headers}");
    print("Query Parameters: ${options.queryParameters}");
    print("Request Body: ${options.data}");
    print("--- Dio Request Log End ---");
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print("--- Dio Response Log Start ---");
    print("URI: ${response.requestOptions.uri}");
    print("Status Code: ${response.statusCode}");
    print("Response Headers: ${response.headers.map}");
    print("Response Body: ${response.data}");
    print("--- Dio Response Log End ---");
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print("--- Dio Error Log Start ---");
    print("URI: ${err.requestOptions.uri}");
    print("Message: ${err.message}");
    print("Status Code: ${err.response?.statusCode}");
    print("Response Body: ${err.response?.data}");
    print("--- Dio Error Log End ---");
    handler.next(err);
  }
}
