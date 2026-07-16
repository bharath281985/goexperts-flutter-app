# Investor API Integration — Phase 19-C

Date: 2026-07-07

## Integrated in this pass

- Investor dashboard:
  - `GET /investor/dashboard`
  - wired in `DashboardCubit` and consumed by `InvestorHomePage` cards/chart.
- Investor profile:
  - `GET /investor/profile`
  - `PUT /investor/profile`
  - `POST /investor/profile/avatar`
  - `POST /investor/profile/documents` (fallback to `POST /files/upload`)
  - route `Routes.investorProfile` now points to a dedicated live profile page.
- Startup discovery for investor role:
  - `GET /investor/startups`
  - `GET /investor/startups/:id`
  - save/unsave via `POST/DELETE /investor/startups/:id/save`
  - implemented in role-aware `StartupRepositoryImpl`.
- Watchlist / investment / portfolio list wiring:
  - `GET /investor/watchlist` + create/delete behavior via watchlist endpoints
  - `GET /investor/investments`
  - `GET /investor/portfolio`
  - implemented in `InvestorRepositoryImpl`.
- Meetings & messages role-aware paths:
  - `GET /investor/meetings`
  - `GET /investor/messages/conversations`
  - `POST /investor/messages/send`
- Documents:
  - `GET /investor/documents`
  - `POST /investor/documents/upload` (with files fallback)
  - route `Routes.investorDocuments` now uses live documents page.
- Reports & analytics:
  - `GET /investor/reports`
  - `GET /investor/reports/portfolio`
  - `GET /investor/reports/roi`
  - `GET /investor/analytics`
  - route `Routes.investorReports` now uses live reports page that also pulls analytics summary.

## Shared investor modules verified as role-aware

- Wallet / transactions / invoices (shared repo paths)
- Notifications
- Subscriptions
- Settings / search / auth session flow unchanged

## Notes

- No route names changed.
- No UI redesign performed.
- Protected live endpoints return `401` without investor token; authenticated functional QA is pending.
