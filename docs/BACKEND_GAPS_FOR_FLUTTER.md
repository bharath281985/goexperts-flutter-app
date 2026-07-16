# Backend Gaps for Flutter

**Updated:** Phase 24-A — 2026-07-07

## Critical — deploy required

| Gap | Action |
|-----|--------|
| **Production DB missing `users.is_online`** | Run `npx prisma db push` on server or `prisma/migrations/manual_add_user_presence.sql` |
| **Backend Phase 24-A not deployed** | Deploy rebuilt `dist/` — login/register currently expose raw Prisma errors on live API |

## Resolved in Phase 24-A (code)

| Feature | Status |
|---------|--------|
| Clean API error responses | ✅ `error-mapper.ts` |
| Registration with wallet + prefs | ✅ |
| Login USER_NOT_FOUND / INVALID_CREDENTIALS | ✅ |
| Token codes TOKEN_EXPIRED etc. | ✅ |
| Social login bootstrap | ✅ |
| Flutter auto logout on session expiry | ✅ |

## Remaining gaps

### LinkedIn mobile OAuth (Flutter)

Backend `POST /auth/social/linkedin` ready. Flutter shows "LinkedIn login coming soon".

### Firebase service account (server)

`FIREBASE_SERVICE_ACCOUNT_KEY` required for Google/Apple social login.

### Legacy API 404s

`/search`, `/chat/*`, `/app/feature-flags` — unchanged from prior phases.

### device-token without auth

`POST /app/device-token` may accept unauthenticated requests — review middleware.
