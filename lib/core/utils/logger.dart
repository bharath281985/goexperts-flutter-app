import 'dart:developer' as developer;

/// Minimal logger wrapper. Swap the sink for Crashlytics/Sentry later.
class AppLogger {
  AppLogger._();

  static void d(Object? message) => developer.log('$message', name: 'GoExperts');

  static void e(Object? message, [Object? error, StackTrace? stack]) {
    developer.log('$message', name: 'GoExperts', error: error, stackTrace: stack);
  }
}
