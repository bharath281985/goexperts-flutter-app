# Device QA Checklist — Phase 23

Run on **physical devices** with production API: `https://mobileapi.goexperts.in/api/v1/mobile`

Package: `com.doorstephub.goexperts`

## Android

- [ ] Email login
- [ ] Google login (role picker → sign-in)
- [ ] Role signup (draft → role → register)
- [ ] FCM token generated (log / network tab)
- [ ] `POST /app/device-token` after login
- [ ] Individual push notification received
- [ ] Subscription gate blocks dashboard without plan
- [ ] Easebuzz payment initiate → browser → verify → subscription active
- [ ] File upload (document / avatar multipart)
- [ ] Offline banner when airplane mode (`connectivity_plus`)

## iOS

- [ ] Apple login
- [ ] FCM permission prompt
- [ ] Push notification received
- [ ] Subscription / Easebuzz payment flow
- [ ] Google Sign-In URL scheme callback

## Sign-off

| Tester | Device | Date | Pass/Fail |
|--------|--------|------|-----------|
| | | | |
