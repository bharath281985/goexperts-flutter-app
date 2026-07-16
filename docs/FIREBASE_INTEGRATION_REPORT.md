# Firebase Integration Report — Phase 22

**Date:** 2026-07-07  
**Project:** `goexperts_portal_app`  
**Firebase project:** `goexperts-a979c`

## Status: Implemented (with bundle ID blocker)

### Flutter packages added

| Package | Purpose |
|---------|---------|
| `firebase_core` | App initialization |
| `firebase_messaging` | FCM token + push |
| `firebase_analytics` | App open events |
| `flutter_local_notifications` | Foreground notification display |

### Initialization

- `lib/main.dart` — `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` before `runApp`
- Background handler registered via `FirebaseMessaging.onBackgroundMessage`
- `lib/firebase_options.dart` — platform options (Android/iOS/macOS/web)

### Push service

- `FirebasePushNotificationService` replaces stub in production DI
- Permission request on init
- FCM token get + refresh
- Foreground → local notification + snackbar
- Background handler registered
- Killed-state tap → `getInitialMessage` → `NotificationRouter`

### Android

- `google-services.json` present at `android/app/google-services.json`
- Google Services Gradle plugin applied
- `POST_NOTIFICATIONS` permission added

### iOS / macOS

- `GoogleService-Info.plist` present under `ios/Runner/` and `macos/Runner/` (if copied)
- Push entitlements **not yet applied in Xcode** — see `SPM_MIGRATION_REPORT.md`

## Critical blocker: Bundle / package ID mismatch

| Platform | App bundle ID | Firebase config ID |
|----------|---------------|-------------------|
| Android | `com.goexperts.portal.goexperts_app` | `com.doorstephub.goexperts` |
| iOS | `com.goexperts.portal.goexpertsApp` | `com.doorstephub.goexperts` |

**Impact:** FCM token generation, Google Sign-In, and Firebase Auth token verification may fail until Firebase Console apps are registered for the actual bundle IDs (or app IDs are changed to match Firebase).

**Fix:** In [Firebase Console](https://console.firebase.google.com/project/goexperts-a979c), add Android + iOS apps with matching bundle IDs and download updated config files.

## Backend

- Social login uses Firebase Admin `verifyIdToken` — requires `FIREBASE_SERVICE_ACCOUNT_KEY` in server `.env`
- Device tokens saved via `POST /app/device-token`

## Files changed

- `lib/main.dart`, `lib/firebase_options.dart`
- `lib/core/notifications/firebase_push_notification_service.dart`
- `lib/core/notifications/device_token_registration_service.dart`
- `android/app/build.gradle.kts`, `android/settings.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
