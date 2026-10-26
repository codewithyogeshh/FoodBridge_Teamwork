# FoodBridge 2.0 API & Realtime Protocol Documentation

This document specifies the backend endpoints, realtime channel events, and data schemas for FoodBridge 2.0.

---

## 1. REST Endpoints (Supabase PostgREST)

### `GET /rest/v1/donations`
Retrieves available, reserved, and active food surplus listings.
- **Query Parameters**:
  - `status=eq.available`: Filter for claimable donations.
  - `urgency_level=eq.critical`: Filter for items needing urgent pickup within 3 hours.
  - `order=created_at.desc`: Newest first.

### `POST /rest/v1/donations`
Submits a new food rescue surplus batch.
- **Payload Headers**:
  - `apikey`: Anon public client key.
  - `Authorization`: Bearer user session token.
- **Body Attributes**:
  - `title` (string, required): Meal or produce description.
  - `food_type` (string, required): One of `Cooked Meals`, `Bakery & Grains`, etc.
  - `quantity_servings` (integer, required): Estimated beneficiary meal count.
  - `safe_until` (ISO 8601 timestamp): Calculated consumption expiry window.
  - `pickup_latitude` / `pickup_longitude` (float): Geocoordinates.

### `PATCH /rest/v1/donations?id=eq.{id}`
Updates donation status, OTP verification, or volunteer assignment.

---

## 2. Realtime WebSocket Protocol

FoodBridge connects to Supabase Realtime channel `foodbridge-live`:

### Events:
- `broadcast:new_donation`: Triggered when a donor submits surplus. Broadcasts to nearby NGOs and volunteers.
- `broadcast:pickup_verified`: Sent after 4-digit OTP is verified at pickup point.
- `broadcast:delivery_completed`: Updates impact ledger and increments saved meals count.

---

## 3. Webhook Dispatch Integration

For external partner alerts and WhatsApp dispatcher notifications, outgoing webhooks are signed using HMAC-SHA256 headers:
- `X-FoodBridge-Signature`: Digest signature for verifying event authenticity.
- `X-FoodBridge-Event`: Event identifier (`DONATION_URGENT_ALLOCATED`).
