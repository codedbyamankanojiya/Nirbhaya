# 🛡️ Nirbhaya - Women's Safety & Emergency Assistance Platform

<div align="center">

![Nirbhaya Banner](https://img.shields.io/badge/Safety-First-red?style=for-the-badge)
![Next.js](https://img.shields.io/badge/Next.js-15.5.9-black?style=for-the-badge&logo=next.js)
![React](https://img.shields.io/badge/React-19.2.1-61DAFB?style=for-the-badge&logo=react)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-3178C6?style=for-the-badge&logo=typescript)
![AI Powered](https://img.shields.io/badge/AI-Powered-purple?style=for-the-badge)

**A comprehensive women's safety and real-time emergency assistance application**

[Features](#-features) • [Tech Stack](#-tech-stack) • [Installation](#-installation) • [Usage](#-usage) • [Architecture](#-architecture)

</div>

---

## 📖 Overview

**Nirbhaya** is a cutting-edge, mobile-first web application designed to provide comprehensive safety solutions for women. Built as a proof-of-concept, it combines modern web technologies with AI-powered features to create a proactive and responsive personal safety tool.

The application leverages **Google's Genkit AI** with the **Gemini model** to provide intelligent safety recommendations, crime hotspot analysis, and real-time assistance. With a beautiful, intuitive interface built using **shadcn/ui** components and **Tailwind CSS**, Nirbhaya offers a seamless user experience within a simulated smartphone shell, emphasizing its mobile-first design philosophy.

### 🎯 Mission

To empower women with technology-driven safety tools that provide peace of mind, instant emergency response capabilities, and intelligent safety insights.

---

## ✨ Features

### 🚨 **Emergency SOS Button**
- **One-tap emergency alert** with animated visual feedback
- Instantly broadcasts alerts to emergency contacts and authorities
- Sends live location data to guardians
- Confirmation dialog to prevent accidental activation

### 📞 **Smart Call Interface**
- **Fake Call Feature**: Simulate incoming calls to de-escalate unsafe situations
- **Emergency Contact Calling**: Beautiful call interface for all contacts
- **Realistic call screen** with contact photos and Samsung Galaxy S25+ 5G branding
- **Outgoing/Incoming modes**: Different UI for calling vs receiving calls
- **Quick-access** from home screen and profile
- **Discreet exit strategy** tool

### 🗺️ **Community Safety Map**
- **AI-generated crime heatmaps** showing high-risk areas
- Real-time crime data visualization
- Safe route suggestions based on current location
- Interactive map with color-coded danger zones
- Powered by Google Genkit AI for intelligent analysis

### 🤖 **AI Safety Assistant**
- Conversational AI chatbot for real-time safety advice
- Context-aware recommendations based on:
  - Current location
  - Time of day
  - Recent crime data
- Powered by Google Gemini AI model
- Natural language interaction

### 👥 **Guardian Live Tracking**
- Share real-time location with trusted contacts
- Add/manage emergency contacts
- Live location updates
- Privacy controls for tracking duration

### 📚 **Safety Resources Library**
- Emergency helpline numbers
- Safety tips and guidelines
- Self-defense techniques
- Legal resources and rights information
- Educational content for awareness

### 👤 **User Profile & Settings**
- **Personalized dashboard** with actual user photo (Priya Sharma)
- **Emergency contact management** with real contact photos:
  - Police (priority emergency contact)
  - Family members (Mom, Dad, Brother)
  - Friends (Aisha Khan, Aman Kanojiya)
- **One-tap calling** with beautiful call interface
- **Medical information** (blood type, allergies, conditions)
- **Guardian management** for live location sharing
- **Theme customization** (Dark/Light mode)
- **Multi-language support** (English, Hindi, Tamil, Telugu, Gujarati)
- **Privacy and security settings**

---

## 🛠️ Tech Stack

### **Frontend Framework**
- **Next.js 15.5.9** - React framework with App Router for server-side rendering
- **React 19.2.1** - UI library with latest features
- **TypeScript 5.0** - Type-safe development

### **Styling & UI**
- **Tailwind CSS 3.4.1** - Utility-first CSS framework
- **shadcn/ui** - High-quality, accessible component library
- **Radix UI** - Unstyled, accessible UI primitives (18 components)
- **Lucide React** - Beautiful, consistent icon library
- **class-variance-authority** - Type-safe component variants
- **tailwind-merge** - Intelligent Tailwind class merging
- **tailwindcss-animate** - Animation utilities

### **AI & Intelligence**
- **Google Genkit 1.20.0** - AI orchestration framework
- **@genkit-ai/google-genai** - Google AI integration
- **@genkit-ai/next** - Next.js integration for Genkit
- **Gemini AI Model** - Advanced language model for safety insights

### **Forms & Validation**
- **React Hook Form 7.54.2** - Performant form management
- **Zod 3.24.2** - TypeScript-first schema validation
- **@hookform/resolvers** - Form validation resolvers

### **Data Visualization**
- **Recharts 2.15.1** - Composable charting library
- **D3.js** (via Recharts) - Data-driven visualizations

### **Additional Libraries**
- **Firebase 11.9.1** - Backend services and authentication
- **date-fns 3.6.0** - Modern date utility library
- **next-themes 0.4.0** - Theme management with system preference support
- **embla-carousel-react 8.6.0** - Lightweight carousel library

### **Development Tools**
- **Turbopack** - Ultra-fast bundler for Next.js
- **ESLint** - Code linting
- **PostCSS** - CSS processing
- **genkit-cli** - Genkit development tools

---

## 🚀 Installation

### Prerequisites

- **Node.js** 20.x or higher
- **npm** or **yarn** package manager
- **Git** for version control

### Step-by-Step Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/codedbyamankanojiya/nirbhaya.git
   cd nirbhaya
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   
   Create a `.env.local` file in the root directory:
   ```env
   # Google AI API Key
   GOOGLE_GENAI_API_KEY=your_google_ai_api_key_here
   
   # Firebase Configuration
   NEXT_PUBLIC_FIREBASE_API_KEY=your_firebase_api_key
   NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
   NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
   NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
   NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
   ```

4. **Run the development server**
   ```bash
   npm run dev
   ```

5. **Open your browser**
   
   Navigate to [http://localhost:9002](http://localhost:9002)

### Available Scripts

```bash
# Development server with Turbopack (port 9002)
npm run dev

# Production build
npm run build

# Start production server
npm start

# Run ESLint
npm run lint

# TypeScript type checking
npm run typecheck

# Genkit AI development server
npm run genkit:dev

# Genkit with watch mode
npm run genkit:watch
```

---

## 📱 Usage

### Getting Started

1. **Home Screen**: The main dashboard features a prominent SOS button for emergencies
2. **Navigation**: Use the bottom navigation bar to access different features
3. **Emergency Setup**: Add trusted contacts in the Profile section
4. **Explore Features**: Navigate through Map, AI Assistant, Tracking, and Resources

### Key Workflows

#### 🆘 Activating Emergency SOS
1. Press the animated SOS button on the home screen
2. Confirm the emergency alert in the dialog
3. Alert is sent to all emergency contacts with your live location
4. Authorities are notified automatically

#### 🗺️ Using Safety Map
1. Navigate to the Map screen
2. View AI-generated crime hotspots (red zones)
3. Check safe routes and recommendations
4. Plan your journey avoiding high-risk areas

#### 💬 Chatting with AI Assistant
1. Go to the AI Assistant screen
2. Ask safety-related questions
3. Get context-aware advice based on your location and time
4. Receive personalized safety recommendations

#### 📍 Sharing Live Location
1. Open the Tracking screen
2. Select trusted contacts to share with
3. Enable live tracking
4. Contacts receive real-time location updates

---

## 🏗️ Architecture

### Project Structure

```
nirbhaya/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── layout.tsx         # Root layout with theme provider
│   │   ├── page.tsx           # Main app entry point
│   │   └── globals.css        # Global styles
│   │
│   ├── components/
│   │   ├── app/               # Application-specific components
│   │   │   ├── app-shell.tsx           # Smartphone shell wrapper
│   │   │   ├── app-header.tsx          # App header component
│   │   │   ├── bottom-nav.tsx          # Bottom navigation
│   │   │   ├── home-screen.tsx         # Home/SOS screen
│   │   │   ├── map-screen.tsx          # Safety map screen
│   │   │   ├── safety-assistant-screen.tsx  # AI chat screen
│   │   │   ├── tracking-screen.tsx     # Live tracking screen
│   │   │   ├── resources-screen.tsx    # Safety resources
│   │   │   ├── profile-screen.tsx      # User profile
│   │   │   └── fake-call-screen.tsx    # Fake call feature
│   │   │
│   │   ├── ui/                # shadcn/ui components (34 components)
│   │   │   ├── button.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── toast.tsx
│   │   │   └── ...
│   │   │
│   │   └── theme-provider.tsx # Theme context provider
│   │
│   ├── ai/                    # AI/Genkit integration
│   │   ├── genkit.ts          # Genkit configuration
│   │   ├── dev.ts             # Development server setup
│   │   └── flows/             # AI flows
│   │       ├── ai-safety-advice.ts      # Safety advice flow
│   │       ├── ai-crime-hotspot-map.ts  # Crime analysis flow
│   │       └── ai-detect-distress.ts    # Distress detection
│   │
│   ├── hooks/                 # Custom React hooks
│   │   └── use-toast.ts       # Toast notification hook
│   │
│   └── lib/                   # Utility functions
│       └── utils.ts           # Helper utilities
│
├── public/                    # Static assets
├── tailwind.config.ts         # Tailwind configuration
├── tsconfig.json             # TypeScript configuration
├── next.config.ts            # Next.js configuration
├── postcss.config.mjs        # PostCSS configuration
├── components.json           # shadcn/ui configuration
└── package.json              # Dependencies and scripts
```

### Component Architecture

The application follows a **component-driven architecture** with clear separation of concerns:

- **App Shell**: Provides the smartphone frame and layout structure
- **Screen Components**: Each feature is a self-contained screen component
- **UI Components**: Reusable shadcn/ui components for consistent design
- **AI Flows**: Server-side AI logic using Genkit framework

### State Management

- **React Hooks**: Primary state management using `useState`, `useEffect`
- **Context API**: Theme management via `ThemeProvider`
- **Server Actions**: AI flows run as server actions for security

### AI Integration Flow

```
User Input → Screen Component → AI Flow (Server) → Genkit → Gemini AI → Response → UI Update
```

1. User interacts with UI (e.g., asks safety question)
2. Component calls server action
3. Genkit orchestrates AI flow
4. Gemini model processes request
5. Response returned and displayed

---

## 🎨 Design Philosophy

### Mobile-First Approach
- **Samsung Galaxy S25 design**: Authentic smartphone shell with punch-hole camera
- **Responsive design**: Optimized for mobile devices
- **Adaptive layout**: Phone shell on desktop, full-screen on mobile
- **Touch-friendly** interactions and gestures
- **Modern aesthetics**: Thinner bezels, Samsung-style gesture bar

### Accessibility
- WCAG 2.1 compliant components via Radix UI
- Keyboard navigation support
- Screen reader friendly
- High contrast color schemes
- Proper image alt texts and ARIA labels

### Visual Design
- **Dark Mode**: Default theme for reduced eye strain and premium feel
- **Glassmorphism**: Modern frosted glass effects
- **Smooth Animations**: 
  - SOS pulse animation (scale 1.0 → 1.15)
  - Accordion animations for expandable content
  - Fade-in effects for screen transitions
  - Call screen animations (pulse, glow effects)
- **Color Psychology**: 
  - Red for emergency (SOS, decline)
  - Green for safety (accept call, safe zones)
  - Blue for outgoing actions (calling)
  - Lavender/purple accents for premium feel
- **Custom Scrollbar**: Sleek, minimal design
- **Inter Font Family**: Modern, readable typography

---

## 🔐 Security & Privacy

- **Client-side encryption** for sensitive data
- **Secure API calls** to AI services
- **Privacy-first design** - user data never shared without consent
- **Firebase Authentication** for secure user management
- **Environment variables** for API key protection

---

## 🌟 Future Enhancements

- [ ] Mobile app versions (iOS & Android)
- [ ] Real-time video streaming to emergency contacts
- [ ] Integration with local police departments
- [ ] Wearable device support (smartwatch SOS)
- [ ] Multi-language support
- [ ] Offline mode with cached safety resources
- [ ] Community reporting features
- [ ] Advanced AI distress detection from voice/text

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

**Aman Kanojiya**

- GitHub: [@codedbyamankanojiya](https://github.com/codedbyamankanojiya)
- Portfolio: [Your Portfolio URL]
- LinkedIn: [in/aman-kanojiya-7386822b0](https://www.linkedin.com/in/aman-kanojiya-7386822b0)
- Email:- aman.knj2006@gmail.com

---

## 🙏 Acknowledgments

- **Google Genkit** for the powerful AI orchestration framework
- **Vercel** for Next.js and deployment platform
- **shadcn** for the beautiful UI component library
- **Radix UI** for accessible primitives
- All open-source contributors who made this project possible

---

## 📞 Support

For support, questions, or feedback:
- Open an issue on [GitHub Issues](https://github.com/codedbyamankanojiya/nirbhaya/issues)
- Contact: [aman.knj2006@gmail.com](mail to:aman.knj2006@gmail.com)

---

<div align="center">

**Made with ❤️ for Womens (Our Beloved Mothers & Sisters)**

⭐ Star this repository if you find it helpful!

</div>
