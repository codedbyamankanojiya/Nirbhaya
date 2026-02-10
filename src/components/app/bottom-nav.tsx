
import type { FC } from "react";
import { cn } from "@/lib/utils";
import type { LucideIcon } from "lucide-react";
import type { ScreenId } from "@/app/page";
import { User } from 'lucide-react';

type NavItem = {
    id: ScreenId;
    icon: LucideIcon;
    label: string;
};

interface BottomNavProps {
    activeScreen: ScreenId;
    setActiveScreen: (screen: ScreenId) => void;
    navItems: readonly Omit<NavItem, 'id'> & { id: string }[];
    onProfileClick: () => void;
}

export function BottomNav({ activeScreen, setActiveScreen, navItems, onProfileClick }: BottomNavProps) {
    return (
        <div className="h-20 bg-background/80 backdrop-blur-sm border-t">
            <nav className="w-full h-full">
                <div className="flex justify-around items-center h-full px-2 relative">
                    {navItems.map((item) => (
                        <button
                            key={item.id}
                            onClick={() => setActiveScreen(item.id as ScreenId)}
                            className={cn(
                                "relative z-10 flex flex-col items-center justify-center gap-1 w-full h-full transition-colors duration-300",
                                activeScreen === item.id
                                    ? "text-primary"
                                    : "text-muted-foreground hover:text-foreground"
                            )}
                            aria-current={activeScreen === item.id ? "page" : undefined}
                        >
                            <item.icon className="w-6 h-6" />
                            <span className="text-[10px] font-medium">{item.label}</span>
                        </button>
                    ))}
                    <button
                        key="profile"
                        onClick={onProfileClick}
                        className={cn(
                            "relative z-10 flex flex-col items-center justify-center gap-1 w-full h-full transition-colors duration-300",
                            activeScreen === 'profile'
                                ? "text-primary"
                                : "text-muted-foreground hover:text-foreground"
                        )}
                        aria-current={activeScreen === 'profile' ? "page" : undefined}
                    >
                        <User className="w-6 h-6" />
                        <span className="text-[10px] font-medium">Profile</span>
                    </button>
                </div>
            </nav>
        </div>
    );
}
