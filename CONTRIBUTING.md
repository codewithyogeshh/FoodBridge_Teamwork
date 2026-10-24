# Contributing to FoodBridge 🤝

Thank you for contributing to **FoodBridge Teamwork**!

## 🚀 Quick Start for Collaborators

1. **Clone the repository**:
   ```bash
   git clone https://github.com/codewithyogeshh/FoodBridge_Teamwork.git
   cd FoodBridge_Teamwork
   ```

2. **Ensure Flutter 3.44.8 is active**:
   ```bash
   # If using FVM:
   fvm install 3.44.8
   fvm use 3.44.8

   # Check version:
   flutter --version
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Set up local environment**:
   ```bash
   cp .env.example .env
   ```

## 🌿 Branching Policy

- Never push directly to `main`.
- Create a feature branch:
  - `feature/<name>` for new features
  - `bugfix/<name>` for bug fixes
  - `docs/<name>` for documentation updates

## 🧪 Quality Gate Before Pushing

Before opening a PR, ensure all 3 checks pass:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --no-pub
flutter test
```

## 📬 Submitting a Pull Request

1. Push your branch to GitHub: `git push -u origin feature/<name>`
2. Open a Pull Request on GitHub against `main`.
3. Fill out the PR template with a description and verification checklist.
4. Wait for CI checks to pass and peer review approval.

## 💡 Code of Conduct

- Be respectful and inclusive in all interactions.
- Write clean, well-documented code with meaningful commit messages.
- Report bugs with clear steps to reproduce.
- Help teammates debug issues and share knowledge freely.
