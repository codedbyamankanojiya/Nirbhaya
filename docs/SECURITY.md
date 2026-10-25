# 🛡️ Security Policy — Nirbhaya Women's Safety & Emergency Assistance

Nirbhaya is an independent, production-grade safety platform designed, architected, and developed individually and solely by **Aman Kanojiya**. 

As the sole creator and developer of Nirbhaya, user safety, physical security, and digital privacy are my absolute top priorities. Because this platform is designed for life-critical emergency distress situations, I enforce strict cryptographic standards, privacy safeguards, and a zero-leak secrets policy across all codebases.

---

## 🔒 Supported Versions

Active security updates, vulnerability patches, and emergency fixes are provided for the following releases:

| Version | Supported | Status |
| :--- | :---: | :--- |
| `1.0.x` | ✅ | Active Production Release |
| `< 1.0.0` | ❌ | Deprecated / Beta Pre-release |

---

## 🚨 Reporting a Vulnerability

If you discover a security vulnerability, credential leak, or critical privacy flaw within the Nirbhaya application or backend services, please **DO NOT open a public GitHub issue**. Public disclosure may jeopardize the safety of users in crisis.

### How to Report Privately:
1. **GitHub Security Advisories (Preferred)**: Navigate to the repository's **Security** tab $\rightarrow$ **Advisories** $\rightarrow$ Click **Report a vulnerability**.
2. **Direct to Sole Creator & Lead Developer**: Contact **Aman Kanojiya**:
   - GitHub: [@codedbyamankanojiya](https://github.com/codedbyamankanojiya)
   - Portfolio: [codedbyamankanojiya.vercel.app](https://codedbyamankanojiya.vercel.app)
   - LinkedIn: [Aman Kanojiya](https://www.linkedin.com/in/aman-kanojiya-7386822b0)
   - Twitter (X): [@AKnj08](https://x.com/AKnj08)
   - Email: `security@nirbhaya.org`

### Please Include in Your Report:
- A detailed description of the vulnerability.
- Steps or a minimal Proof of Concept (PoC) to reproduce the issue safely.
- The affected component (e.g. SOS state machine, Keystore token storage, Firestore sync, Live GPS stream).
- The potential impact on user safety or personal privacy.

### Response Timeline:
- **Initial Acknowledgment**: Within **24 hours**.
- **Impact Assessment & Triage**: Within **48 hours**.
- **Fix Deployment & Patch Release**: Within **3 to 7 business days** (critical emergency vulnerabilities are patched immediately).

---

## 🔐 Core Security & Privacy Architecture

The Nirbhaya application is engineered under the **Defense-in-Depth** security philosophy:

### 1. Hardware Keystore Token Storage
- All session JWTs, recovery tokens, biometric keys, and safety PIN codes are stored inside the **Android Keystore / iOS Keychain** via `flutter_secure_storage`.
- On Android, data is encrypted at rest using **AES-256 GCM** backed by hardware-backed Trusted Execution Environments (TEE) or StrongBox Keymaster.

### 2. Zero-Leak Credential & Key Isolation
- **No API keys or cloud credentials are hardcoded into the Git-tracked Dart source files.**
- Google Gemini AI keys are injected via compile-time variables (`--dart-define=GEMINI_API_KEY=...`) or entered by users in local device storage.
- Firebase project configuration files (`google-services.json`, `GoogleService-Info.plist`, and `firebase_options.dart`) are explicitly listed in `.gitignore`.
- Dummy templates (`.env.example`, `google-services.json.example`) are provided for contributors so private production keys are never checked into public version control.

### 3. Local Hardware-First Fail-safe
- During an active emergency SOS trigger, the app **never blocks on cloud network round-trips**.
- Hardware sirens, LED strobe lights, phone dialers (112, 1091), SMS dispatches, and local GPS logging fire **synchronously on the device**.
- Cloud Firestore and backend REST synchronization run asynchronously with SQLite offline persistence; if cell signal is jammed or lost, writes are cached securely on the device and sync automatically once connectivity is restored.

### 4. Covert Evidence & Media Vault Privacy
- Audio recordings, photo captures, and video evidence taken via the Evidence Studio are saved to the app's sandboxed private storage directory (`Context.getFilesDir()`).
- Media files are not accessible by third-party gallery apps or malicious applications without root authorization.
- Covert recording mode includes an OLED Blackout Screen to prevent attackers from noticing active audio surveillance.

### 5. Transport Layer Security (TLS)
- All network communication with Google Gemini AI and Firebase Firestore requires **TLS 1.3 / HTTPS** with certificate validation.
- Unencrypted HTTP cleartext traffic is disabled in production builds.

---

## 🛡️ Best Practices for Contributors & Deployers

When deploying or contributing to Nirbhaya:
1. **Never commit `.env` or keystores**: Ensure your `.env`, `key.properties`, and `*.keystore` files remain strictly local.
2. **Review Git Staging**: Always verify your staged files before committing:
   ```bash
   git status
   git diff --staged
   ```
3. **Use Environment Variables in CI/CD**: When setting up GitHub Actions or automated build pipelines, store all signing keys and API tokens in **GitHub Repository Secrets**.

Thank you for helping keep women safe and protecting the privacy of the community!

