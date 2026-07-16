# Investor Screen Matrix — Phase 19-C

Date: 2026-07-07

| Screen | Route | Status | API |
|---|---|---|---|
| Investor Home Dashboard | `/investor/dashboard` | Live | `GET /investor/dashboard` |
| Investor Profile | `/investor/profile` | Live | `GET/PUT /investor/profile`, avatar/doc upload |
| Startup Discovery | `/investor/startups` | Live | `GET /investor/startups`, detail/save wired |
| Deal Rooms | `/investor/deals` | Live/Partial | `GET /investor/investments` list wired |
| Portfolio | `/investor/portfolio` | Live/Partial | `GET /investor/portfolio` list wired |
| Preferences | `/investor/preferences` | Partial | UI exists; dedicated persistence API still pending |
| Due Diligence | `/investor/due-diligence` | Partial | UI exists; checklist API contract pending |
| Offers | `/investor/offers` | Partial | UI exists; offer detail/status action completion pending |
| Investor Documents | `/investor/documents` | Live | `GET /investor/documents`, upload wired |
| Investor Reports | `/investor/reports` | Live | reports + portfolio + roi + analytics summary |
| Transactions | `/investor/transactions` | Live | shared wallet transactions role-aware |
| Meetings | `/meetings` | Live | role-aware investor meetings path |
| Messages | `/messages` | Live | role-aware investor conversations/send path |
