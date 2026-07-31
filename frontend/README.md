# 📱 Nirbhaya Frontend Web Application

Next.js 15 web application for the Nirbhaya Women's Safety Platform.

## 🛠 Tech Stack
- **Framework**: Next.js 15.5.9 (App Router) & React 19.2.1
- **Styling**: Tailwind CSS & shadcn/ui (Radix UI)
- **Icons**: Lucide React
- **AI**: Google Genkit 1.20 & Gemini 2.5 Flash

## 🔑 Environment Setup
Copy `.env.example` to `.env.local`:
```bash
cp .env.example .env.local
```

```env
NEXT_PUBLIC_API_URL=http://localhost:3000
GOOGLE_GENAI_API_KEY=your-google-gemini-api-key
```

## 🚀 Running Client Locally
```bash
# 1. Install dependencies
npm install

# 2. Start dev server
npm run dev
```

App runs on: `http://localhost:3001`

## ☁️ Vercel Deployment
1. Set **Root Directory** to `frontend` in Vercel.
2. Add `NEXT_PUBLIC_API_URL` environment variable pointing to your backend URL.
3. Deploy!
