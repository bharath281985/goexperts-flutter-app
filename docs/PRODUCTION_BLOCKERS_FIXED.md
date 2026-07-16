# Production Blockers Fixed — Phase 21

**Date:** 2026-07-07  
**App:** `goexperts_portal_app`  
**Backend:** `https://mobileapi.goexperts.in/api/v1/mobile`

---

## Summary

| Blocker | Status | Key changes |
|---------|--------|-------------|
| **1. Role-based signup** | ✅ Fixed | Signup → Role → Register API with selected `role` |
| **2. Subscription gate** | ✅ Fixed | Backend `GET /subscriptions/current` validation; removed `?? 'active'` bypass |
| **3. Secure auth storage** | ✅ Fixed | `flutter_secure_storage` replaces SharedPreferences for tokens |
| **4. Multipart uploads** | ✅ Fixed | `FileUploadHelper` with Dio `MultipartFile`, progress, retry |
| **5. Android release** | ⚠️ Partial | SigningConfig wired; keystore must be generated locally |
| **6. Offline handling** | ✅ Fixed | `connectivity_plus`, `ConnectivityCubit`, `AppOfflineBanner` |
| **7. API error handling** | ✅ Fixed | Global interceptor + `AppErrorMessages` for 401/403/404/409/422/429/500/503 |
| **8. Push notifications** | ⚠️ Partial | Service + routing scaffold; Firebase config required |
| **9. App update** | ✅ Fixed | `AppUpdateService` checks `/app/version` + maintenance mode |
| **10. QA** | ✅ Done | See `QA_REPORT_V2.md` |

---

## Blocker 1 — Role-based Signup

**Flow:** Splash → Signup → Role Selection → Register API → Profile → Subscription → Dashboard

### Changes
- `AuthSignupDraftSaved` stores form data without calling API
- `signup_page.dart` navigates to role selection after draft save
- `AuthRoleSelected` calls `POST /auth/register` with `role: freelancer|client|investor|founder`
- Router allows role selection when `pendingSignup` is set

### Files
- `lib/features/auth/presentation/bloc/auth_bloc.dart`
- `lib/features/auth/presentation/bloc/auth_event.dart`
- `lib/features/auth/presentation/bloc/auth_state.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/presentation/pages/signup_page.dart`
- `lib/app/router/app_router.dart`

---

## Blocker 2 — Subscription Gate

### Changes
- Removed `subscriptionPlanId: user.subscriptionPlan ?? 'active'`
- Added `SubscriptionGateStatus` enum: `active`, `expired`, `none`
- `SubscriptionRepository.getSubscriptionStatus(role)` calls role-specific `/subscriptions/current`
- `AuthBloc` fetches subscription status on login/check/register
- Removed subscription "Skip" button (no local bypass)
- `AuthSubscriptionRefreshed` re-validates from API after plan selection

### Files
- `lib/core/utils/subscription_status.dart`
- `lib/features/subscriptions/data/repositories/subscription_repository_impl.dart`
- `lib/features/auth/presentation/bloc/auth_bloc.dart`
- `lib/features/subscriptions/presentation/pages/subscription_selection_page.dart`

---

## Blocker 3 — Secure Authentication

### Changes
- `SecureStorage` now uses `flutter_secure_storage` (encrypted)
- Stores: `access_token`, `refresh_token`, `user_id`, `user_role`
- `logout()` clears all secure storage keys
- Token persist race fixed (await before return)

### Files
- `lib/core/storage/secure_storage.dart`
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/app/dependency_injection/service_locator.dart`

---

## Blocker 4 — Multipart Upload

### Changes
- New `FileUploadHelper` — `MultipartFile`, 5 min timeout, 2 retries, progress callback
- Updated repositories: documents, freelancer profile, company, tasks
- Updated live pages: investor, founder, client document uploads

### Files
- `lib/core/network/file_upload_helper.dart`
- `lib/features/documents/data/repositories/document_repository_impl.dart`
- `lib/features/freelancer_dashboard/data/repositories/freelancer_profile_repository_impl.dart`
- `lib/features/client_dashboard/data/repositories/company_repository_impl.dart`
- `lib/features/freelancer_dashboard/data/repositories/freelancer_task_repository_impl.dart`
- `lib/features/*/presentation/pages/*_live_pages.dart`, `client_blocker_pages.dart`

---

## Blocker 5 — Android Release

### Changes
- `android/app/build.gradle.kts` — release `signingConfigs`, conditional keystore
- `android/key.properties.example` — template for production signing
- Falls back to debug signing until keystore file exists

### Action required
Generate keystore (see `ANDROID_RELEASE_GUIDE.md`).

---

## Blocker 6 — Offline Handling

### Changes
- `NetworkInfoImpl` uses `connectivity_plus`
- `ConnectivityCubit` streams online/offline state
- `AppOfflineBanner` shown globally in `MaterialApp.builder`
- `NoInternetScreen` widget for full-screen offline state
- Connection errors emit user-friendly global snackbars

### Files
- `lib/core/network/network_info.dart`
- `lib/core/connectivity/connectivity_cubit.dart`
- `lib/core/widgets/no_internet_screen.dart`
- `lib/app/app.dart`

---

## Blocker 7 — API Error Handling

### Changes
- `_GlobalErrorInterceptor` in `dio_client.dart`
- `AppErrorMessages.forStatus()` maps HTTP codes to friendly text
- `GlobalErrorBus` broadcasts errors → global `SnackBar` in app shell
- Enhanced `ApiExceptionHandler` for 409, 429, 503

### Files
- `lib/core/network/dio_client.dart`
- `lib/core/network/app_error_messages.dart`
- `lib/core/network/global_error_bus.dart`
- `lib/core/network/api_exception_handler.dart`

---

## Blocker 8 — Push Notifications

### Changes
- `PushNotificationService` abstraction
- `StubPushNotificationService` (safe until Firebase configured)
- `NotificationRouter` for deep-link routing on tap
- Foreground snackbar handler wired in `app.dart`

### Action required
Add `google-services.json` + enable `firebase_messaging` for production push.

---

## Blocker 9 — App Update

### Changes
- `AppUpdateService` checks `/app/version` and `/app/maintenance`
- Force update dialog (non-dismissible)
- Soft update dialog (dismissible)
- Maintenance mode dialog on startup

### Files
- `lib/core/services/app_update_service.dart`
- `lib/app/app.dart`

---

## Blocker 10 — QA

See `docs/QA_REPORT_V2.md` for per-role validation matrix.

---

## Dependencies Added

```yaml
flutter_secure_storage: ^9.2.4
connectivity_plus: ^6.1.4
package_info_plus: ^8.3.0
path: ^1.9.1
```
