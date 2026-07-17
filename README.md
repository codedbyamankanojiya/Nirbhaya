# 🛡️ Nirbhaya - Women's Safety & Emergency Assistance Platform

<div align="center">

![Nirbhaya Banner](https://img.shields.io/badge/Safety-First-red?style=for-the-badge)
![Next.js](https://img.shields.io/badge/Next.js-15.5.9-black?style=for-the-badge&logo=next.js)
![React](https://img.shields.io/badge/React-19.2.1-61DAFB?style=for-the-badge&logo=react)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-3178C6?style=for-the-badge&logo=typescript)
![NestJS](https://img.shields.io/badge/NestJS-11.0.1-E0234E?style=for-the-badge&logo=nestjs)
![Prisma](https://img.shields.io/badge/Prisma-7.8.0-2D3748?style=for-the-badge&logo=prisma)
![AI Powered](https://img.shields.io/badge/AI-Powered-purple?style=for-the-badge)

**A comprehensive, full-stack women's safety and real-time emergency assistance application**

[Features](#-features) • [Tech Stack](#-tech-stack) • [Architecture](#-architecture) • [Project State](#-project-state) • [Roadmap](#-remaining-roadmap) • [Installation](#-installation-and-setup) • [Usage](#-usage-and-workflows)

</div>

---

## 📖 Overview

**Nirbhaya** is a cutting-edge, mobile-first safety platform designed to provide proactive and responsive security solutions for women. Featuring an authentic smartphone frame mockup (Samsung Galaxy S25+ 5G style), it delivers an immersive personal safety application experience.

The platform is designed in two primary components:
1. **Frontend**: A Next.js 15 mobile-first web app integrating Google Genkit AI and Gemini 2.5 Flash for contextual safety coaching, crime hotspot mapping, and voice/motion distress analysis.
2. **Backend**: A NestJS 11 server utilizing a PostgreSQL database with Prisma ORM for JWT session management, emergency contacts, incident logs, secure media uploads, and real-time event notifications.

### 🎯 Mission

To empower women with technology-driven safety tools that provide peace of mind, instant emergency response capabilities, and intelligent safety insights.

---

## ✨ Features

### 🆘 **Emergency SOS Trigger**
- **One-Tap SOS Button**: Highlighted with interactive pulse animations.
- **Confirmation dialog**: Prevents accidental triggers.
- **Broadcast System**: Designed to send instant alerts and live coordinates to emergency guardians and local authorities.

### 📞 **Samsung S25+ Smart Call Emulator**
- **Fake Call**: Instantly simulates a highly realistic incoming phone call to de-escalate unsafe situations.
- **Discreet Call Interface**: Standard dialing screens for all emergency contacts.
- **Outgoing & Incoming modes**: Dynamic layouts with user-customized avatars.

### 🗺️ **Community Safety Map & Hotspots**
- **AI Crime Heatmaps**: Highlights high-risk areas based on time of day.
- **Safe Route Suggestions**: Recommends optimized paths considering lighting scores, crowd densities, and police box proximity.
- Powered by Google Genkit AI for real-time safety mapping.

### 🤖 **AI Safety Coach / Assistant**
- Conversational chat interface for immediate, contextual safety tips.
- Factors in user's current location, local time of day, and recent crime trends.
- Powered by Google Gemini.

### 👥 **Guardian Tracking & Resource Library**
- **Walking With Me**: Live location-sharing session for guardians.
- **Emergency Directory**: Quick dial for police, medical, and national hotlines.
- **Resources**: Self-defense tutorials, legal guides, and emergency guidelines.

---

## 🛠️ Tech Stack

### 📱 Frontend (Client)
- **Framework**: Next.js 15.5.9 (App Router) & React 19.2.1
- **Styling**: Tailwind CSS & shadcn/ui components (Radix UI primitives)
- **Icons**: Lucide React
- **Theme**: `next-themes` (Dark Mode optimized by default for discreet night use)

### ⚙️ Backend (Server)
- **Framework**: NestJS 11.0.1 (Node.js)
- **Database**: PostgreSQL with Prisma ORM 7.8.0
- **Auth**: JWT (Access & Refresh token rotation)
- **File Uploads**: Cloudinary API with `multer-storage-cloudinary`
- **Security & Rate Limiting**: Helmet & NestJS Throttler
- **Emails**: Nodemailer (SMTP transport)

### 🤖 AI Orchestration
- **Google Genkit 1.20.0**
- **@genkit-ai/google-genai** (Gemini 2.5 Flash model)

---

## 🏗️ Architecture

```mermaid
graph TD
    subgraph Frontend [Next.js Client (Port 9002)]
        UI[App Shell / Mobile mockup]
        GenkitClient[Genkit Server Actions]
        State[React State / Context]
    end

    subgraph AI Orchestration [Google Genkit]
        GenkitClient -->|Flow Trigger| Flows[AI Flows]
        Flows -->|Gemini API| Gemini[Gemini 2.5 Flash]
    end

    subgraph Backend [NestJS Server (Port 3000)]
        AuthCtrl[Auth Controller]
        SosCtrl[SOS Controller]
        ContactsCtrl[Contacts Controller]
        ProfileCtrl[Profile Controller]
        UploadsCtrl[Uploads Controller]
        DbService[Prisma Service]
    end

    subgraph Storage [Persistence & Cloud Services]
        DbService -->|SQL Query| Postgres[(PostgreSQL Database)]
        UploadsCtrl -->|Secure Save| Cloudinary[Cloudinary Storage]
    end

    UI -->|Interactive UI| State
    UI -.->|Pending Integration| AuthCtrl
    UI -.->|Pending Integration| SosCtrl
    UI -.->|Pending Integration| ContactsCtrl
    UI -.->|Pending Integration| ProfileCtrl
    UI -.->|Pending Integration| UploadsCtrl
```

---

## 📁 Folder Structure

```
nirbhaya/
├── frontend/                 # Frontend Next.js 15 application
│   ├── src/                  # App screens & Genkit flow definitions
│   │   ├── app/              # Router paths & theme provider
│   │   ├── components/       # UI & simulated device layouts
│   │   └── ai/               # Genkit & Gemini orchestration
│   ├── public/               # Static assets & illustrations
│   └── package.json          # Dependencies & startup scripts
│
├── backend/                  # Backend NestJS 11 application
│   ├── src/                  # REST controllers & services
│   │   ├── modules/          # Auth, SOS, contacts, uploads modules
│   │   └── database/         # Prisma Database Service configuration
│   ├── prisma/               # Database model & migration schemas
│   └── package.json          # Dependencies & build pipelines
│
└── README.md                 # Unified project documentation
```

---

## 🚦 Project State & Demo Mode

The project is currently in a **partially-integrated prototyping phase**:

1. **Frontend App Mockup**: The Next.js frontend is fully styled and responsive, simulating the phone UI using mock states (e.g. Priya Sharma profile, static contacts list, and fallback triggers).
2. **AI Flows (Genkit)**: Genkit server actions are fully configured and functional when a `GOOGLE_GENAI_API_KEY` is provided. If the AI service fails or times out, the screens automatically fall back to **Demo Mode** to show simulation data.
3. **Backend Service (NestJS)**: The backend contains modular REST controllers and database schemas. It is not yet connected to the Next.js client, meaning the frontend does not currently query or update the database.
4. **Distress Detection**: The Genkit distress detection flow (audio & sensor parsing) is implemented on the server but is not yet wired into the frontend UI.

---

## 📋 Remaining Roadmap (TODO)

To transform Nirbhaya from a high-fidelity prototype into a production-ready application, the following tasks remain:

- [ ] **Frontend-Backend API Binding**:
  - Replace client-side mock states in `profile-screen.tsx`, `tracking-screen.tsx`, and `home-screen.tsx` with actual `fetch` queries pointing to the NestJS API.
  - Implement Frontend SignUp/SignIn screens communicating with `/api/v1/auth`.
- [ ] **Live Location & WebSockets**:
  - Integrate Socket.io between NestJS (`notifications` module) and Next.js client.
  - Implement real-time coordinate broadcasts to guardians during a "Walking With Me" session.
- [ ] **Cloudinary Video Uploads**:
  - Upload captured evidence videos from `home-screen.tsx` directly to the `/api/v1/uploads` endpoint to store them securely.
- [ ] **Distress Detection UI integration**:
  - Wire the `detectDistress` flow to run via device microphone triggers or a "Simulate Incident" option.
- [ ] **Database Deployment**:
  - Launch a PostgreSQL server and run Prisma migrations to provision the schema tables.

---

## 🚀 Installation and Setup

### 1. Setup Database & Backend

1. Navigate to the `backend` directory:
   ```bash
   cd backend
   ```
2. Install NestJS dependencies:
   ```bash
   npm install
   ```
3. Set up your environment variables:
   Copy `.env.example` to `.env` and fill in the details:
   ```env
   PORT=3000
   DATABASE_URL="postgresql://username:password@localhost:5432/nirbhaya_db?schema=public"
   JWT_ACCESS_SECRET="your-access-secret"
   JWT_REFRESH_SECRET="your-refresh-secret"
   CLOUDINARY_CLOUD_NAME="your-cloudinary-name"
   CLOUDINARY_API_KEY="your-api-key"
   CLOUDINARY_API_SECRET="your-api-secret"
   ```
4. Run Prisma database migrations:
   ```bash
   npx prisma migrate dev --name init
   ```
5. Start the backend in development/watch mode:
   ```bash
   npm run start:dev
   ```
   *Swagger documentation will be available at [http://localhost:3000/api/docs](http://localhost:3000/api/docs).*

### 2. Setup Next.js Frontend

1. Navigate to the `frontend` directory:
   ```bash
   cd frontend
   ```
2. Install frontend dependencies:
   ```bash
   npm install
   ```
3. Create `.env.local` in the `frontend` folder:
   ```env
   # Google AI Key for Genkit
   GOOGLE_GENAI_API_KEY=your_gemini_api_key_here
   ```
4. Start the Next.js development server:
   ```bash
   npm run dev
   ```
5. Open [http://localhost:9002](http://localhost:9002) in your browser. Use the responsive layout (or browser responsive developer tools) to view the smartphone interface.

---

## 🔐 Security & Privacy

- **Data Privacy**: No user contact numbers or real-time location histories are exposed without active SOS/Walking mode session triggers.
- **Rate Limiting**: NestJS Throttler protects API endpoints against Denial of Service (DoS) and brute force login attempts.
- **Access Control**: JWT token verification (using HTTP header Bearer Authorization) secures all backend resources, with role-based policies (User vs Admin).

---

## 👨‍💻 Developer

**Aman Kanojiya**

- **GitHub**: [@codedbyamankanojiya](https://github.com/codedbyamankanojiya)
- **LinkedIn**: [Aman Kanojiya](https://www.linkedin.com/in/aman-kanojiya-7386822b0)
- **Email**: aman.knj2006@gmail.com

---

## 🙏 Acknowledgments

- **Google Genkit** for the streamlined AI flows.
- **shadcn** for beautiful UI building blocks.
- **NestJS** for the scalable backend design.

---

<div align="center">

**Made with ❤️ for Women's Safety (Our Mothers & Sisters)**

⭐ Star this repository if you find it helpful!

</div>
