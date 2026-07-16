# API ↔ Screen Mapping (Current)

Base URL: `https://mobileapi.goexperts.in/api/v1/mobile`

Legend: ✅ live | 🔄 partial | 🚫 backend gap

## Role dashboards

| Route | API | Status |
|---|---|---|
| `/freelancer/dashboard` | `GET /freelancer/dashboard` | ✅ |
| `/client/dashboard` | `GET /client/dashboard` | ✅ |
| `/investor/dashboard` | `GET /investor/dashboard` | ✅ |
| `/founder/dashboard` | `GET /founder/dashboard` | ✅ |

## Core role profile screens

| Route | API | Status |
|---|---|---|
| `/freelancer/profile` | `GET/PUT /freelancer/profile` | ✅ |
| `/client/profile` | `GET/PUT /client/profile` | ✅ |
| `/investor/profile` | `GET/PUT /investor/profile` | ✅ |
| `/founder/profile` | `GET/PUT /founder/profile` | ✅ |

## Shared modules

| Route | API | Status |
|---|---|---|
| `/messages` | role-specific `/.../messages/*` + shared `/chat/*` fallback | 🔄 |
| `/notifications` | `GET /notifications`, read/read-all/unread-count | ✅ |
| `/search` | `GET /search`, discovery recent/recommendations | ✅ |
| `/bookmarks` | shared + role repositories (favorites backend partial) | 🔄 |
| `/wallet` | role-aware wallet + transactions | ✅ |
| `/subscriptions` | role-aware current/plans | ✅ |
| `/support` | `GET/POST /support/tickets`, reply | ✅ |

## Founder / investor advanced modules

| Route | API | Status |
|---|---|---|
| `/investor/reports` | `GET /investor/reports`, portfolio, roi, analytics | ✅ |
| `/founder/analytics` | `GET /founder/analytics`, `GET /founder/reports` | ✅ |
| `/founder/pitch-deck` | `GET/POST/PUT /founder/pitch-deck` | ✅ |
| `/founder/business-plan` | `GET/POST/PUT /founder/business-plan` | ✅ |

## App runtime config

| Screen/Layer | API | Status |
|---|---|---|
| App bootstrap service | `GET /app/config`, `/app/version`, `/app/maintenance`, `/app/feature-flags` | 🔄 (`/app/feature-flags` currently 404 in unauth probe) |
