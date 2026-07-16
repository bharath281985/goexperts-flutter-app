# Release Build Report — Phase 20

**Date:** 2026-07-07  
**App:** `goexperts_portal_app`  
**Version:** 1.0.0+1  
**Application ID:** `com.goexperts.portal.goexperts_app`  
**Flutter:** 3.44.0 (stable)  
**Backend:** `https://mobileapi.goexperts.in/api/v1/mobile`

---

## Build Summary

| Build target | Command | Result | Artifact |
|--------------|---------|--------|----------|
| Debug APK | `flutter build apk --debug` | ✅ PASS | `build/app/outputs/flutter-apk/app-debug.apk` |
| Release APK | `flutter build apk --release` | ✅ PASS | `build/app/outputs/flutter-apk/app-release.apk` |
| Release AAB | `flutter build appbundle --release` | ⚠️ PARTIAL | `build/app/outputs/bundle/release/app-release.aab` |
| Web | `flutter build web` | ✅ PASS | `build/web/` |

---

## Artifact Paths

| Artifact | Absolute path | Size |
|----------|---------------|------|
| **Debug APK** | `/Volumes/Samsung 1TB/All Projects/GoExperts Flutter Master/goexperts_portal_app/build/app/outputs/flutter-apk/app-debug.apk` | 177 MB |
| **Release APK** | `/Volumes/Samsung 1TB/All Projects/GoExperts Flutter Master/goexperts_portal_app/build/app/outputs/flutter-apk/app-release.apk` | 61 MB |
| **Release AAB** | `/Volumes/Samsung 1TB/All Projects/GoExperts Flutter Master/goexperts_portal_app/build/app/outputs/bundle/release/app-release.aab` | 59 MB |
| **Web build** | `/Volumes/Samsung 1TB/All Projects/GoExperts Flutter Master/goexperts_portal_app/build/web/` | 45 MB |

### Relative paths (from project root)

```
build/app/outputs/flutter-apk/app-debug.apk
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
build/web/index.html
```

---

## Pre-build Checks

| Check | Result |
|-------|--------|
| `flutter pub get` | ✅ |
| `flutter analyze` | ✅ 0 errors, 59 warnings |
| `flutter test` | ✅ 2/2 pass |

---

## Android Configuration

| Setting | Value |
|---------|-------|
| `compileSdk` | 36 |
| `minSdk` | flutter default |
| `targetSdk` | flutter default |
| `namespace` | `com.goexperts.portal.goexperts_app` |
| `applicationId` | `com.goexperts.portal.goexperts_app` |
| Release signing | ⚠️ **Debug keys** (`signingConfig = debug`) |

> **Store blocker:** Release APK/AAB are signed with debug keys. Generate a production keystore before Play Store upload.

---

## AAB Warning

```
Release app bundle failed to strip debug symbols from native libraries.
```

- The `.aab` file **was produced** despite the exit-code warning.
- Upload to Play Console internal testing track to verify acceptance.
- Run `flutter doctor` and ensure Android NDK/toolchain is complete if the warning persists.
- Consider `flutter build appbundle --release --no-tree-shake-icons` only if icon issues arise (not required now).

---

## Web Build Notes

- Tree-shaking reduced Material/Cupertino icon fonts by ~98%.
- Wasm dry-run succeeded; `--wasm` flag available for future builds.
- Deploy `build/web/` to any static host (Firebase Hosting, Netlify, cPanel, etc.).
- Ensure CORS on `mobileapi.goexperts.in` allows the web origin.

---

## Runtime Configuration (All Flavors)

```dart
baseUrlDev / baseUrlStaging / baseUrlProd
  → https://mobileapi.goexperts.in/api/v1/mobile

useMockData = false
realtimeProvider = socketIo
socketUrl = https://mobileapi.goexperts.in
```

All three flavors point to the same production API URL.

---

## Install Commands

### Debug APK (internal QA)

```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (sideload testing)

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Web (local preview)

```bash
cd build/web && python3 -m http.server 8080
# Open http://localhost:8080
```

---

## Build Pipeline Readiness

| Item | Status |
|------|--------|
| Debug builds | ✅ Ready |
| Release APK | ✅ Ready (debug-signed) |
| Release AAB | ⚠️ Produced with symbol-strip warning |
| Web builds | ✅ Ready |
| Production signing | ❌ Not configured |
| CI/CD automation | ❌ Not set up |
| iOS build | ❌ Not in scope (no macOS signing) |

**Build pipeline readiness: 78%**
