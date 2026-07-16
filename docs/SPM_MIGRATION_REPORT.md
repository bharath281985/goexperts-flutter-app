# iOS / macOS SPM Migration Report — Phase 22

**Date:** 2026-07-07

## Summary

**Partial migration.** Firebase Flutter plugins use CocoaPods via Flutter tooling. Full SPM-only iOS/macOS builds are **not** possible yet without plugin updates.

## GoogleService-Info.plist

| Location | Present | Bundle ID in file | App bundle ID |
|----------|---------|-------------------|---------------|
| `ios/Runner/GoogleService-Info.plist` | ✅ | `com.doorstephub.goexperts` | `com.goexperts.portal.goexpertsApp` |
| `macos/Runner/GoogleService-Info.plist` | ⚠️ Verify on disk | — | — |

**Action:** Re-download plist from Firebase after registering `com.goexperts.portal.goexpertsApp` (and macOS bundle if different). Confirm **Target Membership → Runner** in Xcode.

## Push Notifications capability

| Item | iOS | macOS |
|------|-----|-------|
| Push Notifications entitlement | ❌ Not in repo — enable in Xcode | ❌ |
| Background Modes → Remote notifications | ❌ Not in Info.plist | ❌ |
| `aps-environment` entitlement file | ❌ Missing `Runner.entitlements` | ❌ |

**Manual steps (Xcode):**

1. Open `ios/Runner.xcworkspace`
2. Runner target → Signing & Capabilities → **+ Push Notifications**
3. **+ Background Modes** → check **Remote notifications**
4. Upload APNs key to Firebase Console → Cloud Messaging

## CocoaPods vs SPM

Flutter `pub get` reported plugins **without** SPM support:

- `sign_in_with_apple`
- `flutter_secure_storage`
- `flutter_local_notifications`
- Firebase-related pods (via `firebase_core`, `firebase_messaging`, etc.)

**Conclusion:** Keep **CocoaPods** (`ios/Podfile`, `macos/Podfile`). Run `pod install` after `flutter pub get` for native builds.

## Bundle ID

- Xcode: `com.goexperts.portal.goexpertsApp` (iOS)
- Firebase plist: `com.doorstephub.goexperts` — **must be aligned**

## Recommendation

1. Fix Firebase app registration for production bundle IDs
2. Add push entitlements in Xcode (cannot be fully automated without project.pbxproj edits)
3. Revisit SPM when Flutter Firebase + auth plugins declare SPM support
