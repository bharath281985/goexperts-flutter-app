# Easebuzz Live Setup

## Server configuration (`.env` only — never commit)

```env
EASEBUZZ_KEY=8BIGQZS5AE
EASEBUZZ_SALT=5D9UII20TB
EASEBUZZ_ENV=live
EASEBUZZ_SUCCESS_URL=https://goexperts.in/payment/success
EASEBUZZ_FAILURE_URL=https://goexperts.in/payment/failure
```

Set these on the **production server** at `mobileapi.goexperts.in`, not in the Flutter repo.

## Backend implementation

- `src/modules/payments/gateways/easebuzz.gateway.ts` — SHA-512 hash, `initiateLink` API, reverse hash verify
- `src/modules/payments/payments.service.ts` — creates `Payment` record, verify activates subscription
- Webhook: updates payment status on success

## Verify gateway enabled

```bash
curl -H "Authorization: Bearer <token>" \
  https://mobileapi.goexperts.in/api/v1/mobile/payments/gateways
```

Expect `easebuzz.enabled: true` when key + salt are set.

## Test initiate (authenticated)

```bash
curl -X POST https://mobileapi.goexperts.in/api/v1/mobile/payments/initiate \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"gateway":"easebuzz","purpose":"subscription","amount":999,"currency":"INR","planId":"pro"}'
```

Response must include `paymentUrl` and `paymentId` — **never** `EASEBUZZ_SALT`.

## Flutter test

1. Login → subscription onboarding
2. Select paid plan → Subscribe
3. Browser opens Easebuzz checkout
4. Complete test/live payment
5. Return to app → Verify
6. Confirm `GET /subscriptions/current` shows active plan

## Errors

| Code | Meaning |
|------|---------|
| `PAYMENT_GATEWAY_NOT_CONFIGURED` | Missing `EASEBUZZ_KEY` or `EASEBUZZ_SALT` on server |
| `INVALID_GATEWAY` | Unsupported gateway name |
