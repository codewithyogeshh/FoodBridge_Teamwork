# FoodBridge Architecture & Data Flow Guide

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│  Donor Portal   │       │   NGO Portal    │       │ Volunteer Fleet │
└────────┬────────┘       └────────┬────────┘       └────────┬────────┘
         │                         │                         │
         ▼                         ▼                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       Flutter Presentation Layer                    │
│    (Stateful AppRepository + RealtimeNotificationOverlay Stream)    │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         Core Service Domain                         │
│  • AIAllocationService     • OfflineSyncService   • WebhookService  │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Supabase Cloud Backend                         │
│  • Postgres Schema (RLS)   • Realtime Channels    • Storage Buckets │
└─────────────────────────────────────────────────────────────────────┘
```

## Security & Verification Flows
1. **Donation Creation**: Donor uploads food batch with photo proof and perishability timer.
2. **AI Scoring**: Calculates urgency index and suggests best-fit local shelter.
3. **Dispatch & Notification**: Alert broadcast via Supabase Realtime to volunteer riders.
4. **Secure Handshake**: Donor verifies pickup via secure 4-digit PIN / OTP.
5. **Dropoff & Chain-of-Custody**: Thermal log check and delivery receipt recorded.
