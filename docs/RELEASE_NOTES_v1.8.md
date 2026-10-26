# FoodBridge 2.0 Release Notes — Version 1.8.0

**Release Date:** October 26, 2026  
**Lead Maintainer:** Yogesh Chavan ([@codewithyogeshh](https://github.com/codewithyogeshh))

---

## 🌟 What's New in v1.8.0

### 1. Model & Data Enhancements
- Added helper queries (`isDonor`, `isVolunteer`, `isNgo`, `isAdmin`, `isCommunity`) and immutable `copyWith` to `UserProfileModel`.
- Added `vehicleType` tracking for volunteer delivery fleets.
- Added freshness calculators (`isSafeToConsume`, `remainingMinutes`) to `DonationModel`.
- Added capacity and verification indicators to `NGOModel`.
- Added fulfillment status and 80G tax receipt validation to `CommunityDonationModel`.

### 2. Localization Expansion
- Extended Marathi (`mr`) and Hindi (`hi`) dictionaries with terminology for volunteer delivery, OTP handshakes, and food classification.

### 3. AI Allocation & ESG Metrics
- Added direct calculation of CO2e greenhouse gas offset and conserved water footprints per rescued meal.

### 4. Developer Guides & System Architecture
- Added comprehensive REST and Realtime WebSocket API documentation (`docs/API_DOCUMENTATION.md`).
- Added system architecture diagram and component interaction topology (`docs/ARCHITECTURE_DIAGRAMS.md`).
- Added food safety and thermal preservation guidelines (`docs/FOOD_SAFETY_PROTOCOLS.md`).
- Added production deployment checklist (`docs/DEPLOYMENT_GUIDE.md`).

---
Total Commits in Milestone: **50 Commits**
