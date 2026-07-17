
"use client";

import { useState, type ReactNode, type FC } from "react";
import { AppShell } from "@/components/app/app-shell";
import { BottomNav } from "@/components/app/bottom-nav";
import HomeScreen from "@/components/app/home-screen";
import MapScreen from "@/components/app/map-screen";
import SafetyAssistantScreen from "@/components/app/safety-assistant-screen";
import TrackingScreen from "@/components/app/tracking-screen";
import ProfileScreen from "@/components/app/profile-screen";
import FakeCallScreen from "@/components/app/fake-call-screen";
import ResourcesScreen from "@/components/app/resources-screen";
import { ThemeProvider } from "@/components/theme-provider";
import { Home as HomeIcon, Map, Sparkles, Users, User, BookOpen } from "lucide-react";

export type ScreenId = "home" | "map" | "ai" | "tracking" | "resources" | "profile";

const screens: { [key in ScreenId]: { id: ScreenId; component: FC<any>; icon: FC<any> } } = {
  home: { id: "home", component: HomeScreen, icon: HomeIcon },
  map: { id: "map", component: MapScreen, icon: Map },
  ai: { id: "ai", component: SafetyAssistantScreen, icon: Sparkles },
  tracking: { id: "tracking", component: TrackingScreen, icon: Users },
  resources: { id: "resources", component: ResourcesScreen, icon: BookOpen },
  profile: { id: "profile", component: ProfileScreen, icon: User },
};

const navItems = [
  { id: "home", icon: HomeIcon, label: "Home" },
  { id: "map", icon: Map, label: "Map" },
  { id: "ai", icon: Sparkles, label: "Assistant" },
  { id: "tracking", icon: Users, label: "Tracking" },
  { id: "resources", icon: BookOpen, label: "Resources" },
];

interface ScreenWrapperProps {
  id: ScreenId;
  onNavigate: (screen: ScreenId) => void;
  onFakeCall: () => void;
  onBack: () => void;
  isHomeScreen: boolean;
}

// This wrapper component ensures that only the necessary props are passed to each screen.
const ScreenWrapper: FC<ScreenWrapperProps> = ({ id, onNavigate, onFakeCall, onBack, isHomeScreen }) => {
  const Component = screens[id].component;

  if (id === 'home') {
    return <Component onNavigate={onNavigate} onFakeCall={onFakeCall} onBack={onBack} isHomeScreen={isHomeScreen} />;
  }

  // All other screens only get onBack
  return <Component onBack={onBack} />;
};


export default function Home() {
  const [activeScreen, setActiveScreen] = useState<ScreenId>("home");
  const [showFakeCall, setShowFakeCall] = useState(false);

  const handleNavigate = (screen: ScreenId) => {
    setActiveScreen(screen);
  };

  const handleBack = () => {
    setActiveScreen("home");
  };

  const isHomeScreen = activeScreen === 'home';

  return (
    <main className="flex min-h-screen w-full flex-col items-center justify-center p-0 lg:p-4 bg-gradient-to-br from-blue-100 via-purple-100 to-pink-100">
      <ThemeProvider
        attribute="class"
        defaultTheme="dark"
        enableSystem
        disableTransitionOnChange
        storageKey="nirbhaya-theme"
      >
        <AppShell>
          {showFakeCall ? (
            <FakeCallScreen onHangUp={() => setShowFakeCall(false)} />
          ) : (
            <>
              <div className="flex-grow overflow-y-auto">
                <ScreenWrapper
                  id={activeScreen}
                  onNavigate={handleNavigate}
                  onFakeCall={() => setShowFakeCall(true)}
                  onBack={handleBack}
                  isHomeScreen={isHomeScreen}
                />
              </div>
              <div className="relative">
                <BottomNav
                  activeScreen={activeScreen}
                  setActiveScreen={setActiveScreen}
                  navItems={navItems}
                  onProfileClick={() => setActiveScreen('profile')}
                />
              </div>
            </>
          )}
        </AppShell>
      </ThemeProvider>
    </main>
  );
}
