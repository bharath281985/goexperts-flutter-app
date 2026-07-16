# Client API Integration — Phase 19-B

Date: 2026-07-07

## Integrated in this pass

- Client dashboard data wiring in `DashboardCubit`:
  - `GET /client/dashboard`
  - mapped to existing dashboard state fields used by `ClientHomePage`.
- Client projects in shared `ProjectRepositoryImpl`:
  - `GET /client/projects`
  - `GET /client/projects/:id`
- Client project posting flow (`CreateProjectPage`):
  - `POST /client/projects`
- Client freelancer discovery in `FreelancerRepositoryImpl`:
  - `GET /client/freelancers`
  - `GET /client/freelancers/:id`
  - `POST /client/freelancers/:id/save`
- Client contracts in shared `ProjectRepositoryImpl`:
  - `GET /client/contracts`
  - `GET /client/contracts/:id`
- Client meetings/messages role-aware paths:
  - `GET /client/meetings`
  - `GET /client/messages/conversations`
  - `POST /client/messages/send`
- Client wallet/invoice role-aware paths:
  - `GET /client/wallet`
  - `GET /client/wallet/transactions`
  - `GET /client/invoices`
- Client reviews role-aware list:
  - `GET /client/reviews`
- Client subscriptions role-aware:
  - `GET /client/subscriptions/plans`
  - `GET /client/subscriptions/current`
  - `POST /client/subscriptions/upgrade`
  - `POST /client/subscriptions/renew`
  - `POST /client/subscriptions/cancel`
- Client team page:
  - `GET /client/team`
  - `POST /client/team/invite`

## Existing live flow kept intact

- Client proposal action flow remains live and unchanged:
  - project proposals list
  - shortlist/reject/interview/accept
  - proposal message action

## Phase 19-B2 blocker closure

- Company profile route wired to live client profile page:
  - `GET /client/profile`
  - `PUT /client/profile`
  - `POST /client/profile/logo`
  - `POST /client/profile/documents` (fallback `POST /files/upload`)
- Contracts lifecycle actions wired from contract detail:
  - `PATCH /client/contracts/:id/activate`
  - `PATCH /client/contracts/:id/complete`
  - `PATCH /client/contracts/:id/cancel`
- Client operations hub (`/client/reports`) added for pending blockers:
  - `GET /client/tasks`
  - `PATCH /client/tasks/:id/status`
  - `GET /client/milestones`
  - `PATCH /client/milestones/:id/approve`
  - `PATCH /client/milestones/:id/reject`
  - `GET /client/payments`
  - `POST /client/payments/initiate`
  - `POST /client/payments/verify`
  - `GET /client/documents` (upload fallback supported)
- Client analytics route now uses live endpoint:
  - `GET /client/analytics`

## Notes

- No route names were changed.
- No UI redesign performed.
- For protected endpoints, unauthenticated probe confirms `401` (expected); authenticated behavior requires a valid client token QA pass.
