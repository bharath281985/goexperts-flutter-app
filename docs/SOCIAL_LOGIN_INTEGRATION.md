# Social Login Integration

## Endpoints (backend)

| Provider | Method | Path |
|----------|--------|------|
| Google | POST | `/auth/social/google` |
| Apple | POST | `/auth/social/apple` |
| LinkedIn | POST | `/auth/social/linkedin` |

Base: `https://mobileapi.goexperts.in/api/v1/mobile`

## Required payload

```json
{
  "idToken": "<google|apple>",
  "accessToken": "<linkedin only>",
  "role": "freelancer|client|investor|founder",
  "deviceId": "...",
  "deviceName": "...",
  "platform": "android|ios|macos",
  "fcmToken": "...",
  "email": "optional apple fallback",
  "fullName": "optional apple fallback"
}
```

## Flutter flow

1. User taps Google / Apple / LinkedIn on login or signup
2. **Role picker bottom sheet** (`social_role_picker_dialog.dart`) — required before API call
3. Native sign-in via `SocialAuthService` (Google Sign-In, Sign in with Apple)
4. `AuthRepositoryImpl.socialLogin()` → `AuthRemoteDatasource.socialLogin()`
5. Tokens persisted; user authenticated; FCM token registered

## Provider status

| Provider | Flutter | Backend | Notes |
|----------|---------|---------|-------|
| Google | ✅ Wired | ✅ `verifyIdToken` | Needs matching Firebase Android/iOS app + `serverClientId` |
| Apple | ✅ iOS/macOS button | ✅ `verifyIdToken` | Requires Apple capability in Xcode |
| LinkedIn | ❌ Throws (no OAuth UI) | ✅ userinfo API | Needs mobile OAuth / web redirect flow — documented in `BACKEND_GAPS_FOR_FLUTTER.md` |

## Role selection

Social login always requires role **before** API call (per product requirement). Email signup flow unchanged: draft → role page → register.

## Security

- No secrets in Flutter
- Backend verifies Google/Apple tokens with Firebase Admin
- LinkedIn validates `accessToken` against LinkedIn userinfo API

## Files

- `lib/features/auth/data/datasources/social_auth_service.dart`
- `lib/features/auth/presentation/widgets/social_login_row.dart`
- `lib/features/auth/presentation/widgets/social_role_picker_dialog.dart`
- `flutter-goexpertsapp-apis/src/modules/auth/social.controller.ts`
