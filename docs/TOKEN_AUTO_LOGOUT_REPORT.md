# Token Auto Logout Report — Phase 24-A

## Backend token codes

| Scenario | HTTP | Code |
|----------|------|------|
| Access token expired | 401 | `TOKEN_EXPIRED` |
| Access token invalid | 401 | `INVALID_TOKEN` |
| Refresh token expired | 401 | `REFRESH_TOKEN_EXPIRED` |
| Refresh token revoked | 401 | `TOKEN_REVOKED` |

## Flutter flow (`dio_client.dart`)

1. API request returns **401** (non-auth routes)
2. `_RefreshInterceptor` attempts `POST /auth/refresh` once
3. **Refresh success** → save new tokens → retry original request + queued requests
4. **Refresh failure** or session codes → `SecureStorage.deleteAll()` → `SessionHandler.notifyExpired(message)`
5. `app.dart` → `AuthLoggedOut` + snackbar: *"Session expired. Please login again."*
6. Router redirects to login (unauthenticated state)

## Session codes handled

`TOKEN_EXPIRED`, `INVALID_TOKEN`, `REFRESH_TOKEN_EXPIRED`, `TOKEN_REVOKED`

## User experience

- No silent stuck dashboard after expiry
- Server `message` used when available
- 401 errors not double-shown via `GlobalErrorBus` during logout

## Files

- `lib/core/network/dio_client.dart`
- `lib/core/auth/session_handler.dart`
- `lib/app/app.dart`
- `lib/core/network/api_exception_handler.dart` (string `errorCode` from envelope)
