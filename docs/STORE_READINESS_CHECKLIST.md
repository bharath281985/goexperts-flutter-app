# Store Readiness Checklist — Phase 20

**App:** Go Experts Portal (`goexperts_app`)  
**Version:** 1.0.0+1  
**Package:** `com.goexperts.portal.goexperts_app`  
**Date:** 2026-07-07  
**Overall store readiness:** **52%** (internal/beta track only)

---

## Google Play Store

### App binary & signing

| Item | Status | Action |
|------|--------|--------|
| Release APK builds | ✅ Done | Use for sideload QA |
| Release AAB builds | ⚠️ Partial | AAB exists; fix symbol-strip warning |
| Production keystore | ❌ Missing | Create `upload-keystore.jks`, configure `key.properties` |
| Release signing config | ❌ Uses debug keys | Update `android/app/build.gradle.kts` |
| `versionCode` / `versionName` | ✅ 1.0.0+1 | Bump before each release |
| App bundle size | ✅ ~59 MB | Within Play limits |
| 64-bit support | ✅ Flutter default | Verify on Play pre-launch report |

### Play Console listing

| Item | Status | Action |
|------|--------|--------|
| App title & short description | ❌ | Prepare store copy |
| Full description | ❌ | Highlight freelancer/client/investor/founder |
| Screenshots (phone) | ❌ | Capture per role dashboard |
| Feature graphic (1024×500) | ❌ | Design required |
| App icon (512×512) | ⚠️ | Verify `assets/logo/` meets Play specs |
| Privacy policy URL | ❌ | Required — host on goexperts.in |
| Content rating questionnaire | ❌ | Complete in Play Console |
| Target audience & ads declaration | ❌ | Complete |
| Data safety form | ❌ | Declare auth tokens, profile, payments |
| Category | ❌ | Business / Productivity recommended |

### Technical compliance

| Item | Status | Action |
|------|--------|--------|
| `targetSdk` current | ✅ Flutter 3.44 default | Recheck before submission |
| Permissions audit | ⚠️ | Review camera, storage, internet in `AndroidManifest.xml` |
| ProGuard / R8 | ✅ Flutter default | No custom rules needed yet |
| Deep links / App Links | ⚠️ | Router exists; verify intent filters |
| Push notifications (FCM) | ⚠️ | Backend FCM key missing on server |

---

## Apple App Store (Future)

| Item | Status |
|------|--------|
| iOS project configured | ⚠️ Exists, not built in Phase 20 |
| Apple Developer account | ❌ Not verified |
| Provisioning profiles | ❌ |
| App Store Connect listing | ❌ |
| Privacy nutrition labels | ❌ |

---

## Web Deployment

| Item | Status | Action |
|------|--------|--------|
| `flutter build web` | ✅ Pass | Deploy `build/web/` |
| HTTPS hosting | ❌ | Configure on subdomain |
| CORS for API | ⚠️ | Add web origin to backend `allowedOrigins` |
| PWA manifest | ⚠️ | Basic Flutter web; enhance if needed |
| SEO / meta tags | ❌ | Update `web/index.html` |

---

## Backend / API Readiness

| Item | Status | Action |
|------|--------|--------|
| Health endpoint | ✅ 200 | |
| Auth endpoints | ✅ Reachable | |
| Role dashboards (401 protected) | ✅ | |
| `/app/feature-flags` | ❌ 404 | Deploy Phase 19-F backend routes |
| `/search` | ❌ 404 | Deploy search module routes |
| `/chat/conversations` | ❌ 404 | Deploy chat module routes |
| Database connection | ✅ Fixed (health 200) | Monitor uptime |
| SSL certificate | ✅ | |
| Rate limiting | ✅ | Document for QA testers |
| Payment gateways (Stripe/Razorpay) | ⚠️ | Keys missing on server |

---

## Security & Privacy

| Item | Status | Action |
|------|--------|--------|
| Token storage encrypted | ❌ | Migrate to `flutter_secure_storage` |
| Certificate pinning | ❌ | Optional for v1.1 |
| Obfuscation (`--obfuscate`) | ❌ | Enable for release builds |
| API keys in source | ✅ None hardcoded | |
| GDPR / data deletion | ⚠️ | `DELETE /auth/account` wired; verify E2E |
| Password policy enforced | ✅ | Client + server validation |

---

## Functional Readiness (Must pass before public release)

| Flow | Status |
|------|--------|
| Login / logout / refresh | ⚠️ QA required |
| Signup with correct role | ❌ Bug: always freelancer |
| Subscription paywall | ❌ Bug: bypassed with `'active'` fallback |
| File upload (avatar, docs) | ❌ Multipart not implemented |
| Realtime chat | ❌ Polling only |
| OTP / social login | ❌ Not available |
| Payments / wallet withdraw | ⚠️ Gateway-dependent |
| Multi-language UI | ❌ English only |
| Offline / error UX | ⚠️ Partial |

---

## QA Sign-off Checklist

- [ ] Login tested for all 4 roles on physical device
- [ ] Token refresh tested (kill access token)
- [ ] Forced logout on refresh expiry tested
- [ ] Signup role persistence verified (currently failing)
- [ ] Subscription gate verified (currently failing)
- [ ] File upload E2E verified (currently failing)
- [ ] Chat send/receive via polling verified
- [ ] Notifications mark-read verified
- [ ] Support ticket create/reply verified
- [ ] Search returns results (blocked by 404)
- [ ] Crash-free session on release APK (Firebase Crashlytics recommended)
- [ ] Play pre-launch report reviewed

---

## Release Track Recommendation

| Track | Ready? | Notes |
|-------|--------|-------|
| Internal testing | ⚠️ Yes with caveats | Debug or release APK sideload |
| Closed beta (Play) | ❌ | Fix signing + critical bugs first |
| Open beta | ❌ | Backend 404s + auth bugs |
| Production | ❌ | Not ready |

---

## Pre-submission Action Plan (Priority Order)

1. **Create production Android keystore** and configure release signing.
2. **Fix subscription gate bug** in `auth_bloc.dart`.
3. **Fix signup role** — pass selected role to register API.
4. **Implement multipart file uploads** across document/avatar repos.
5. **Migrate token storage** to `flutter_secure_storage`.
6. **Deploy backend routes** for `/app/feature-flags`, `/search`, `/chat/*`.
7. **Capture store screenshots** for each role.
8. **Publish privacy policy** URL.
9. **Complete Play Console** data safety + content rating forms.
10. **Run closed beta** with 10–20 testers before production.

---

## Estimated Timeline to Store-Ready

| Phase | Effort | Outcome |
|-------|--------|---------|
| Critical bug fixes (auth, uploads, storage) | 3–5 days | Functional beta |
| Backend route deployment | 1 day | Search/chat/flags live |
| Signing + Play listing assets | 2 days | Uploadable AAB |
| Closed beta QA | 1–2 weeks | Crash/flow validation |
| **Total to production track** | **~3 weeks** | Store submission ready |
