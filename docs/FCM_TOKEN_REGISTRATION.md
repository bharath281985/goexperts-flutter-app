# FCM Token Registration

## Endpoint

```
POST /api/v1/mobile/app/device-token
Authorization: Bearer <accessToken>
```

## Payload

```json
{
  "fcmToken": "...",
  "deviceId": "...",
  "deviceName": "Android Device",
  "platform": "android|ios|macos|web",
  "appVersion": "1.0.0"
}
```

## When registration runs

| Trigger | Implementation |
|---------|----------------|
| Login | Device fields included in `POST /auth/login` body; additionally `DeviceTokenRegistrationService.registerIfPossible()` on `AuthStatus.authenticated` |
| Register | Device fields in `POST /auth/register` |
| App launch (valid session) | `AuthCheckRequested` → authenticated → token registration |
| FCM token refresh | `FirebaseMessaging.onTokenRefresh` → `registerIfPossible()` |

## Flutter implementation

- `DeviceInfoHelper` — collects `deviceId`, `deviceName`, `platform`, `appVersion`, `fcmToken`
- `DeviceTokenRegistrationService` — calls `ApiEndpoints.appDeviceToken`
- Wired in `lib/app/app.dart` via auth bloc stream listener + token refresh listener

## Backend

- Route: `src/modules/app-config/app-config.routes.ts`
- Push service upserts device token per user (`saveDeviceToken` in `push.service.ts`)

## Manual test

1. Login with email on a physical device (emulator may not receive FCM)
2. Confirm `POST /app/device-token` returns 200 in network logs
3. Send test push from Firebase Console or backend admin to the stored token

## Blockers

- Firebase bundle ID mismatch (see `FIREBASE_INTEGRATION_REPORT.md`)
- Server `FIREBASE_SERVICE_ACCOUNT_KEY` must be set for backend-initiated push
