# ⚙️ Nirbhaya Backend API

NestJS 11 REST API server for the Nirbhaya Women's Safety Platform.

## 🛠 Tech Stack
- **Framework**: NestJS 11.0.1
- **Database**: PostgreSQL 14+ with Prisma 7.8.0 ORM (`@prisma/adapter-pg`)
- **Auth**: JWT (Access & Refresh tokens) & bcryptjs
- **Media**: Cloudinary API with Multer
- **Docs**: Swagger OpenAPI (`/api/docs`)

## 🔑 Environment Setup
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

## 🚀 Running Server Locally
```bash
# 1. Install dependencies
npm install

# 2. Generate Prisma Client
npx prisma generate

# 3. Run database migrations
npx prisma migrate dev

# 4. Start NestJS server
npm start
```

Server runs on: `http://localhost:3000`  
Swagger API Docs: `http://localhost:3000/api/docs`
