'use client';

import type { ReactNode } from "react";
import { cn } from "@/lib/utils";

export function AppShell({ children, className }: { children: ReactNode; className?: string }) {
    return (
        <div className="w-full max-w-[400px] mx-auto h-[860px] max-h-[90vh] bg-black rounded-[42px] shadow-2xl overflow-hidden border-[8px] border-neutral-900 flex flex-col relative group">
            {/* Samsung S25 Punch-hole Camera */}
            <div className="absolute top-3 left-1/2 -translate-x-1/2 w-3 h-3 bg-black rounded-full z-30 ring-2 ring-neutral-800"></div>

            {/* Screen Container */}
            <div id="app-shell-container" className={cn("flex-grow flex flex-col overflow-hidden relative bg-card", className)}>
                {children}
            </div>

            {/* Samsung-style Bottom Gesture Bar */}
            <div className="absolute bottom-1.5 left-1/2 -translate-x-1/2 w-28 h-1 bg-neutral-700 rounded-full opacity-90 z-20"></div>
        </div>
    );
}
