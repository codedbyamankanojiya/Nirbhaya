# 🌐 Nirbhaya: Real-World Manual Setup & Cloud Integration Guide

This guide provides step-by-step instructions for all external services, cloud integrations, and credentials required to deploy the **Nirbhaya Women's Safety App** — conceptualized, designed, and developed solely by **Aman Kanojiya** — in production with a strict **Zero-Leak Policy** for secrets and credentials.

---

## 📋 Table of Contents
1. [Zero-Leak Security Checklist](#1-zero-leak-security-checklist)
2. [Google Gemini AI API (Conversational Safety Intelligence)](#2-google-gemini-ai-api)
3. [Firebase Integration (Cloud Firestore & Auth)](#3-firebase-integration)
4. [Testing on a Physical Android Smartphone](#4-testing-on-a-physical-android-smartphone)
5. [Publishing to Google Play Store](#5-publishing-to-google-play-store)

---

## 1. Zero-Leak Security Checklist

Before pushing any changes to a public or private GitHub repository, ensure the following files are **NEVER committed**:

| File / Folder | Purpose | Ignored by `.gitignore`? |
| :--- | :--- | :---: |
| `.env` | Local developer secrets & host URLs | ✅ Yes |
| `android/app/google-services.json` | Firebase Android configuration | ✅ Yes |
| `ios/Runner/GoogleService-Info.plist` | Firebase iOS configuration | ✅ Yes |
| `lib/firebase_options.dart` | Generated Firebase client credentials | ✅ Yes |
| `*.jks` / `*.keystore` | Android release signing keys | ✅ Yes |
| `key.properties` | Keystore password credentials | ✅ Yes |
| `.vscode/` | Local launch arguments with keys | ✅ Yes |

> [!IMPORTANT]
> The repository includes safe templates with dummy placeholders for all sensitive files:
> - `.env.example`
> - `android/app/google-services.json.example`
> - `lib/firebase_options.dart.example`

---

## 2. Google Gemini AI API

Nirbhaya includes an intelligent AI Safety Assistant with an extensive offline fallback engine. To enable live conversational AI answers powered by Google's fast **Gemini 1.5 Flash** model:

### Step-by-Step Setup:
1. Navigate to **[Google AI Studio](https://aistudio.google.com/)**.
2. Sign in with your Google Account.
3. Click **"Get API key"** in the top left corner.
4. Click **"Create API key in new project"** (100% free with generous rate limits, no credit card required).
5. Copy your generated API key (`AQ...` or `AIzaSy...`).

### How to Connect to Nirbhaya:
- **Option A (Instant In-App — Recommended)**: 
  Open Nirbhaya $\rightarrow$ Tap **Settings** (gear icon) $\rightarrow$ Scroll to **Connectivity & AI** $\rightarrow$ Tap **Google Gemini AI Key** $\rightarrow$ Paste key and tap **Save**.
- **Option B (Launch Argument / CI/CD)**:
  Run or build with `--dart-define`:
  ```bash
  flutter run --dart-define=GEMINI_API_KEY=YOUR_GEMINI_KEY
  ```
- **Option C (Local `.env` file)**:
  Add to your local `.env` file:
  ```env
  GEMINI_API_KEY="YOUR_GEMINI_KEY"
  ```

---

## 3. Firebase Integration

Firebase provides cloud synchronization for Emergency SOS distress signals, emergency contacts, and personal medical cards.

### Step-by-Step Setup:
1. Open the **[Firebase Console](https://console.firebase.google.com/)**.
2. Click **"Add project"** and name it (e.g., `nirbhaya-v2`).
3. Under **Build $\rightarrow$ Firestore Database**, click **Create Database** and choose location `asia-south1 (Mumbai)`.
4. Under **Build $\rightarrow$ Authentication**, click **Get Started** and enable **Email/Password** and **Anonymous** sign-in methods.

### Automated Setup via FlutterFire CLI (Fastest):
```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```
Select your project (`nirbhaya-v2`) and platforms (`android`). The CLI will automatically download and place `google-services.json` and generate `firebase_options.dart`.

### Manual Setup:
1. In Firebase Console, go to ⚙️ **Project settings** $\rightarrow$ Click **Add App** (Android).
2. Package Name:
   ```text
   com.nirbhaya.nirbhaya
   ```
3. Download `google-services.json` and place it inside:
   ```text
   android/app/google-services.json
   ```
4. Verify Kotlin DSL Gradle configurations:
   - In [`android/settings.gradle.kts`](file:///d:/Projects/Android/Flutter%20Projects/Nirbhaya/android/settings.gradle.kts):
     ```kotlin
     plugins {
         id("com.google.gms.google-services") version "4.4.2" apply false
     }
     ```
   - In [`android/app/build.gradle.kts`](file:///d:/Projects/Android/Flutter%20Projects/Nirbhaya/android/app/build.gradle.kts):
     ```kotlin
     plugins {
         id("com.google.gms.google-services")
     }
     ```

---

## 4. Testing on a Physical Android Smartphone

To test all real-world hardware sensors (accelerometer, real cellular phone calls, SMS intents, GPS antenna, flashlight, vibrations):

### Step 1: Enable USB Debugging
1. On your Android phone, go to **Settings** $\rightarrow$ **About Phone** $\rightarrow$ Tap **Build Number** 7 times.
2. Go to **Settings** $\rightarrow$ **System** $\rightarrow$ **Developer Options** $\rightarrow$ Enable **USB Debugging**.
3. Connect your phone via USB cable and select **Allow USB Debugging** on the phone screen.

### Step 2: Run the App
```bash
flutter devices
flutter run -d <your_device_id>
```

---

## 5. Publishing to Google Play Store

### Step 1: Generate an Upload Keystore
Run in PowerShell:
```powershell
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Step 2: Configure `android/key.properties`
Create `android/key.properties` (never commit this file to Git):
```properties
storePassword=YourKeystorePassword
keyPassword=YourKeyPassword
keyAlias=upload
storeFile=../upload-keystore.jks
```

### Step 3: Build Production Android App Bundle (AAB)
```bash
flutter build appbundle --release
```
The production bundle will be generated at:
```text
build/app/outputs/bundle/release/app-release.aab
```

### Step 4: Upload to Google Play Console
1. Log in to **[Google Play Console](https://play.google.com/console)**.
2. Create an App named **Nirbhaya**.
3. Complete the Safety declaration (declaration for SMS and Location in foreground/background).
4. Upload `app-release.aab` under Internal Testing or Production, and submit for review.

---

## 👨‍💻 Sole Creator & Support

Solely Designed, Architected, and Developed by **Aman Kanojiya**:
- 🌐 **Portfolio**: [codedbyamankanojiya.vercel.app](https://codedbyamankanojiya.vercel.app)
- 🐙 **GitHub**: [@codedbyamankanojiya](https://github.com/codedbyamankanojiya)
- 💼 **LinkedIn**: [Aman Kanojiya](https://www.linkedin.com/in/aman-kanojiya-7386822b0)
- 🐦 **Twitter (X)**: [@AKnj08](https://x.com/AKnj08)
