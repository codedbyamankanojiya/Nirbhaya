# 🤝 Contributing to Nirbhaya

Thank you for your interest in contributing to **Nirbhaya** — a life-critical Women's Safety & Emergency Assistance mobile platform conceptualized, architected, and developed solely by **Aman Kanojiya**. Every line of code, bug report, and documentation improvement helps protect lives and empower women in crisis.

Please take a few moments to review these contribution guidelines before submitting issues or pull requests.

---

## 📜 Code of Conduct

All contributors and community members are expected to adhere to the [Code of Conduct](CODE_OF_CONDUCT.md). I am committed to maintaining a friendly, respectful, and safe environment for everyone.

---

## 🛠️ Getting Started

### 1. Prerequisites
Ensure you have the following developer tools installed on your workstation:
- **Flutter SDK**: `^3.24.0` or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: `^3.5.0` or higher
- **Android Studio** / **VS Code** with Flutter and Dart extensions
- **Android SDK & Platform Tools** (API Level 34+ recommended)
- **Git**

### 2. Fork & Clone
```bash
git clone https://github.com/codedbyamankanojiya/Nirbhaya.git
cd Nirbhaya
```

### 3. Setting Up Local Secrets & Environment
To protect sensitive credentials, Nirbhaya enforces a strict **Zero-Leak Policy**:
1. Copy the environment template:
   ```bash
   cp .env.example .env
   ```
2. (Optional) If testing Firebase locally:
   - Run `flutterfire configure` to connect your own free Firebase test project.
   - Or copy the dummy template:
     ```bash
     cp android/app/google-services.json.example android/app/google-services.json
     cp lib/firebase_options.dart.example lib/firebase_options.dart
     ```
3. Fetch Flutter dependencies:
   ```bash
   flutter pub get
   ```

---

## 🏛️ Architecture & Best Practices

Nirbhaya follows modern **Clean Architecture** combined with **Riverpod 2.6+ reactive state management**:

```
lib/
├── app/                  # Routing (GoRouter), Theme (Material 3), Global Config
├── core/                 # Shared network clients (Dio), Platform checks, Firebase Sync
├── features/
│   ├── ai_assistant/     # Google Gemini 1.5 Flash + Offline Indian Legal Engine
│   ├── auth/             # Biometrics, Token Storage (Keystore), Glassmorphic UI
│   ├── contacts/         # Emergency contacts, Primary priorities, Direct dialer
│   ├── location/         # High-accuracy live GPS stream & Geolocator service
│   ├── maps/             # OpenStreetMap radar tracking & Safety POI search
│   ├── profile/          # Medical Emergency Card, Personal Details, Govt ID
│   ├── resources/        # Helplines (112, 1091, 181, 1930) & Interactive Legal Guides
│   ├── settings/         # PIN code, Countdown duration, Sensitivity sliders, UI themes
│   ├── sos/              # Emergency SOS State Machine, Sirens, Strobe, Haptics
│   └── uploads/          # Evidence Studio (Photos, Video, Stealth Audio Recording)
└── shared/               # Reusable Glassmorphism widgets, Badges, Dialogs
```

### Key Engineering Rules:
1. **Offline-First Resilience**: All critical safety features (SOS sirens, 112 phone calls, SMS alerts, OpenStreetMap, local contacts, and Indian legal guides) must function **100% offline** without network connectivity.
2. **State Machine Integrity**: Always guarantee proper cleanup (`Timer.cancel()`, `WakelockPlus.disable()`, `Vibration.cancel()`) when exiting or cancelling an emergency state.
3. **No Hardcoded Secrets**: Never commit API keys, personal phone numbers, or production tokens into source files. Use `String.fromEnvironment()` or `SharedPreferences`.
4. **Material 3 Tokens**: Always consume colors, radii, and typography from [`lib/app/theme.dart`](file:///d:/Projects/Android/Flutter%20Projects/Nirbhaya/lib/app/theme.dart) to preserve accessibility and theme consistency.

---

## 🧪 Testing & Quality Assurance

Before submitting any Pull Request, ensure your code passes static analysis and tests:

```bash
# 1. Run static analysis (must report zero errors)
flutter analyze

# 2. Run unit and widget tests
flutter test

# 3. Format code according to Dart guidelines
dart format --set-exit-if-changed .
```

---

## 🔀 Git Branching & Commit Conventions

Please follow the **Conventional Commits** specification:

### Branch Naming:
- `feat/feature-name` (New features)
- `fix/bug-description` (Bug fixes)
- `docs/documentation-update` (Docs & guides)
- `perf/optimization-name` (Performance improvements)
- `security/vulnerability-patch` (Security hardening)

### Commit Message Format:
```text
feat(sos): add atomic lock to prevent stuck countdown timers
fix(contacts): resolve priority sorting for primary guardian badge
docs(readme): update manual setup steps for Android Kotlin DSL
security(secrets): prevent accidental commit of google-services.json
```

---

## 📬 Pull Request Process

1. Create a descriptive PR title following conventional commit rules.
2. In the PR description, explain:
   - What problem does this solve?
   - How was it tested (emulator, physical device)?
   - Any visual changes (attach screenshots or screen recordings).
3. Ensure all CI/CD pipeline checks pass.
4. I will personally review your PR within 48–72 hours.

---

## 💬 Community & Questions

If you have questions, ideas, or need guidance on contributing, feel free to reach out to the sole creator and lead maintainer:
- **Sole Creator & Lead Architect**: Aman Kanojiya
- **GitHub**: [@codedbyamankanojiya](https://github.com/codedbyamankanojiya)
- **Portfolio**: [codedbyamankanojiya.vercel.app](https://codedbyamankanojiya.vercel.app)
- **LinkedIn**: [Aman Kanojiya](https://www.linkedin.com/in/aman-kanojiya-7386822b0)
- **Twitter (X)**: [@AKnj08](https://x.com/AKnj08)

Thank you for contributing to women's safety! 🌸

