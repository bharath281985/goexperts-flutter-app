# Final QA Report — Phase 20

**Date:** 2026-07-07  
**App:** `goexperts_portal_app`  
**Package:** `goexperts_app` v1.0.0+1  
**Backend:** `https://mobileapi.goexperts.in/api/v1/mobile`  
**Flavor:** `dev` (`useMockData = false`)

---

## Executive Summary

| Metric | Value |
|--------|-------|
| **Overall app readiness** | **71%** |
| **Flutter compile health** | ✅ Pass (0 errors, 59 style warnings) |
| **Automated tests** | ✅ 2/2 pass |
| **Live backend health** | ✅ `/health` 200 |
| **Production recommendation** | **Beta / internal QA only** — not store-ready until blockers resolved |

The unified Flutter app compiles, builds, and is wired to live APIs across all four roles and shared modules. Critical auth, subscription-gate, file-upload, and backend route gaps block a public store release.

---

## Automated Checks

| Command | Result | Notes |
|---------|--------|-------|
| `flutter pub get` | ✅ PASS | 13 packages have newer constrained versions |
| `flutter analyze` | ✅ PASS | 0 errors, 59 warnings (mostly `unnecessary_non_null_assertion`) |
| `flutter test` | ✅ PASS | 2 tests (formatters) |
| `flutter build apk --debug` | ✅ PASS | 177 MB |
| `flutter build apk --release` | ✅ PASS | 64.5 MB |
| `flutter build appbundle --release` | ⚠️ PARTIAL | AAB produced; Flutter reports debug-symbol strip failure |
| `flutter build web` | ✅ PASS | 45 MB output |

**Flutter SDK:** 3.44.0 (stable)

---

## Live API Probe (Unauthenticated)

| Endpoint | HTTP | Assessment |
|----------|------|------------|
| `GET /health` | 200 | ✅ Server running |
| `GET /app/config` | 200 | ✅ Public config reachable |
| `POST /auth/login` (empty body) | 400 | ✅ Auth route reachable (validation) |
| `GET /freelancer/dashboard` | 401 | ✅ Protected |
| `GET /client/dashboard` | 401 | ✅ Protected |
| `GET /investor/dashboard` | 401 | ✅ Protected |
| `GET /founder/dashboard` | 401 | ✅ Protected |
| `GET /notifications` | 401 | ✅ Protected |
| `GET /wallet` | 401 | ✅ Protected |
| `GET /support/tickets` | 401 | ✅ Protected |
| `GET /app/feature-flags` | 404 | ❌ Route not deployed |
| `GET /search?q=test` | 404 | ❌ Route not deployed |
| `GET /chat/conversations` | 404 | ❌ Route not deployed |

---

## Flow Validation Matrix

### 1. Auth (login / register / logout / refresh) — 72%

| Flow | Code wiring | Live API | Status |
|------|-------------|----------|--------|
| Login | ✅ `auth_remote_datasource.dart` | ✅ Reachable | Ready for QA |
| Register | ✅ | ✅ Reachable | ⚠️ Always sends `role: freelancer` |
| Logout | ✅ | ✅ | Ready |
| Refresh token | ✅ `_RefreshInterceptor` in `dio_client.dart` | ✅ | Ready for QA |
| Forgot password | ✅ | ✅ | Ready |
| OTP / phone | UI exists | ❌ Backend disabled | Blocked |
| Social login | UI exists | ❌ No API | Blocked |
| Role selection | Local only | ❌ Not persisted to API | Blocked |

**Key files:** `lib/features/auth/`, `lib/core/network/dio_client.dart`, `lib/core/auth/session_handler.dart`

---

### 2. Freelancer flows — 82%

| Area | Status |
|------|--------|
| Dashboard, profile, tasks, proposals | ✅ API-wired |
| Wallet, subscriptions, documents | ✅ Wired (upload transport issue) |
| Certificates, portfolio, settings | ✅ Wired |
| Protected endpoints | ✅ 401 without token |

**Key files:** `lib/features/freelancer_dashboard/`, `lib/app/router/app_router.dart`

---

### 3. Client flows — 78%

| Area | Status |
|------|--------|
| Dashboard, projects, proposals | ✅ API-wired |
| Company profile, contracts, tasks | ✅ Wired |
| Payments initiate/verify | ✅ Wired (gateway-dependent) |
| Team / companies list | ⚠️ Partial mock fallback |

**Key files:** `lib/features/client_dashboard/`, `lib/features/projects/`, `lib/features/proposals/`

---

### 4. Investor flows — 75%

| Area | Status |
|------|--------|
| Dashboard, profile, startups | ✅ API-wired |
| Deals (mapped to investments) | ✅ Wired |
| Documents, reports, analytics | ✅ Wired |
| Subscription onboarding | ❌ No investor subscription API |

**Key files:** `lib/features/investor_dashboard/`, `lib/features/startup_ideas/`

---

### 5. Founder flows — 80%

| Area | Status |
|------|--------|
| Dashboard, startup profile | ✅ API-wired |
| Funding, investor requests | ✅ Wired |
| Pitch deck, business plan, team | ✅ Wired |
| Meetings, messages | ✅ Role-aware endpoints |

**Key files:** `lib/features/founder_dashboard/`, `lib/features/startup_ideas/`

---

### 6. Shared — Notifications — 70%

| Check | Status |
|-------|--------|
| List / unread count | ✅ Wired |
| Mark read / read-all | ✅ Wired |
| Role-prefixed vs global paths | ⚠️ Mixed by role |

**Key files:** `lib/features/notifications/`

---

### 7. Shared — Chat fallback — 65%

| Check | Status |
|-------|--------|
| REST conversations/messages | ✅ Wired |
| Socket.IO realtime | ❌ Not implemented |
| Polling fallback (10s) | ✅ Active |
| Live `/chat/conversations` | ❌ 404 on server |

**Key files:** `lib/features/messages/`, `lib/features/messages/presentation/cubit/chat_cubit.dart`

---

### 8. Shared — Files / documents — 60%

| Check | Status |
|-------|--------|
| List / preview / download / delete | ✅ Wired |
| Upload | ⚠️ Sends JSON `filePath` — no `MultipartFile` |
| Stale cache on list failure | ⚠️ Masks errors |

**Key files:** `lib/features/documents/`

---

### 9. Shared — Wallet / invoices / subscriptions — 70%

| Check | Status |
|-------|--------|
| Role-prefixed wallet | ✅ Wired |
| Invoices | ✅ Wired |
| Subscriptions (freelancer/client/founder) | ✅ Wired |
| Investor subscriptions | ❌ No API paths |
| Withdrawals | ⚠️ Returns error / snack |
| Subscription gate bypass bug | ❌ Critical |

**Key files:** `lib/features/wallet/`, `lib/features/subscriptions/`

---

### 10. Shared — Support tickets — 70%

| Check | Status |
|-------|--------|
| List / create | ✅ Wired |
| Reply | ⚠️ Hardcoded message string |
| Contact buttons | ⚠️ Snack placeholders |

**Key files:** `lib/features/support/`

---

### 11. Shared — Search / discovery — 65%

| Check | Status |
|-------|--------|
| Global search API wiring | ✅ Code ready |
| Discovery / recommendations | ✅ Code ready |
| Live `/search` | ❌ 404 on server |
| Search chip navigation | ⚠️ Snack only, no result pages |

**Key files:** `lib/features/search/`, `lib/features/discovery/`

---

### 12. Language setup — 25%

| Check | Status |
|-------|--------|
| `supportedLocales` (en/hi/te/ta/kn) | ✅ Declared |
| Settings language picker | ✅ Persists to API |
| `MaterialApp.router` locale binding | ❌ Not applied |
| ARB / generated l10n | ❌ Not implemented |
| UI strings | English only (`AppStrings`) |

**Key files:** `lib/app/app.dart`, `lib/features/settings/`

---

### 13. Empty / loading / error states — 80%

| Check | Status |
|-------|--------|
| `PaginatedListView` lifecycle | ✅ Consistent |
| `AppEmptyState` / `AppErrorState` / shimmer | ✅ Reusable |
| Dashboard silent error swallow | ⚠️ Some cubits |
| Ad-hoc spinners on support/search | ⚠️ Inconsistent |

**Key files:** `lib/core/widgets/`, `lib/core/bloc/list_bloc.dart`

---

### 14. Token expiry handling — 75%

| Check | Status |
|-------|--------|
| 401 → refresh → retry queue | ✅ Implemented |
| Refresh failure → logout | ✅ `SessionHandler` |
| Concurrent request handling | ✅ Queued |
| Token storage security | ⚠️ SharedPreferences (not encrypted) |

**Key files:** `lib/core/network/dio_client.dart`, `lib/core/storage/secure_storage.dart`

---

### 15. API error handling — 82%

| Check | Status |
|-------|--------|
| Envelope parsing `{success, message, data, meta}` | ✅ |
| Dio → typed failures | ✅ `api_exception_handler.dart` |
| Repository `Result<T>` pattern | ✅ |
| Global error UI layer | ⚠️ Per-screen only |

**Key files:** `lib/core/network/`, `lib/core/error/`

---

## Critical Code Bugs (Must Fix Before Store)

| # | Severity | Issue | Location |
|---|----------|-------|----------|
| 1 | Critical | Subscription gate bypass: `subscriptionPlan ?? 'active'` | `auth_bloc.dart:34,51,83` |
| 2 | Critical | Signup always registers as `freelancer` | `auth_repository_impl.dart:71` |
| 3 | High | `selectRole()` never calls backend | `auth_repository_impl.dart` |
| 4 | High | File uploads use JSON path, not multipart | Multiple repos |
| 5 | High | Tokens in SharedPreferences (misnamed SecureStorage) | `secure_storage.dart` |
| 6 | Medium | Settings always uses `/freelancer/settings` for all roles | `settings_repository_impl.dart` |
| 7 | Medium | Support reply sends hardcoded message | `support_page.dart` |
| 8 | Medium | Hardcoded chat badge count `3` | `role_shell.dart` |

---

## Readiness by Area

| Area | % |
|------|---|
| Auth | 72% |
| Freelancer | 82% |
| Client | 78% |
| Investor | 75% |
| Founder | 80% |
| Notifications | 70% |
| Chat | 65% |
| Files | 60% |
| Wallet / invoices / subs | 70% |
| Support | 70% |
| Search / discovery | 65% |
| Language | 25% |
| UI states | 80% |
| Token expiry | 75% |
| API errors | 82% |
| **Overall** | **71%** |

---

## Recommended Manual QA Pass

1. Login as each role → verify dashboard loads with real data.
2. Kill access token → confirm silent refresh works.
3. Expire refresh token → confirm forced logout to login screen.
4. New signup as client → verify server role (expected fail: stored as freelancer).
5. User with `subscriptionPlan: null` → verify subscription screen (expected bug: skipped).
6. Upload avatar / document → verify server receives bytes (expected fail).
7. Open chat → send message → confirm 10s polling receives it.
8. Change language in settings → confirm UI stays English (expected).
9. Airplane mode → verify error states on list screens.

---

## Verdict

**Beta-ready** for internal device testing with live backend. **Not production/store-ready** until subscription gate, role persistence, secure token storage, multipart uploads, and remaining backend 404 routes are resolved.
