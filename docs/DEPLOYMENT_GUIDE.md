# FoodBridge 2.0 Production Deployment Guide

## 1. Environment Configuration (.env)
Required environment variables:
```env
SUPABASE_URL=https://idajqabgvficbtvrqkvx.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_key
WHATSAPP_BOT_API_KEY=your_whatsapp_bot_key
```

## 2. Android Build Configuration
1. Sign release APK / App Bundle:
   ```bash
   flutter build appbundle --release
   ```
2. Verify keystore credentials in `android/key.properties`.

## 3. iOS / Web Build
1. Web release:
   ```bash
   flutter build web --release --pwa-strategy=offline-first
   ```
2. iOS Archive via Xcode workspace:
   ```bash
   flutter build ipa --release
   ```

## 4. Database Migration & RLS Security Checklist
- [x] Enable Row-Level Security on `donations`, `ngos`, `user_profiles`, `notifications`.
- [x] Configure Realtime Publication for `foodbridge-live`.
- [x] Configure Storage bucket `food-verification-photos` with public read, authenticated upload.
