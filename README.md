# 🛡️ Nirbhaya - Women's Safety & Emergency Assistance Platform

<div align="center">

![Safety First](https://img.shields.io/badge/Safety-First-red?style=for-the-badge)
![Next.js](https://img.shields.io/badge/Next.js-15.5.9-black?style=for-the-badge&logo=next.js)
![React](https://img.shields.io/badge/React-19.2.1-61DAFB?style=for-the-badge&logo=react)
![TypeScript](https://img.shields.io/badge/TypeScript-5.7.3-3178C6?style=for-the-badge&logo=typescript)
![NestJS](https://img.shields.io/badge/NestJS-11.0.1-E0234E?style=for-the-badge&logo=nestjs)
![Prisma](https://img.shields.io/badge/Prisma-7.8.0-2D3748?style=for-the-badge&logo=prisma)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-4169E1?style=for-the-badge&logo=postgresql)

**A comprehensive, mobile-first women's safety application featuring a one-tap SOS button, smart fake call de-escalation, emergency contact dialing, and real-time distress assistance.**

[Overview](#-overview) • [Key Features](#-key-features) • [Tech Stack](#-tech-stack) • [Architecture](#-architecture) • [Environment Setup](#-environment-variables) • [Local Running Guide](#-local-running-guide) • [Vercel Deployment](#-vercel-deployment)

</div>

---

## 📖 Overview

**Nirbhaya** is a modern, mobile-first women's safety application designed for real-world personal protection, instant emergency response, and community risk awareness. Framed inside an interactive smartphone UI emulator, it delivers an authentic mobile experience on web browsers.

The system is engineered as a monorepo consisting of:
1. **Frontend (`frontend/`)**: Next.js 15 web application with React 19, Tailwind CSS, shadcn/ui components, `AuthContext` with JWT session restoration, interactive safety profile manager, and emergency dialing interface.
2. **Backend (`backend/`)**: NestJS 11 REST API with Prisma 7.8.0 ORM (`@prisma/adapter-pg`), PostgreSQL database, JWT authentication, bcrypt password hashing, Multer Cloudinary media uploads, and Swagger API documentation.

---

## ✨ Key Features

### 👤 **Interactive Safety Profile & Medical Information**
- **Personal Details Manager**: Edit Full Name, Emergency Phone, Contact Email, Address, DOB, and Gender.
- **Medical Emergency Profile**: Store Blood Group, Known Allergies, Medical Conditions, and Special Instructions for paramedics.
- **Hybrid Persistence**: Instant local storage fallback for offline device use + cloud synchronization with NestJS backend (`/api/v1/profile`).

### 👥 **Emergency Contacts & Smart Dialing**
- **Contact Management**: Add, edit, and delete emergency contacts with custom relationship tags (*Family, Friend, Guardian, Emergency Services, Doctor, Neighbor*).
- **Outward Dialing Simulation**: One-tap phone icon triggers an emergency call screen layout with custom contact avatars.
- **REST API Sync**: Direct integration with `/api/v1/contacts` database endpoints.

### 🔐 **Authentication & Session Security**
- **JWT Auth Flow**: Registration and Login dialogs supporting password visibility toggles, form validation, and toast notifications.
- **Token Rotation**: Automatic access token refresh using HTTP 401 interceptors.
- **Guest / Preview Mode**: Explicit indicators when running unauthenticated with seamless transition to cloud mode upon sign-in.

### 📞 **Smart Fake Call De-escalation**
- **Instant Fake Call**: Simulates a realistic incoming call to help exit uncomfortable or unsafe situations discreetly.
- **Interactive UI**: Accept, decline, or talk through a simulated call interface.

---

## 🛠️ Tech Stack & Dependencies

| Component | Technology | Version |
| :--- | :--- | :--- |
| **Frontend Framework** | Next.js (App Router) | `15.5.9` |
| **UI Library** | React | `19.2.1` |
| **Styling** | Tailwind CSS & shadcn/ui (Radix UI) | `3.4.1` |
| **Icons** | Lucide React | `0.475.0` |
| **Theme** | next-themes (Dark mode optimized) | `0.4.0` |
| **Backend Framework** | NestJS | `11.0.1` |
| **Database ORM** | Prisma 7 (with `@prisma/adapter-pg`) | `7.8.0` |
| **Database** | PostgreSQL | `14+` |
| **Authentication** | Passport.js & JWT (`@nestjs/jwt`) | `11.0.2` |
| **Password Hashing** | bcryptjs | `3.0.3` |
| **File Storage** | Cloudinary & Multer | `1.41.3` |

---

## 🏗️ System Architecture

```mermaid
graph TD
    subgraph Frontend [Next.js Client — Port 3001]
        UI[App Shell / Mobile Frame]
        AuthContext[Auth Context / Session Restore]
        ApiClient[API Client / Fetch Interceptor]
    end

    subgraph Backend [NestJS Server — Port 3000]
        AuthCtrl[Auth Controller /api/v1/auth]
        ProfileCtrl[Profile Controller /api/v1/profile]
        ContactsCtrl[Contacts Controller /api/v1/contacts]
        SosCtrl[SOS Controller /api/v1/sos]
        IncidentsCtrl[Incidents Controller /api/v1/incidents]
        UploadsCtrl[Uploads Controller /api/v1/uploads]
        PrismaService[Prisma Service with PrismaPg Adapter]
    end

    subgraph Persistence [Cloud Storage & Database]
        PrismaService -->|pg Pool Connection| Postgres[(PostgreSQL Database: nirbhaya)]
        UploadsCtrl -->|Media Storage| Cloudinary[Cloudinary API]
    end

    UI --> AuthContext
    AuthContext --> ApiClient
    ApiClient -->|REST HTTP Requests| AuthCtrl
    ApiClient -->|REST HTTP Requests| ProfileCtrl
    ApiClient -->|REST HTTP Requests| ContactsCtrl
```

---

## 📁 Repository Structure

```
nirbhaya/
├── frontend/                     # Next.js 15 Client Application
│   ├── src/
│   │   ├── app/                  # App Router & page wrappers
│   │   ├── components/app/       # Mobile app screens & auth modals
│   │   ├── context/              # AuthContext provider
│   │   ├── lib/                  # api.ts client & utilities
│   │   └── ai/                   # Genkit AI flow definitions
│   ├── .env.example              # Frontend environment template
│   ├── vercel.json               # Vercel deployment configuration
│   └── package.json              # Client scripts (dev: port 3001)
│
├── backend/                      # NestJS 11 Server Application
│   ├── src/
│   │   ├── modules/              # Auth, profile, contacts, sos, uploads modules
│   │   ├── database/             # PrismaService with PrismaPg pool adapter
│   │   ├── config/               # Application configuration
│   │   └── main.ts               # NestJS bootstrap & CORS settings
│   ├── prisma/
│   │   ├── schema.prisma         # Prisma database schema
│   │   └── migrations/           # PostgreSQL migration SQL files
│   ├── .env.example              # Backend environment template
│   └── package.json              # Server scripts (start: port 3000)
│
└── README.md                     # Comprehensive project documentation
```

---

## 🔑 Environment Variables Guide

Before running locally or deploying, populate the `.env` files using these templates:

### 1. Backend (`backend/.env`)

Create `backend/.env` from `backend/.env.example`:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# PostgreSQL Connection String (Prisma 7)
DATABASE_URL="postgresql://postgres:Ammy%40123@localhost:5432/nirbhaya?schema=public"

# JWT Secret Keys
JWT_ACCESS_SECRET="your-super-secret-access-token-key"
JWT_REFRESH_SECRET="your-super-secret-refresh-token-key"
JWT_ACCESS_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"

# Cloudinary Credentials (Evidence Uploads)
CLOUDINARY_CLOUD_NAME="your-cloudinary-cloud-name"
CLOUDINARY_API_KEY="your-cloudinary-api-key"
CLOUDINARY_API_SECRET="your-cloudinary-api-secret"

# Email SMTP Settings (Nodemailer Verification & Reset)
SMTP_HOST="smtp.example.com"
SMTP_PORT=587
SMTP_USER="your-email@example.com"
SMTP_PASS="your-email-password"
EMAIL_FROM="noreply@nirbhaya.com"

# Allowed CORS Origins (Frontend dev server on port 3001)
CORS_ORIGIN="http://localhost:3001"

# Throttler Rate Limiting
THROTTLE_TTL=60
THROTTLE_LIMIT=100
```

### 2. Frontend (`frontend/.env.local`)

Create `frontend/.env.local` from `frontend/.env.example`:

```env
# NestJS Backend API Base URL
NEXT_PUBLIC_API_URL=http://localhost:3000

# Google Gemini / Genkit AI Key (Optional for AI features)
GOOGLE_GENAI_API_KEY=your-google-gemini-api-key-here
```

---

## 🚀 Local Running Guide

To run both backend and frontend locally without port collisions:

### Step 1: Start Backend (Terminal 1)
```bash
cd backend
npm install
npx prisma generate
npm start
```
- **Backend API**: [http://localhost:3000](http://localhost:3000)
- **Swagger Documentation**: [http://localhost:3000/api/docs](http://localhost:3000/api/docs)

### Step 2: Start Frontend (Terminal 2)
```bash
cd frontend
npm install
npm run dev
```
- **Frontend Web App**: [http://localhost:3001](http://localhost:3001)

---

## ☁️ Vercel Deployment (Showcase)

To deploy the frontend to Vercel:

1. Import the repository on [Vercel](https://vercel.com).
2. Set **Root Directory** to `frontend`.
3. Add Environment Variable:
   - `NEXT_PUBLIC_API_URL`: URL of your deployed NestJS backend API.
4. Deploy! Vercel automatically uses `frontend/vercel.json` and builds Next.js.

---

## 👨‍💻 Developer & Author

**Aman Kanojiya**
- **GitHub**: [@codedbyamankanojiya](https://github.com/codedbyamankanojiya)
- **LinkedIn**: [Aman Kanojiya](https://www.linkedin.com/in/aman-kanojiya-7386822b0)
- **Email**: aman.knj2006@gmail.com

---

<div align="center">

**Built for Women's Security & Empowerment (Nirbhaya)**

</div>
