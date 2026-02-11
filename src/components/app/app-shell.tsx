'use client';

import type { ReactNode } from "react";
import { cn } from "@/lib/utils";
import { useRouter } from "next/navigation";

export function AppShell({ children, className }: { children: ReactNode; className?: string }) {
    const router = useRouter();

    const handleBack = () => {
        router.back();
    };

    const handleHome = () => {
        router.push('/');
    };

    const handleRecents = () => {
        // Placeholder for recents
        console.log('Recents clicked');
    };

    return (
        <div className="w-full max-w-[400px] mx-auto h-[800px] max-h-[90vh] bg-black rounded-[42px] shadow-2xl overflow-hidden border-[8px] border-neutral-900 flex flex-col relative group">
            {/* Samsung S25 Punch-hole Camera */}
            <div className="absolute top-3 left-1/2 -translate-x-1/2 w-3 h-3 bg-black rounded-full z-30 ring-2 ring-neutral-800"></div>

            {/* Screen Container */}
            <div id="app-shell-container" className={cn("flex-grow flex flex-col overflow-hidden relative bg-card", className)}>
                {children}
            </div>

            {/* Android Navigation Bar - Transparent Overlay */}
            <div className="absolute bottom-0 left-0 right-0 h-12 bg-gradient-to-t from-black/80 to-transparent flex items-center justify-around px-8 z-50 pointer-events-none">
                {/* Back Button */}
                <button
                    onClick={handleBack}
                    className="flex items-center justify-center w-12 h-full active:bg-white/10 transition-colors pointer-events-auto"
                >
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-white/80 filter drop-shadow-md">
                        <path d="M15 18l-6-6 6-6" />
                    </svg>
                </button>

                {/* Home Button */}
                <button
                    onClick={handleHome}
                    className="flex items-center justify-center w-12 h-full active:bg-white/10 transition-colors pointer-events-auto"
                >
                    <div className="w-4 h-4 rounded-full border-2 border-white/80 shadow-md"></div>
                </button>

                {/* Recents Button */}
                <button
                    onClick={handleRecents}
                    className="flex items-center justify-center w-12 h-full active:bg-white/10 transition-colors pointer-events-auto"
                >
                    <div className="w-4 h-4 rounded-[4px] border-2 border-white/80 shadow-md"></div>
                </button>
            </div>
        </div>
    );
}
