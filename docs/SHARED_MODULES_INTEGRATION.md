# Shared Modules Integration — Phase 19-E

Date: 2026-07-07

## Completed shared modules in this pass

- **Chat / Messages**
  - Socket production URL set in config: `https://mobileapi.goexperts.in`
  - REST fallback aligned to chat endpoints for shared mode:
    - `GET /chat/conversations`
    - `GET /chat/conversations/:id`
    - `POST /chat/send`
  - Polling fallback added in `ChatCubit` (10s) when realtime stream is unavailable.
  - Removed fake periodic inbound demo messages from repository.
- **Notifications**
  - Added unread count API support.
  - Mark all read / mark single read wired to repository + UI.
  - Added delete + preferences repository methods.
- **Files / Documents**
  - Shared `/files` repository already live (list/upload/preview/download/delete).
  - Category filtering retained.
- **Search / Discovery**
  - Global search page now uses shared APIs:
    - `GET /search`
    - `GET /discovery/recently-viewed`
    - `GET /discovery/recommendations`
- **Wallet / Invoices / Subscriptions**
  - Shared role-aware repositories already live and preserved.
- **Support Tickets**
  - Support page now live-wired for:
    - `GET /support/tickets`
    - `POST /support/tickets`
    - `POST /support/tickets/:id/reply`
- **App Config**
  - Added runtime config bootstrap service:
    - `GET /app/config`
    - `GET /app/version`
    - `GET /app/maintenance`
    - `GET /app/feature-flags`

## Multi-language status

- Added locale infrastructure support in app shell:
  - supported locales: `en`, `hi`, `te`, `ta`, `kn`
  - localization delegates configured.
- Full key-level translation catalog for auth/navigation/dashboard/errors/settings is still pending.

## Socket.IO status

- Socket base URL configured for production.
- Full Socket.IO client transport (online presence, typing channel, read-receipt events, attachment realtime sync) is **not fully implemented yet**.
- Safe fallback is active through REST + polling.
