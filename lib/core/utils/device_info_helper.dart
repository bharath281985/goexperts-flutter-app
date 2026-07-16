import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import '../notifications/push_notification_service.dart';
import '../storage/local_storage.dart';

/// Collects device metadata for auth and FCM registration payloads.
class DeviceInfoHelper {
  DeviceInfoHelper(this._storage, [this._push]);

  final LocalStorage _storage;
  final PushNotificationService? _push;

  static const _deviceIdKey = 'device_id';

  Future<Map<String, dynamic>> authPayload() async {
    final device = await devicePayload();
    return {
      ...device,
      'fcmToken': device['fcmToken'] ?? '',
    };
  }

  Future<Map<String, dynamic>> devicePayload() async {
    var deviceId = _storage.getString(_deviceIdKey);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = 'dev_${DateTime.now().millisecondsSinceEpoch}';
      await _storage.setString(_deviceIdKey, deviceId);
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final fcmToken = await _push?.getToken();

    return {
      'deviceId': deviceId,
      'deviceName': _deviceName(),
      'platform': _platform(),
      if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken,
      'appVersion': packageInfo.version,
    };
  }

  String _platform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'web';
  }

  String _deviceName() {
    final platform = _platform();
    return '${platform[0].toUpperCase()}${platform.substring(1)} Device';
  }
}
