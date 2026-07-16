import '../errors/failures.dart';

/// Lightweight functional result type used across repositories and usecases,
/// avoiding a heavier dependency while keeping call sites explicit.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Err<T>;

  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;
  Failure? get failureOrNull => this is Err<T> ? (this as Err<T>).failure : null;

  R fold<R>(R Function(Failure failure) onFailure, R Function(T value) onSuccess) {
    final self = this;
    if (self is Success<T>) return onSuccess(self.value);
    return onFailure((self as Err<T>).failure);
  }
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
