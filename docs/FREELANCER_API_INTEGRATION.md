# Freelancer API Integration — Phase 19-A2

Date: 2026-07-07

## Integrated in this pass

- Freelancer profile subpages in `freelancer_subpages.dart` now use live profile API:
  - Skills: `GET /freelancer/profile`, `PUT /freelancer/profile`
  - Experience: `GET /freelancer/profile`
  - Education: `GET /freelancer/profile`
- Freelancer tasks page now uses live task API:
  - `GET /freelancer/tasks`
  - `PATCH /freelancer/tasks/:id/status`
- Settings page now uses live settings API:
  - `GET /freelancer/settings`
  - `PUT /freelancer/settings`
- Subscription page now uses live subscription API:
  - `GET /freelancer/subscription/plans`
  - `GET /freelancer/subscription`
  - `POST /freelancer/subscription/upgrade`
  - `POST /freelancer/subscription/renew`
  - `POST /freelancer/subscription/cancel` (repository support)
- Certificates list now uses files API when live mode is enabled:
  - `GET /files?category=certificate`
- Portfolio flow added with API-first + files fallback:
  - `GET /freelancer/portfolio` (fallback: `GET /files?category=portfolio`)
  - `POST /freelancer/portfolio`
  - `PUT /freelancer/portfolio/:id`
  - `DELETE /freelancer/portfolio/:id` (fallback delete file id)
- Document manager repository added:
  - `GET /files`
  - `GET /files/:id`
  - `GET /files/:id/preview`
  - `GET /files/:id/download`
  - `POST /files/upload`
  - `DELETE /files/:id`
- Task detail bottom-sheet added (from task list row) via:
  - `GET /freelancer/tasks/:id`

## Phase 19-A4 updates

- Live API validation performed against production host for freelancer blocker endpoints.
- Task collaboration wiring added in repository + UI:
  - `addComment(taskId, text)` -> `POST /freelancer/tasks/:id/comments`
  - `addAttachment(taskId, filePath)` -> `POST /freelancer/tasks/:id/attachments`
  - `getTimeLogs(taskId)` -> tries `GET /freelancer/tasks/:id/time-logs`, falls back to task detail payload.
- Task detail sheet now renders:
  - comments list + add comment action
  - attachment list + upload action
  - time log list
  - safe unavailable states on endpoint failure.
- Withdrawal page remains non-fake:
  - request action explicitly shows “coming soon / API not available”.

## Repositories added/updated

- Added `FreelancerProfileRepository` + `FreelancerProfileRepositoryImpl`
- Added `FreelancerTaskRepository` + `FreelancerTaskRepositoryImpl`
- Added `SettingsRepository` + `SettingsRepositoryImpl`
- Updated `SubscriptionRepository` / `SubscriptionRepositoryImpl` for live plan/current/upgrade/renew/cancel
- Updated `CatalogRepositoryImpl.getCertificates()` to live files API

## Models added

- `FreelancerProfile`
- `FreelancerTask`

## DI updates

- Registered in `service_locator.dart`:
  - `FreelancerProfileRepository`
  - `FreelancerTaskRepository`
  - `SettingsRepository`
- Updated registration:
  - `SubscriptionRepositoryImpl(apiClient)`
  - `CatalogRepositoryImpl(apiClient)`

## Notes

- Existing route names were preserved.
- Existing screen structure was preserved; no redesign.
- Profile avatar/resume/certificate upload repository methods are wired to backend endpoints, but full file picker + multipart UX is still pending as a dedicated UI task.
