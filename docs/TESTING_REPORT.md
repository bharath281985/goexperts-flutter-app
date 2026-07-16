# Testing Report — Phase 24-A

**Date:** 2026-07-07

## Automated

| Command | Result |
|---------|--------|
| `npx prisma validate` | ✅ Pass |
| `npx prisma generate` | ✅ Pass |
| `npx prisma db push` | ❌ Local MySQL unreachable (`P1001`) — run on production server |
| `npm run build` (backend) | ✅ Pass |
| `flutter analyze` | ✅ No errors (warnings only) |
| `flutter test` | ✅ 2/2 passed |
| `flutter build apk --debug` | ✅ `build/app/outputs/flutter-apk/app-debug.apk` |

## Live API (pre-deploy — old code still running)

| Test | Result |
|------|--------|
| `POST /auth/login` unregistered | ❌ Raw Prisma `is_online` error (fixed in code, not deployed) |
| `POST /auth/register` | ❌ Same — DB column missing on production |

## After production deploy checklist

1. Run on server:
   ```bash
   npx prisma db push
   # OR: mysql < prisma/migrations/manual_add_user_presence.sql
   npm run build && restart app
   ```
2. Re-test login unregistered → `USER_NOT_FOUND`
3. Register each role → success + correct `role` in response
4. Duplicate register → `EMAIL_ALREADY_EXISTS`
5. Invalid token on `/auth/me` → `INVALID_TOKEN`
6. Flutter: expire session → auto logout + snackbar

## Manual Flutter QA

- [ ] Register freelancer / client / investor / founder
- [ ] Login wrong password message
- [ ] Google social with role picker
- [ ] Session expiry auto logout
- [ ] LinkedIn shows "coming soon"
