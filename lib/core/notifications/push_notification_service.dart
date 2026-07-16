import 'dart:async';

import 'package:flutter/foundation.dart';

/// Push notification abstraction.
abstract class PushNotificationService {
  Future<void> initialize();
  Future<String?> getToken();
  void setOnMessageOpenedHandler(void Function(Map<String, dynamic> data) handler);
  void setOnForegroundMessage(void Function(Map<String, dynamic> data) handler);
  void setOnTokenRefresh(void Function(String token) handler) {}
}

/// Safe stub used until Firebase project files are configured.
class StubPushNotificationService implements PushNotificationService {
  @override
  Future<void> initialize() async {
    debugPrint('[Push] Stub service initialized — add Firebase config for production push.');
  }

  @override
  Future<String?> getToken() async => null;

  @override
  void setOnMessageOpenedHandler(void Function(Map<String, dynamic> data) handler) {}

  @override
  void setOnForegroundMessage(void Function(Map<String, dynamic> data) handler) {}

  @override
  void setOnTokenRefresh(void Function(String token) handler) {}
}
