# city_view_website

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Payments (Paystack) Setup

Admissions payment is integrated with Paystack via Cloud Functions.

1) Configure Cloud Functions secret

```bash
cd functions
firebase functions:config:set paystack.secret_key="YOUR_PAYSTACK_SECRET_KEY"
firebase deploy --only functions
```

Alternatively, set `PAYSTACK_SECRET_KEY` in the functions runtime environment.

2) Deploy Firestore rules and indexes

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

3) Paystack Dashboard → set Webhook URL

```
https://<YOUR_REGION>-<YOUR_PROJECT>.cloudfunctions.net/paystackWebhook
```

4) Test
- Submit an application at `/admissions`
- Open `/admissions/pay/:id` and click “Pay with Paystack”
- On success, webhook updates `admissions/{id}.paymentStatus` to `paid`