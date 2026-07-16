# Founder API Integration — Phase 19-D

Date: 2026-07-07

## Integrated in this pass

- Founder dashboard:
  - `GET /founder/dashboard`
  - wired in `DashboardCubit` and rendered in `FounderHomePage`.
- Founder profile:
  - `GET /founder/profile`
  - `PUT /founder/profile`
  - route `Routes.founderProfile` now points to a live profile page.
- Startup profile:
  - `GET /founder/startup`
  - integrated in `MyStartupView` with live refresh.
- Funding:
  - `GET /founder/funding`
  - `POST /founder/funding`
  - `PATCH /founder/funding/:id/status`
  - route `Routes.founderFunding` now points to live funding page.
- Investor requests:
  - `GET /founder/investor-requests`
  - `PATCH /founder/investor-requests/:id/accept`
  - `PATCH /founder/investor-requests/:id/reject`
  - integrated through `FounderRepositoryImpl` and `MyStartupView`.
- Founder investors:
  - `GET /founder/investors`
  - `GET /founder/investors/:id`
  - wired in role-aware `InvestorRepositoryImpl` for founder role.
- Pitch deck & business plan:
  - `GET/POST/PUT /founder/pitch-deck`
  - `GET/POST/PUT /founder/business-plan`
  - routes switched to live editors.
- Team, documents, meetings, messages:
  - `GET/POST /founder/team`
  - `GET /founder/documents`
  - `POST /founder/documents/upload` (files fallback kept)
  - `GET /founder/meetings`, `POST /founder/meetings` path wiring
  - `GET /founder/messages/conversations`, `POST /founder/messages/send` path wiring
- Analytics/reports/wallet/subscription role paths:
  - `GET /founder/analytics`
  - `GET /founder/reports`
  - `GET /founder/wallet`
  - `GET /founder/invoices`
  - `GET /founder/subscriptions/current`
  - `GET /founder/subscriptions/plans`

## Repositories updated

- `FounderRepositoryImpl` (API-first for founder + investor requests)
- `InvestorRepositoryImpl` (founder-aware investor discovery paths)
- `MeetingRepositoryImpl` (founder role endpoint paths)
- `MessageRepositoryImpl` (founder role endpoint paths)
- `WalletRepositoryImpl` (founder role wallet/invoice paths)
- `SubscriptionRepositoryImpl` (founder current/plans paths)
- `StartupRepositoryImpl` (kept role-aware from prior phases)
- `DashboardCubit` (founder dashboard endpoint wiring)

## Notes

- No route names changed.
- No UI redesign performed.
- Unauthenticated live probes return `401`; authenticated founder token QA is required for business-level validation.
