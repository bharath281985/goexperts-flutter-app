# Freelancer Screen Matrix — Phase 19-A2

Date: 2026-07-07

| Screen | Route | API Status | Notes |
|---|---|---|---|
| Freelancer Home Dashboard | `/freelancer/dashboard` | Live | Dashboard cards/charts from `/freelancer/dashboard` |
| Projects List | `/freelancer/projects` | Live | `/freelancer/projects` |
| Project Detail | `/project/:id` | Live | Freelancer-aware project detail path used |
| Proposals List | `/freelancer/proposals` | Live | `/freelancer/proposals` |
| Proposal Detail | `/proposal/:id` | Live | Includes withdraw action |
| Contracts | `/freelancer/contracts` | Live | `/freelancer/contracts` |
| Contract Detail | `/contract/:id` | Live | `/freelancer/contracts/:id` |
| Tasks | `/freelancer/tasks` | Live+ | List + status update + detail sheet + comments/attachments/time-log wiring with safe fallback |
| Meetings | `/meetings` | Live | Role-aware freelancer meetings |
| Messages | `/messages` and `/chat/:id` | Live (REST) | REST fallback integrated |
| Notifications | `/notifications` | Live | Role-aware freelancer notification endpoints |
| Wallet | `/wallet` | Live | Role-aware freelancer wallet endpoints |
| Invoices | `/freelancer/invoices` | Partial live | Uses wallet payment history mapping |
| Withdrawals | `/freelancer/withdrawals` | Partial | History from wallet transactions; request remains non-fake placeholder due backend gap |
| Reviews | `/freelancer/reviews` | Live/Partial | Detail still via list lookup fallback |
| Documents/Certificates | `/freelancer/certificates` | Live | Category filter + upload + preview/download/delete |
| Skills | `/freelancer/skills` | Live | `GET/PUT /freelancer/profile` |
| Experience | `/freelancer/experience` | Live read | `GET /freelancer/profile` |
| Education | `/freelancer/education` | Live read | `GET /freelancer/profile` |
| Subscription | `/subscriptions` | Live partial | Plans/current/upgrade integrated, payment UI pending |
| Settings | `/settings` | Live | `GET/PUT /freelancer/settings` |
| Portfolio | Profile tile navigation | Partial live | CRUD API-first with files fallback; no dedicated route name existed |
