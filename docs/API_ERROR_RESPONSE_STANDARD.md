# API Error Response Standard

All mobile API errors use this envelope:

```json
{
  "success": false,
  "message": "User-friendly message",
  "code": "ERROR_CODE",
  "data": null,
  "errors": [],
  "timestamp": "2026-07-07T14:00:00.000Z"
}
```

## Never exposed to clients

- Prisma invocation text
- SQL / column names
- Stack traces
- Internal file paths

## Error code mapping (backend `error-mapper.ts`)

| Source | Client message | Code |
|--------|----------------|------|
| P1000 | Service temporarily unavailable | `SERVICE_UNAVAILABLE` |
| P2002 | This record already exists | `DUPLICATE_RECORD` |
| P2022 / missing column | Service temporarily unavailable | `SERVICE_UNAVAILABLE` |
| P2025 | Record not found | `NOT_FOUND` |
| Token expired (JWT) | Session expired. Please login again. | `TOKEN_EXPIRED` |
| Invalid JWT | Invalid session. Please login again. | `INVALID_TOKEN` |
| Account inactive | Your account is inactive. Please contact support. | `ACCOUNT_INACTIVE` |
| Firebase not configured | Social login is not configured yet | `SOCIAL_LOGIN_NOT_CONFIGURED` |

## Auth-specific codes

| Code | HTTP | Message |
|------|------|---------|
| `USER_NOT_FOUND` | 404 | User is not registered with us |
| `INVALID_CREDENTIALS` | 401 | Invalid email or password |
| `EMAIL_ALREADY_EXISTS` | 409 | Email is already registered. Please login. |
| `TOKEN_EXPIRED` | 401 | Session expired. Please login again. |
| `INVALID_TOKEN` | 401 | Invalid session. Please login again. |
| `REFRESH_TOKEN_EXPIRED` | 401 | Session expired. Please login again. |
| `TOKEN_REVOKED` | 401 | Session revoked. Please login again. |
| `FORBIDDEN` | 403 | You do not have permission to access this resource. |
| `VALIDATION_ERROR` | 422 | Field-specific message from Zod |

## Implementation

- `src/core/error-mapper.ts` — maps Prisma/JWT/internal errors
- `src/middleware/error.ts` — global Express handler
- `src/middleware/auth.ts` — auth middleware returns standard codes
