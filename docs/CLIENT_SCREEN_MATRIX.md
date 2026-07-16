# Client Screen Matrix — Phase 19-B

Date: 2026-07-07

| Screen | Route | Status | API |
|---|---|---|---|
| Client Home Dashboard | `/client/dashboard` | Live | `GET /client/dashboard` |
| Company Profile | `/client/profile` | Live | `GET/PUT /client/profile`, logo/doc uploads wired |
| My Projects list | `/client/projects` | Live | `GET /client/projects` |
| Create Project | `/client/create-project` | Live | `POST /client/projects` |
| Applications | `/client/applications` | Live | client proposal APIs (already integrated) |
| Shortlisted | `/client/shortlisted` | Live | client proposal APIs (already integrated) |
| Freelancer Discovery | `/client/freelancers` | Live | `GET /client/freelancers`, detail/save wired |
| Client Payments | `/client/payments` | Live/Partial | wallet + payments list wired; initiate/verify wired, gateway callback still pending |
| Teams | `/client/teams` | Live | `GET /client/team`, `POST /client/team/invite` |
| Messages | `/messages`, `/chat/:id` | Live | client conversation list/send wired |
| Meetings | `/meetings` | Live | client meetings endpoint wired |
| Wallet/Invoices | `/wallet`, `/client/payments` | Live | `GET /client/wallet`, `/client/wallet/transactions`, `/client/invoices` |
| Reviews | shared review screens | Partial Live | `GET /client/reviews` path wired; create/reply UI partial |
| Subscription | `/subscriptions` | Live/Partial | client subscriptions current/plans/upgrade/renew/cancel wired; payment callback flow pending |
| Support | `/support` | Partial | UI exists; dedicated client support ticket integration pending |
| Client Reports Hub | `/client/reports` | Live | tasks/milestones/payments/documents APIs wired with actions |
| Client Analytics | `/client/analytics` | Live | `GET /client/analytics` wired |
