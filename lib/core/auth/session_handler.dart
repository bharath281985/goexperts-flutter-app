/// Called when refresh token fails — triggers logout in [AuthBloc].
class SessionHandler {
  void Function(String message)? onSessionExpired;
  Future<void> Function()? onTokenRefreshed;

  Future<void> notifyExpired([
    String message = 'Session expired. Please login again.',
  ]) async {
    onSessionExpired?.call(message);
  }

  Future<void> notifyTokenRefreshed() async {
    final cb = onTokenRefreshed;
    if (cb != null) await cb();
  }
}
