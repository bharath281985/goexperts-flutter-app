import 'dart:async';

/// Broadcasts API errors for global UI handling (snackbars, dialogs).
class GlobalErrorBus {
  GlobalErrorBus._();
  static final GlobalErrorBus instance = GlobalErrorBus._();

  final _controller = StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  void emit(String message) {
    if (message.isEmpty) return;
    _controller.add(message);
  }

  void dispose() => _controller.close();
}
