# 🌐 Nirbhaya: Real-World Manual Setup & Cloud Integration Guide

This guide provides step-by-step instructions for all external services, cloud integrations, and credentials required to deploy the **Nirbhaya Women's Safety App** in production.

---

## 📋 Table of Contents
1. [Google Gemini AI API (Conversational Safety Intelligence)](#1-google-gemini-ai-api)
2. [Firebase Integration (FCM Push Notifications & Cloud Messaging)](#2-firebase-integration)
3. [Cloudinary Setup (Encrypted Evidence Photo/Media Storage)](#3-cloudinary-setup)
4. [Backend REST API & PostgreSQL Database Deployment](#4-backend-rest-api--postgresql-deployment)
5. [Testing on a Physical Android Smartphone](#5-testing-on-a-physical-android-smartphone)
6. [Publishing to Google Play Store](#6-publishing-to-google-play-store)

---

## 1. Google Gemini AI API

Nirbhaya includes an intelligent AI Safety Assistant with an extensive offline fallback engine. To enable live conversational AI answers powered by Google's latest Gemini models:

### Step-by-Step Setup:
1. Navigate to **[Google AI Studio](https://aistudio.google.com/)**.
2. Sign in with your Google Account.
3. Click **"Get API key"** in the top left corner.
4. Click **"Create API key in new project"** (This is 100% free with generous rate limits, no billing or credit card required).
5. Copy your generated API key (e.g., `AIzaSy...`).

### How to Connect to Nirbhaya:
- **Option A (Instant in-app)**: Open Nirbhaya -> Tap **Settings** (gear icon) -> Scroll to **Connectivity & AI** -> Tap **Google Gemini AI Key** -> Paste your key and tap **Save**.
- **Option B (Environment default)**: Add to your environment or `.env`:
  ```bash
  GEMINI_API_KEY="AIzaSyYourGeneratedKeyHere"
  ```

---

## 2. Firebase Integration

Firebase is used to deliver real-time emergency push alerts and cloud notifications when an SOS is dispatched.

### Step-by-Step Setup:
1. Open the **[Firebase Console](https://console.firebase.google.com/)**.
2. Click **"Add project"** and name it `Nirbhaya` (or your preferred name).
3. Disable Google Analytics (optional) and click **Create Project**.

### Register the Android Application:
4. In your project overview, click the **Android** icon (`</>`) to add an Android app.
5. Enter the Package Name:
   ```
   com.nirbhaya.nirbhaya
   ```
6. (Optional) Enter App Nickname: `Nirbhaya Safety`.
7. Retrieve your machine's SHA-1 and SHA-256 fingerprints by running in terminal:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the `SHA1` and `SHA-256` under the `debug` variant and paste them into Firebase.
8. Click **Register App**.
9. Download **`google-services.json`** and place the file directly inside:
   ```
   nirbhaya/android/app/google-services.json
   ```

### Register the iOS Application (Optional for iPhone):
1. In Firebase Console, click **Add App** -> **iOS**.
2. Enter the Bundle Identifier: `com.nirbhaya.nirbhaya`.
3. Download **`GoogleService-Info.plist`** and place it inside:
   ```
   nirbhaya/ios/Runner/GoogleService-Info.plist
   ```

---

## 3. Cloudinary Setup

Cloudinary is used by the backend to securely store encrypted evidence photographs taken via the **Record Evidence** tool or attached to incident reports.

### Step-by-Step Setup:
1. Sign up for a free account at **[Cloudinary](https://cloudinary.com/)**.
2. On your Cloudinary Dashboard, locate:
   - **Cloud Name** (e.g. `dxy7abcde`)
   - **API Key** (e.g. `123456789012345`)
   - **API Secret** (e.g. `abCdEfGhIjKlMnOpQrStUvWxYz`)
3. Open your companion backend `.env` file (in `backend/.env`) and add:
   ```env
   CLOUDINARY_CLOUD_NAME="your_cloud_name"
   CLOUDINARY_API_KEY="your_api_key"
   CLOUDINARY_API_SECRET="your_api_secret"
   ```

---

## 4. Backend REST API & PostgreSQL Deployment

The companion NestJS backend is located in `D:\Projects\Next.js Projects\Nirbhaya\backend`.

### Free Cloud Deployment Options:

#### Option A: Deploy on [Railway.app](https://railway.app/) (Recommended)
1. Push your backend code to a private GitHub repository.
2. Sign in to Railway and click **New Project** -> **Provision PostgreSQL**.
3. Railway instantly creates a cloud PostgreSQL database and provides a `DATABASE_URL`.
4. Click **New** -> **GitHub Repo** -> Select your backend repository.
5. In the backend settings, set the Environment Variables:
   ```env
   DATABASE_URL=${{Postgres.DATABASE_URL}}
   JWT_SECRET="generate-a-strong-random-32-char-secret"
   JWT_REFRESH_SECRET="generate-another-strong-secret"
   PORT=3000
   NODE_ENV=production
   CLOUDINARY_CLOUD_NAME="..."
   CLOUDINARY_API_KEY="..."
   CLOUDINARY_API_SECRET="..."
   ```
6. Railway automatically runs `prisma migrate deploy` and starts `npm run start:prod`.
7. Copy the public Railway URL (e.g. `https://nirbhaya-production.up.railway.app`).

#### Option B: Deploy on [Render.com](https://render.com/)
1. Create a free **PostgreSQL Database** on Render.
2. Create a free **Web Service**, link your GitHub repo, set Build Command to `npm install && npm run build` and Start Command to `npm run start:prod`.
3. Copy the Render URL (e.g. `https://nirbhaya-api.onrender.com`).

### Connecting the App to your Cloud Backend:
- In the Nirbhaya mobile app:
  - Go to **Settings** -> **Backend API Server**
  - Enter your production URL: `https://nirbhaya-production.up.railway.app`
  - Tap **Save**. All network requests will instantly connect to your live cloud server!

---

## 5. Testing on a Physical Android Smartphone

To test all hardware features (real phone calls, native SMS dispatch, GPS antenna, accelerometer, vibration) on your actual smartphone:

### Step 1: Connect your phone to your computer
1. On your Android phone, enable **Developer Options**:
   - Go to **Settings** -> **About Phone** -> Tap **Build Number** 7 times.
2. Go to **Settings** -> **System** -> **Developer Options** -> Turn ON **USB Debugging**.
3. Connect your phone via USB cable and allow USB debugging when prompted on the screen.

### Step 2: Configure Local Network Access
1. Make sure your phone and your development computer are connected to the **same Wi-Fi network**.
2. Find your computer's local IP address by running in terminal:
   ```powershell
   ipconfig
   ```
   Look for `IPv4 Address` under your active Wi-Fi adapter (e.g. `192.168.1.15`).
3. Run the app on your physical phone:
   ```bash
   flutter run -d <your_phone_device_id> --dart-define=API_BASE_URL=http://192.168.1.15:3000
   ```
   *(Or change the Server URL directly inside Nirbhaya's in-app Settings screen).*

---

## 6. Publishing to Google Play Store

### 1. Generate an Upload Keystore:
Run the keytool command in terminal:
```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Configure `android/key.properties`:
Create `android/key.properties` (never commit this file to public git):
```properties
storePassword=YourKeystorePassword
keyPassword=YourKeyPassword
keyAlias=upload
storeFile=../upload-keystore.jks
```

### 3. Build the Production Android App Bundle:
```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-production-api.com
```
Your release bundle will be generated at:
```
build/app/outputs/bundle/release/app-release.aab
```

### 4. Upload to Google Play Console:
1. Log in to **[Google Play Console](https://play.google.com/console)**.
2. Create an App named **Nirbhaya**.
3. Under **Production** or **Internal Testing**, create a new release and upload `app-release.aab`.
4. Submit for review!

