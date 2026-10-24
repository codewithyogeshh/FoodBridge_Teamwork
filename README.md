# FoodBridge Teamwork 🍱🤝

> **Empowering Communities, Eliminating Hunger, and Minimizing Food Waste.**  
> An intelligent, multi-portal surplus food rescue and redistribution ecosystem built with Flutter & Supabase.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.44.8-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.12.2-0175C2?logo=dart)](https://dart.dev)
[![Backend](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 📌 Environment & Exact Version Matrix (Source of Truth)

To eliminate **"it works on my machine"** versioning discrepancies across team members, every collaborator **must** align with the locked versions below:

| Component | Target Version | Constraint in `pubspec.yaml` | Notes |
|---|---|---|---|
| **Flutter SDK** | **`3.44.8`** (stable channel) | `>=3.44.0 <4.0.0` | Enforced in `pubspec.yaml` and `.fvmrc` |
| **Dart SDK** | **`3.12.2`** | `^3.12.2` | Bundled with Flutter 3.44.8 |
| **Java JDK** | **JDK 17** (LTS) | Recommended: OpenJDK 17 | Required for Android Gradle builds |
| **Android SDK** | Compile: `34`, Target: `34`, Min: `21` | Configured in `android/app/build.gradle` | Required for modern Android compatibility |
| **CocoaPods** (iOS/macOS) | `>= 1.14.0` | Latest stable | Required for iOS native plugins |

---

## 🛡️ Resolving Versioning & Dependency Problems

### 1. Recommended: Use FVM (Flutter Version Management)
We strongly recommend all team members install **FVM** to switch between Flutter versions effortlessly without breaking system-wide configurations:

```bash
# 1. Install FVM globally (one-time setup)
dart pub global activate fvm

# 2. In the project root, install and activate the exact team Flutter version
fvm install 3.44.8
fvm use 3.44.8

# 3. Use 'fvm flutter' instead of 'flutter'
fvm flutter pub get
fvm flutter run
```
> The project includes a pinned [`.fvmrc`](file:///.fvmrc) file configured to version `3.44.8`. FVM will automatically detect this configuration.

---

### 2. The Strict `pubspec.lock` Rule
- **Always commit `pubspec.lock`**: The lockfile guarantees that every team member installs identical transitive dependency versions.
- **Never run `flutter pub upgrade`** on shared branches without prior team agreement. Upgrading changes package versions in the lockfile and can introduce silent breaking changes for other teammates.
- **Always run `flutter pub get`** after pulling changes from Git.

---

### 3. Troubleshooting Common Versioning Errors

#### A. "The current Flutter SDK version is [x]... Version solving failed"
- **Cause**: You are running an older Flutter SDK (e.g., 3.19.x, 3.22.x) that does not satisfy `>=3.44.0`.
- **Fix**: Update Flutter to the team target version:
  ```bash
  flutter channel stable
  flutter upgrade
  # Or with FVM:
  fvm use 3.44.8
  ```

#### B. Incompatible Dependency Constraints or Broken Cache
- **Cause**: Corrupted build artifacts or conflicting cached package hashes.
- **Fix**: Perform a clean dependency reset:
  ```bash
  flutter clean
  rm pubspec.lock    # (Or on Windows: Remove-Item pubspec.lock)
  flutter pub get
  ```

#### C. Android Gradle / Java Version Conflict
- **Cause**: Using Java 8, 11, or 21 with Gradle configurations expecting JDK 17.
- **Fix**: Verify your Java version with `java -version`. Ensure `JAVA_HOME` points to JDK 17.

#### D. iOS / CocoaPods Podfile Lock Mismatches
- **Cause**: Native iOS dependencies out of sync with Flutter plugin versions.
- **Fix**:
  ```bash
  cd ios
  pod deintegrate
  pod repo update
  pod install
  cd ..
  ```

---

## 🤝 Team Collaboration & Git Workflow

To maintain code stability and eliminate merge conflicts, all team members should follow this workflow:

```mermaid
gitgraph
   commit id: "Initial Commit"
   branch feature/donor-photos
   checkout feature/donor-photos
   commit id: "feat: add photo picker"
   commit id: "feat: upload to supabase"
   checkout main
   merge feature/donor-photos id: "PR #1 Merged"
   branch feature/ngo-map
   checkout feature/ngo-map
   commit id: "feat: shelter markers"
   checkout main
   merge feature/ngo-map id: "PR #2 Merged"
```

### 1. Branch Naming Standard
Never push directly to `main`. Create isolated branches using this naming format:
- `feature/<short-description>` (e.g., `feature/ngo-reservation-flow`)
- `bugfix/<short-description>` (e.g., `bugfix/pickup-code-timer-crash`)
- `refactor/<short-description>` (e.g., `refactor/supabase-service-cache`)
- `docs/<short-description>` (e.g., `docs/api-contracts`)

---

### 2. Step-by-Step Contribution Cycle

#### Step 1: Sync your local `main` with remote
```bash
git checkout main
git pull origin main
```

#### Step 2: Create a new feature branch
```bash
git checkout -b feature/your-feature-name
```

#### Step 3: Install dependencies and configure environment
```bash
flutter pub get
cp .env.example .env    # Fill in your Supabase credentials if not present
```

#### Step 4: Develop, Run, and Test Locally
Keep code formatted and run the test suite frequently:
```bash
# Format code
dart format .

# Check for static lint errors
flutter analyze

# Run all unit and widget tests
flutter test
```

#### Step 5: Commit changes using Conventional Commits
Format commit messages with clear prefixes:
- `feat: add donor photo upload with camera & gallery preview`
- `fix: resolve double reservation bug on concurrent claims`
- `docs: update collaboration workflow in README`
- `test: add unit tests for AI allocation score calculation`
- `refactor: optimize Supabase realtime listener stream`

```bash
git add .
git commit -m "feat: description of changes"
```

#### Step 6: Keep your branch updated before opening a PR
Avoid merge conflicts by rebasing or merging `main` before pushing:
```bash
git fetch origin
git merge origin/main
```
If there are conflicts, resolve them, run `flutter test`, and complete the merge.

#### Step 7: Push branch & Open a Pull Request (PR)
```bash
git push -u origin feature/your-feature-name
```
- Navigate to [FoodBridge_Teamwork Pull Requests](https://github.com/codewithyogeshh/FoodBridge_Teamwork/pulls).
- Click **New Pull Request**.
- Provide a summary of changes, screenshots/recordings if UI changed, and verification evidence (`flutter test` output).
- Request a review from at least one team member.

---

## 🚀 Key Highlights & Architectural Modules

1. **Multi-Role Portals**:
   - **Donors (Restaurants, Caterers, Households)**: Post surplus food batches with real-time freshness countdowns, batch photo capture, quantity metrics, and automated expiry tracking.
   - **NGOs & Relief Shelters**: Browse real-time available food batches nearby, reserve portions with concurrency lock protection, verify collections via OTP/verification codes, and track pickups.
   - **Community Hub**: Peer-to-peer sharing, volunteer coordination, and emergency ration drives.
   - **Admin Command Portal**: Real-time dispatch oversight, verified NGO onboarding, safety audit tracking, and delivery progress monitoring.

2. **Smart AI Urgency & Allocation Engine**:
   - Analyzes food perishability (cooked meals vs. bakery vs. raw produce), storage requirements, and optimal consumption windows.
   - Transparent, explainable allocation recommendations to match surplus food with the closest, most eligible shelters.

3. **Enterprise-Grade Real-Time Backend (Supabase)**:
   - Row Level Security (RLS) ensuring strict role isolation.
   - Real-time notification streams for reservations, status transitions, and emergency alerts.
   - Storage buckets for high-resolution food quality verification photos.

---

## 📂 Project Architecture

```
f:/My_Agent/
├── .fvmrc                     # Pinned Flutter SDK version for FVM (3.44.8)
├── .env.example               # Environment template for Supabase & Map keys
├── pubspec.yaml               # Locked dependencies and SDK constraints
├── pubspec.lock               # Deterministic dependency lockfile (Committed to Git)
├── lib/
│   ├── main.dart              # Application entrypoint & theme initialization
│   ├── data/
│   │   ├── models/            # Data models (Donations, NGOs, Users, Notifications)
│   │   ├── repositories/      # AppRepository providing state and cache management
│   │   └── services/          # Supabase, AI allocation, Webhooks, Offline sync
│   └── ui/
│       ├── core/              # Theme, colors, typography, reusable widgets
│       └── features/
│           ├── admin/         # NGO approvals, delivery monitoring, audits
│           ├── auth/          # Splash, OTP, onboarding, role selection
│           ├── community/     # Peer-to-peer sharing & impact ledger
│           ├── donor/         # Create donation, photo capture, status tracking
│           ├── ngo/           # Food discovery, reservation confirm, pickup verify
│           └── logistics/     # Live delivery routing & WhatsApp dispatch
└── test/
    ├── unit_test.dart         # Unit tests (Allocation logic, models, Supabase sync)
    └── widget_test.dart       # Widget tests (Smoke testing & navigation)
```

---

## 🧪 Pre-Push Quality Checklist

Before submitting a Pull Request, every team member **must verify**:

- [ ] `flutter pub get` completes with 0 errors.
- [ ] `dart format --set-exit-if-changed .` passes (or format with IDE).
- [ ] `flutter analyze --no-pub` reports **0 issues**.
- [ ] `flutter test` reports **all tests passed**.
- [ ] `.env` is **not** committed to Git (verify with `git status`).

---

## 👥 Core Team & Maintainers
- **Yogesh Chavan** ([@codewithyogeshh](https://github.com/codewithyogeshh)) - Lead Maintainer & Full-Stack Architect
- **Team Collaborators**: See [Contributors](https://github.com/codewithyogeshh/FoodBridge_Teamwork/graphs/contributors)

---

## 📄 License
This project is open-source under the MIT License.
