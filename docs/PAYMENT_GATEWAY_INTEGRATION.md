# Payment Gateway Integration

## Security rule

**Flutter never contains:** Easebuzz salt, Razorpay secret, Stripe secret.  
All secrets live in backend `.env` only.

## Flutter flow (Easebuzz SDK in-app)

1. User selects paid plan on `SubscriptionSelectionPage`
2. `PaymentCheckoutService.checkoutWithEasebuzz()` → `POST /payments/initiate`
3. Backend returns `gatewayPayload.accessKey` + `payMode` (`test` / `production`)
4. App opens **Easebuzz native SDK** via `easebuzz_flutter` (`payWithEasebuzz`)
5. On SDK success → `POST /payments/verify` with SDK response fields
6. On verify success → `AuthSubscriptionRefreshed` (onboarding) or pop screen

Free plans (`free` or amount ≤ 0) still use existing `subscribe()` API.

## API

### Initiate

```
POST /payments/initiate
{
  "gateway": "easebuzz",
  "purpose": "subscription",
  "amount": 999,
  "currency": "INR",
  "planId": "pro",
  "metadata": { "billingCycle": "monthly" }
}
```

Response includes:

```json
{
  "paymentId": "...",
  "orderId": "EB...",
  "paymentUrl": "https://...",
  "gatewayPayload": {
    "accessKey": "<sdk-access-key>",
    "txnid": "EB...",
    "payMode": "production"
  }
}
```

### Verify

```
POST /payments/verify
{
  "paymentId": "...",
  "gateway": "easebuzz",
  "purpose": "subscription",
  "planId": "pro",
  "status": "success",
  "txnid": "..."
}
```

**Subscription activates only after backend verify** — no local success bypass.

## Gateways (backend)

| Gateway | Initiate | Webhook | Env vars |
|---------|----------|---------|----------|
| Easebuzz | ✅ Live hash + initiateLink | ✅ `/payments/webhooks/easebuzz` | `EASEBUZZ_KEY`, `EASEBUZZ_SALT`, `EASEBUZZ_ENV` |
| Razorpay | Stub / partial | Route exists | `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET` |
| Stripe | Stub / partial | Route exists | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` |

`EASEBUZZ_ENV=live` → SDK `payMode=production`  
Anything else → SDK `payMode=test`

## Flutter files

- `lib/core/payments/payment_checkout_service.dart` — initiate + Easebuzz SDK + verify
- `lib/features/subscriptions/presentation/pages/subscription_selection_page.dart`
- Package: `easebuzz_flutter: ^0.0.8`
