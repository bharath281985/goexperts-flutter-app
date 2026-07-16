/// Low-level exceptions thrown by datasources, mapped to [Failure]s in repos.
class ServerException implements Exception {
  ServerException(this.message, {this.code, this.errorCode});
  final String message;
  final int? code;
  final String? errorCode;
}

class NetworkException implements Exception {
  NetworkException([this.message = 'No internet connection.']);
  final String message;
}

class CacheException implements Exception {
  CacheException([this.message = 'Cache error.']);
  final String message;
}

class AuthException implements Exception {
  AuthException(this.message, {this.code, this.errorCode});
  final String message;
  final int? code;
  final String? errorCode;
}
