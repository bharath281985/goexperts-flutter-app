# Android Release Guide — Phase 21

**App ID:** `com.goexperts.portal.goexperts_app`  
**Package:** `goexperts_app` v1.0.0+1

---

## 1. Generate Production Keystore

Run from project root (one-time, keep credentials safe):

```bash
keytool -genkey -v \
  -keystore android/app/goexperts-release.keystore \
  -alias goexperts \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass YOUR_STORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD \
  -dname "CN=GoExperts, OU=Mobile, O=GoExperts, L=Hyderabad, ST=Telangana, C=IN"
```

> **Never commit** the keystore or passwords to git.

---

## 2. Create `android/key.properties`

Copy the example and fill in values:

```bash
cp android/key.properties.example android/key.properties
```

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=goexperts
storeFile=goexperts-release.keystore
```

`storeFile` is relative to `android/app/`.

---

## 3. Build Commands

```bash
cd goexperts_portal_app

flutter pub get
flutter analyze
flutter test

# Release APK (sideload / QA)
flutter build apk --release

# Release AAB (Play Store)
flutter build appbundle --release
```

---

## 4. Output Paths

| Artifact | Path |
|----------|------|
| Release APK | `build/app/outputs/flutter-apk/app-release.apk` |
| Release AAB | `build/app/outputs/bundle/release/app-release.aab` |

---

## 5. Signing Behavior

`android/app/build.gradle.kts` automatically:

- Uses **release keystore** when `android/app/goexperts-release.keystore` exists
- Falls back to **debug signing** if keystore is missing (local dev only)

---

## 6. Play Console Upload

1. Open [Google Play Console](https://play.google.com/console)
2. Create app → Production / Internal testing
3. Upload `app-release.aab`
4. Complete store listing, content rating, data safety form
5. Add privacy policy URL

---

## 7. AAB Symbol-Strip Warning

If you see:

```
Release app bundle failed to strip debug symbols from native libraries.
```

The AAB may still be produced. Verify upload in Play Console internal track. Run `flutter doctor` and ensure Android NDK is installed.

---

## 8. `.gitignore` Recommendations

Add to `.gitignore`:

```
android/key.properties
android/app/goexperts-release.keystore
android/app/*.keystore
```

---

## 9. CI/CD (Optional)

```yaml
# Example GitHub Actions secrets needed:
# KEYSTORE_BASE64, KEYSTORE_PASSWORD, KEY_PASSWORD, KEY_ALIAS

- run: echo "$KEYSTORE_BASE64" | base64 -d > android/app/goexperts-release.keystore
- run: |
    cat > android/key.properties <<EOF
    storePassword=${{ secrets.KEYSTORE_PASSWORD }}
    keyPassword=${{ secrets.KEY_PASSWORD }}
    keyAlias=${{ secrets.KEY_ALIAS }}
    storeFile=goexperts-release.keystore
    EOF
- run: flutter build appbundle --release
```

---

## 10. Verify Signing

```bash
# Check APK signature
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk

# Or using jarsigner
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

Release builds signed with debug keys will show `CN=Android Debug` — replace with production keystore before store upload.
