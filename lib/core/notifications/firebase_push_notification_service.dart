import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'push_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class FirebasePushNotificationService implements PushNotificationService {
  FirebasePushNotificationService();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  void Function(Map<String, dynamic> data)? _onOpened;
  void Function(Map<String, dynamic> data)? _onForeground;
  void Function(String token)? _onTokenRefresh;

  @override
  Future<void> initialize() async {
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          try {
            _onOpened?.call(Map<String, dynamic>.from(jsonDecode(payload) as Map));
          } catch (_) {}
        }
      },
    );

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen((message) async {
      final data = _messageData(message);
      _onForeground?.call(data);
      await _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _onOpened?.call(_messageData(message));
    });

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _onOpened?.call(_messageData(initial));
    }

    _messaging.onTokenRefresh.listen((token) {
      _onTokenRefresh?.call(token);
    });
  }

  @override
  void setOnTokenRefresh(void Function(String token) handler) {
    _onTokenRefresh = handler;
  }

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  void setOnMessageOpenedHandler(void Function(Map<String, dynamic> data) handler) {
    _onOpened = handler;
  }

  @override
  void setOnForegroundMessage(void Function(Map<String, dynamic> data) handler) {
    _onForeground = handler;
  }

  Map<String, dynamic> _messageData(RemoteMessage message) {
    return {
      ...message.data,
      'title': message.notification?.title,
      'body': message.notification?.body,
    };
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'goexperts_default',
      'Go Experts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }
}
