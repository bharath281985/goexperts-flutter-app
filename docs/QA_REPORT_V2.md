# QA Report V2 — Phase 21

**Date:** 2026-07-07  
**Backend:** `https://mobileapi.goexperts.in/api/v1/mobile`

---

## Automated Checks

| Check | Result |
|-------|--------|
| `flutter analyze` | ✅ 0 errors |
| `flutter test` | ✅ 2/2 pass |
| `flutter build apk --release` | ✅ PASS |
| `flutter build appbundle --release` | ✅ AAB produced |

---

## Blocker Fix Verification

| # | Blocker | Code verified | Manual E2E |
|---|---------|---------------|------------|
| 1 | Role signup | ✅ Draft → role → register | ⏳ Device test |
| 2 | Subscription gate | ✅ No `?? 'active'` | ⏳ Device test |
| 3 | Secure storage | ✅ flutter_secure_storage | ⏳ Device test |
| 4 | Multipart upload | ✅ FileUploadHelper | ⏳ Device test |
| 5 | Android release | ✅ Gradle config | ⏳ Keystore gen |
| 6 | Offline | ✅ ConnectivityCubit | ⏳ Airplane mode |
| 7 | API errors | ✅ Global interceptor | ⏳ Device test |
| 8 | Push | ⚠️ Stub service | ⏳ Firebase setup |
| 9 | App update | ✅ AppUpdateService | ⏳ Version API test |
| 10 | Full QA | — | ⏳ Per-role smoke |

---

## Per-Role Flow Matrix

### Auth (all roles)

| Flow | Wiring | Expected |
|------|--------|----------|
| Login | ✅ | Token saved encrypted |
| Signup draft | ✅ | Navigates to role selection |
| Register with role | ✅ | `role` in POST body |
| Logout | ✅ | Secure storage cleared |
| Token refresh | ✅ | 401 → refresh → retry |
| Session expiry | ✅ | Forced logout |

### Freelancer

| Flow | Status |
|------|--------|
| Dashboard | ✅ API wired |
| Profile + avatar/resume/certificate upload | ✅ Multipart |
| Tasks + attachments | ✅ Multipart |
| Wallet / subscriptions | ✅ Role-prefixed API |
| Documents | ✅ Multipart |
| Messages (polling) | ✅ REST + 10s poll |
| Notifications | ✅ Wired |

### Client

| Flow | Status |
|------|--------|
| Dashboard | ✅ API wired |
| Company profile + logo/docs | ✅ Multipart |
| Projects / proposals | ✅ Wired |
| Payments | ✅ Gateway-dependent |
| Subscriptions | ✅ `/client/subscriptions/current` |

### Investor

| Flow | Status |
|------|--------|
| Dashboard | ✅ API wired |
| Profile + documents | ✅ Multipart |
| Startups / deals | ✅ Wired |
| Subscriptions | ✅ `/investor/subscriptions/current` |

### Founder

| Flow | Status |
|------|--------|
| Dashboard | ✅ API wired |
| Startup / funding | ✅ Wired |
| Documents upload | ✅ Multipart |
| Subscriptions | ✅ `/founder/subscriptions/current` |

### Shared Modules

| Module | Status |
|--------|--------|
| Notifications | ✅ Protected endpoints |
| Chat | ⚠️ Polling only; `/chat/*` 404 on server |
| Files | ✅ Multipart to `/files/upload` |
| Wallet / invoices | ✅ Role-prefixed |
| Support tickets | ✅ Wired |
| Search / discovery | ⚠️ Code ready; server 404 |
| App config / version | ✅ `/app/config` 200 |

---

## Manual QA Checklist

### Auth
- [ ] Signup as **client** → verify server role is `client` (not freelancer)
- [ ] Login → kill access token → silent refresh works
- [ ] Expire refresh token → forced logout

### Subscription
- [ ] User with no subscription → blocked at subscription screen
- [ ] User with active subscription → dashboard loads
- [ ] Expired subscription → renewal screen shown
- [ ] Skip button removed — cannot bypass

### Uploads
- [ ] Upload avatar (freelancer) — server receives file bytes
- [ ] Upload company document (client)
- [ ] Upload pitch deck (founder)

### Offline
- [ ] Enable airplane mode → offline banner appears
- [ ] Tap Retry → reconnects when network returns

### Errors
- [ ] 422 validation → friendly snackbar
- [ ] 429 rate limit → friendly message
- [ ] 503 → service unavailable message

### App Update
- [ ] `/app/version` returns update info → dialog shown if outdated
- [ ] Maintenance mode → blocking dialog

---

## Known Gaps (Post Phase 21)

| Item | Severity |
|------|----------|
| Production keystore not generated | High (store) |
| Firebase push not configured | Medium |
| Backend `/search`, `/chat/*` 404 | Medium |
| Socket.IO realtime chat | Low |
| OTP / social login | Low |
| i18n UI strings | Low |

---

## Verdict

**Flutter app:** Beta-ready with all Phase 21 code blockers addressed.  
**Store release:** Pending keystore + Firebase + manual E2E sign-off.
