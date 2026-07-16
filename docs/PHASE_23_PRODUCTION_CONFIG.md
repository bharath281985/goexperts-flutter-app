# Phase 23 — Production Configuration Report

**Date:** 2026-07-07  
**Package / Bundle ID:** `com.doorstephub.goexperts` (Android, iOS, macOS)

## 1. Firebase — ✅ Aligned

| Platform | Config file | Package / Bundle |
|----------|-------------|------------------|
| Android | `android/app/google-services.json` | `com.doorstephub.goexperts` |
| iOS | `ios/Runner/GoogleService-Info.plist` | `com.doorstephub.goexperts` |
| macOS | `macos/Runner/GoogleService-Info.plist` | `com.doorstephub.goexperts` |

- Removed Phase 22 temporary `google-services.json` client entry
- `lib/firebase_options.dart` updated with iOS API key + bundle ID from plist
- Android `applicationId` / `namespace` → `com.doorstephub.goexperts`
- `MainActivity` moved to `com.doorstephub.goexperts`

**Manual (Firebase Console):** Upload APNs Authentication Key under Project Settings → Cloud Messaging.

## 2. Apple Push — ⚠️ Partial

| Item | Status |
|------|--------|
| `Runner.entitlements` (`aps-environment: production`) | ✅ Added |
| `UIBackgroundModes` → `remote-notification` in Info.plist | ✅ Added |
| Google Sign-In URL scheme (REVERSED_CLIENT_ID) | ✅ Added |
| Push capability in Apple Developer portal | ⏳ Enable for `com.doorstephub.goexperts` |
| APNs key in Firebase Console | ⏳ Manual upload |

## 3. Backend env — ⚠️ Partially verified on live server

| Variable | Live status |
|----------|-------------|
| `EASEBUZZ_KEY/SALT/ENV` | ✅ Easebuzz `enabled: true` on `GET /payments/gateways` |
| `FIREBASE_SERVICE_ACCOUNT_KEY` | ⏳ Cannot verify from repo — set on server |
| `RAZORPAY_*`, `STRIPE_*` | ❌ Not enabled |

**Do not commit secrets.** Set on `mobileapi.goexperts.in` and restart Node/Passenger.

## 4. Backend verification (live)

| Endpoint | Result |
|----------|--------|
| `GET /api/v1/mobile/health` | ✅ 200 |
| `POST /api/v1/mobile/app/device-token` | ✅ 200 (unauthenticated — review auth middleware) |
| `GET /api/v1/mobile/payments/gateways` | ✅ Easebuzz enabled |
| `POST /api/v1/mobile/payments/initiate` | ✅ 401 without token (auth required — correct) |
| `POST /api/v1/mobile/payments/verify` | ⏳ Requires authenticated session |

## 5. connectivity_plus — ✅ Already implemented

- `pubspec.yaml`: `connectivity_plus: ^6.1.4`
- `NetworkInfoImpl` uses `Connectivity().checkConnectivity()` + stream
- `ConnectivityCubit` + `AppOfflineBanner` in `app.dart`

No UI changes in Phase 23.

## 6. Device QA — ⏳ Pending physical devices

Checklist for manual testing on Android + iOS real devices documented in `DEVICE_QA_CHECKLIST.md`.

## 7. Release builds

| Artifact | Path | Size | Signing |
|----------|------|------|---------|
| APK | `build/app/outputs/flutter-apk/app-release.apk` | 68 MB | ⚠️ **Debug** (`key.properties` missing) |
| AAB | `build/app/outputs/bundle/release/app-release.aab` | 65 MB | ⚠️ **Debug** |
| iOS | `build/ios/iphoneos/Runner.app` | 36.3 MB | `--no-codesign` |

To sign AAB for Play Store: create `android/key.properties` from `key.properties.example` + production keystore.

## 8. Store readiness: **88%**

| Area | % |
|------|---|
| Firebase / bundle alignment | 95% |
| FCM (Android ready, iOS needs APNs) | 80% |
| Payments (Easebuzz live) | 90% |
| Social login | 85% |
| Release signing | 60% |
| Device QA | 0% (not run) |
| Backend secrets (Firebase SA) | 70% |

## Remaining blockers

1. **Production Android keystore** — add `android/key.properties` + keystore file
2. **APNs key** — upload to Firebase; enable Push for App ID in Apple Developer
3. **`FIREBASE_SERVICE_ACCOUNT_KEY`** on production server (social login + server push)
4. **LinkedIn OAuth** — Flutter flow not implemented
5. **Real device QA** — not executed in this session
6. **device-token endpoint** — returns 200 without Bearer token (backend hardening recommended)
