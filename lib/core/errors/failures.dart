import 'package:equatable/equatable.dart';

/// Base failure returned by repositories to the domain/presentation layers.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.code, this.errorCode});

  final String message;
  final int? code;
  final String? errorCode;

  @override
  List<Object?> get props => [message, code, errorCode];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.errorCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.errorCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested item was not found.']);
}
