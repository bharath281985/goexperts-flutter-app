# Known Issues — Phase 20

**App:** `goexperts_portal_app`  
**Backend:** `https://mobileapi.goexperts.in/api/v1/mobile`  
**Last updated:** 2026-07-07

Issues confirmed by code review, automated builds, and live API probes during Phase 20 QA.

---

## Blocking (Must fix before store release)

### B1. Subscription gate bypass

- **Symptom:** Users without a subscription plan skip the subscription onboarding screen.
- **Cause:** `subscriptionPlanId: user.subscriptionPlan ?? 'active'` treats null plan as subscribed.
- **File:** `lib/features/auth/presentation/bloc/auth_bloc.dart` (lines 34, 51, 83)
- **Workaround:** None — paywall is ineffective.
- **Fix:** Use `user.subscriptionPlan` only; redirect to subscription when null/empty.

### B2. Signup always registers as freelancer

- **Symptom:** User selects client/investor/founder in UI but API creates freelancer account.
- **Cause:** `register()` hardcodes `role: UserRole.freelancer`.
- **File:** `lib/features/auth/data/repositories/auth_repository_impl.dart` (line 71)
- **Workaround:** Manually change role in database.
- **Fix:** Pass selected role from signup/onboarding flow to register API.

### B3. Role selection not persisted to backend

- **Symptom:** After signup, role picker updates local state only.
- **Cause:** `selectRole()` calls `user.copyWith(role:)` with no API call.
- **File:** `lib/features/auth/data/repositories/auth_repository_impl.dart`
- **Fix:** Add `PUT /auth/me` or dedicated role-update endpoint call.

### B4. File uploads send JSON path, not file bytes

- **Symptom:** Avatar, document, pitch deck uploads fail against real API.
- **Cause:** Repositories POST `{ "filePath": "..." }` — no `MultipartFile` / `FormData`.
- **Files:** `document_repository_impl.dart`, live upload pages across roles.
- **Fix:** Implement multipart upload per `FILE_UPLOAD_GUIDE.md` on backend.

### B5. Tokens stored in SharedPreferences

- **Symptom:** Access/refresh tokens not hardware-backed or encrypted.
- **Cause:** `SecureStorage` class wraps `SharedPreferences`.
- **File:** `lib/core/storage/secure_storage.dart`
- **Fix:** Migrate to `flutter_secure_storage` package.

### B6. Release builds signed with debug keys

- **Symptom:** Cannot upload to Play Store production track.
- **File:** `android/app/build.gradle.kts` — `signingConfig = debug` in release.
- **Fix:** Create upload keystore and configure `key.properties`.

### B7. Backend routes return 404 (live server)

| Endpoint | Status | Impact |
|----------|--------|--------|
| `GET /app/feature-flags` | 404 | Feature flags bootstrap fails |
| `GET /search` | 404 | Global search broken |
| `GET /chat/conversations` | 404 | Chat list broken |

- **Fix:** Deploy Phase 19-F backend changes (`app.routes.ts`, search/discovery routes) and restart Passenger.

---

## High Priority (Beta blockers)

### H1. No realtime chat (Socket.IO)

- **Symptom:** Messages only update via 10-second polling.
- **Cause:** `RealtimeProvider.socketIo` configured but no socket client implemented.
- **Files:** `lib/features/messages/`, `app_config.dart`
- **Impact:** Delayed messages, no typing indicators.

### H2. OTP and social login unavailable

- **Symptom:** UI buttons exist; API returns errors or stubs.
- **Backend:** `POST /auth/send-otp` returns `EMAIL_AUTH_ONLY` error.
- **Impact:** Phone OTP and Google/Apple login non-functional.

### H3. Token persist race on login/signup

- **Symptom:** Rare navigation before tokens saved.
- **Cause:** `fold(..., (data) async { await _persistTokens })` — async callback not awaited.
- **File:** `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- **Fix:** Await token persistence before returning success.

### H4. Investor subscription flow has no API

- **Symptom:** Investor onboarding may stall at subscription step.
- **Cause:** No `/investor/subscriptions` endpoints; router still requires subscription.
- **Impact:** Investor onboarding broken end-to-end.

### H5. AAB debug-symbol strip warning

- **Symptom:** `flutter build appbundle --release` exits with error despite producing `.aab`.
- **Impact:** May affect Play Console validation; verify on internal track.
- **Fix:** Run `flutter doctor`, ensure NDK installed.

---

## Medium Priority

### M1. Settings API always uses freelancer path

- **File:** `lib/features/settings/data/repositories/settings_repository_impl.dart`
- **Impact:** Client/investor/founder settings may read/write wrong data.

### M2. Support ticket reply sends hardcoded message

- **File:** `lib/features/support/presentation/pages/support_page.dart` (line ~86)
- **Impact:** User replies not sent as typed.

### M3. Hardcoded chat tab badge

- **File:** `lib/app/shell/role_shell.dart` — `badgeCount: 3`
- **Impact:** Misleading unread count.

### M4. Document list masks API errors with stale cache

- **File:** `lib/features/documents/data/repositories/document_repository_impl.dart`
- **Impact:** User sees outdated files after network failure.

### M5. Global search chips don't navigate to results

- **File:** `lib/features/search/presentation/pages/global_search_page.dart`
- **Impact:** Search UX incomplete.

### M6. All app flavors use same production URL

- **File:** `lib/app/config/app_config.dart`
- **Impact:** No dev/staging isolation.

### M7. Locale picker doesn't change UI language

- **Files:** `lib/app/app.dart`, `lib/features/settings/`
- **Impact:** Language setting saved but UI stays English.

### M8. Payment gateway keys missing on server

- **Backend env:** `STRIPE_SECRET_KEY`, Razorpay/Easebuzz not configured.
- **Impact:** Subscription upgrade and payments fail at gateway step.

---

## Low Priority / Polish

### L1. 59 analyzer warnings

- Mostly `unnecessary_non_null_assertion` in repository `fold` callbacks.
- No compile impact.

### L2. Minimal test coverage

- Only 2 formatter unit tests in `test/widget_test.dart`.
- No integration or widget tests for auth/roles.

### L3. `getCompanies()` mock fallback

- Client companies list may show mock data in edge cases.

### L4. Dashboard cubit silent error swallow

- Some dashboards don't surface API errors to user.

### L5. Contact support buttons are snack placeholders

- Email/phone/chat shortcuts not wired.

---

## Backend Gaps (Flutter UI expects, server missing)

See `docs/BACKEND_GAPS_FOR_FLUTTER.md` for full list. Key items:

| Feature | Status |
|---------|--------|
| OTP / phone verification | Stub / disabled |
| Social login (`POST /auth/social`) | Missing |
| Block user endpoints | Missing |
| Freelancer proposal withdraw | Mock only |
| Investor deals alias | Mapped to investments |

---

## Issue Count Summary

| Severity | Count |
|----------|-------|
| Blocking | 7 |
| High | 5 |
| Medium | 8 |
| Low | 5 |
| **Total** | **25** |

---

## Tracking

| ID | Owner | Target |
|----|-------|--------|
| B1–B5 | Flutter | Pre-beta |
| B6 | DevOps / Android | Pre-Play upload |
| B7 | Backend | Immediate |
| H1–H4 | Flutter + Backend | Beta v1.1 |
| M1–M8 | Flutter | Beta polish |
| L1–L5 | Flutter | Post-launch |
