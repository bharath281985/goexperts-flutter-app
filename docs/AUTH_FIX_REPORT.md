# Auth Fix Report — Phase 24-A

**Date:** 2026-07-07

## Registration (`POST /auth/register`)

| Item | Status |
|------|--------|
| Unique email check | ✅ `EMAIL_ALREADY_EXISTS` |
| Role validation (Zod) | ✅ freelancer/client/investor/founder |
| Password hashing (bcrypt 12) | ✅ |
| Role profile creation | ✅ Transactional |
| Wallet creation | ✅ `bootstrapUserResources` |
| Notification preferences | ✅ Default row created |
| Session + refresh token | ✅ |
| FCM device token | ✅ Optional |
| Clean success payload | ✅ `profileCompletion: 0`, `redirectTo` |

## Login (`POST /auth/login`)

| Case | HTTP | Message | Code |
|------|------|---------|------|
| Email not found | 404 | User is not registered with us | `USER_NOT_FOUND` |
| Wrong password | 401 | Invalid email or password | `INVALID_CREDENTIALS` |
| Inactive account | 403 | Your account is inactive. Please contact support. | `ACCOUNT_INACTIVE` |
| Success | 200 | Login successful | — |

## Refresh token (`POST /auth/refresh`)

| Case | Code |
|------|------|
| Expired | `REFRESH_TOKEN_EXPIRED` |
| Revoked | `TOKEN_REVOKED` |
| Invalid JWT | `INVALID_TOKEN` |

## Flutter registration

- Role from `RoleSelectionPage` → `AuthRoleSelected` → API `role` field (not defaulted to freelancer)
- Registration errors shown via `BlocListener` on role selection page
- Backend `message` surfaced in snackbar on login/signup pages

## Files changed (backend)

- `src/modules/auth/auth.controller.ts`
- `src/services/auth-bootstrap.service.ts`
- `src/modules/auth/social.controller.ts`
- `src/middleware/auth.ts`
- `src/core/error-mapper.ts`
- `src/middleware/error.ts`
- `src/validators/auth.validator.ts` (added `macos` platform)
- `src/socket/auth.ts` (JWT `id` fix)

## Files changed (Flutter)

- `lib/core/network/dio_client.dart`
- `lib/core/auth/session_handler.dart`
- `lib/app/app.dart`
- `lib/features/role_selection/.../role_selection_page.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/data/datasources/social_auth_service.dart`

## Deploy blocker

Production API still returns raw Prisma error until:
1. `npx prisma db push` on server DB, **or**
2. Run `prisma/migrations/manual_add_user_presence.sql`
3. Deploy rebuilt backend (`npm run build`)
