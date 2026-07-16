# Deployment Steps — GoExperts Flutter App

## Prerequisites

- Flutter SDK (stable channel, SDK ^3.12.0)
- Android Studio + SDK (for APK/AAB)
- Xcode (for iOS, macOS only)
- Chrome (for web testing)

## Configuration

1. Open `lib/app/config/app_config.dart`
2. Confirm base URL:
   ```
   https://apiai.goexperts.in/api/v1/mobile
   ```
3. Set `useMockData = false` for production
4. Set `AppFlavor` to `prod` in `main.dart` if flavor switching is added

## Android — Debug APK (verified)

```bash
cd goexperts_portal_app
flutter pub get
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

Install:
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## Android — Release APK / AAB

> Requires signing configuration in `android/app/build.gradle` and `key.properties`

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

Outputs:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## Web (verified)

```bash
flutter build web --release
```

Output: `build/web/` — deploy to any static host (Nginx, Firebase Hosting, S3, etc.)

### Nginx example

```nginx
server {
  listen 80;
  root /var/www/goexperts-web;
  index index.html;
  location / {
    try_files $uri $uri/ /index.html;
  }
}
```

## iOS

```bash
flutter build ios --release --no-codesign
```

Open `ios/Runner.xcworkspace` in Xcode for signing and App Store upload.

> Note: iOS build not executed in Phase 18 CI — code compiles; verify on Mac with Xcode.

## Environment Variables (optional future)

| Variable | Purpose |
|----------|---------|
| `API_BASE_URL` | Override base URL per environment |
| `SOCKET_URL` | Realtime chat endpoint |
| `USE_MOCK_DATA` | Enable mock mode |

Currently configured in `AppConfig` constants.

## Post-Deploy Checklist

- [ ] Login works on production API
- [ ] Token refresh works after 401
- [ ] Client can view and action proposals
- [ ] Push notifications (FCM token sent on login)
- [ ] Deep links / GoRouter routes resolve
- [ ] Web CORS allows `apiai.goexperts.in`

## Rollback

Set `AppConfig.useMockData = true` and redeploy to restore offline demo behavior without API dependency.
