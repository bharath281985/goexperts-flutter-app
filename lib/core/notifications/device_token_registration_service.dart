import '../network/api_client_helper.dart';
import '../network/api_endpoints.dart';
import '../utils/device_info_helper.dart';
import 'push_notification_service.dart';

export 'firebase_push_notification_service.dart';

/// Registers FCM token with backend after login/register/refresh.
class DeviceTokenRegistrationService {
  DeviceTokenRegistrationService(
    this._api,
    this._deviceInfo,
    this._push,
  );

  final ApiClientHelper _api;
  final DeviceInfoHelper _deviceInfo;
  final PushNotificationService _push;

  Future<void> registerIfPossible() async {
    final token = await _push.getToken();
    if (token == null || token.isEmpty) return;

    final device = await _deviceInfo.devicePayload();
    await _api.postAction(
      ApiEndpoints.appDeviceToken,
      body: {
        'fcmToken': token,
        ...device,
      },
    );
  }

  void listenForTokenRefresh() {
    _push.setOnTokenRefresh((_) => registerIfPossible());
  }
}
