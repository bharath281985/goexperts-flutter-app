# Social Login Fix Report — Phase 24-A

## Backend

| Endpoint | Status |
|----------|--------|
| `POST /auth/social/google` | ✅ Firebase ID token verify, role required |
| `POST /auth/social/apple` | ✅ Same + email/fullName fallback |
| `POST /auth/social/linkedin` | ✅ LinkedIn userinfo API |

### New user bootstrap (social)

- Role profile + wallet + notification preferences (same as email register)
- Existing users: ensure role profile + resources upserted

### Not configured

```json
{
  "success": false,
  "message": "Google login is not configured yet",
  "code": "SOCIAL_LOGIN_NOT_CONFIGURED"
}
```

Requires `FIREBASE_SERVICE_ACCOUNT_KEY` on server.

## Flutter

| Provider | Status |
|----------|--------|
| Google | ✅ Role picker → idToken → API |
| Apple | ✅ iOS/macOS, identity token |
| LinkedIn | ⚠️ Shows "LinkedIn login coming soon" (no crash) |

### UX fixes

- Google sign-in cancel → silent (no error snackbar)
- Social errors from backend shown via existing `BlocConsumer` on login/signup
- Role always sent with social payload

## Remaining gap

LinkedIn mobile OAuth UI not implemented — backend ready when `accessToken` is provided.
