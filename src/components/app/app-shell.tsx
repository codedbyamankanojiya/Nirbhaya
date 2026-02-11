'use client';

import type { ReactNode } from "react";
import { cn } from "@/lib/utils";

export function AppShell({ children, className }: { children: ReactNode; className?: string }) {
    return (
        <div className="w-full max-w-sm mx-auto h-[812px] max-h-[90vh] bg-neutral-800 rounded-[48px] shadow-2xl overflow-hidden border-[10px] border-black flex flex-col relative group">
            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-36 h-8 bg-black rounded-b-2xl z-20 flex items-center justify-center">
                <div className="w-16 h-1.5 bg-gray-700 rounded-full"></div>
            </div>

            <div id="app-shell-container" className={cn("flex-grow flex flex-col overflow-hidden relative bg-card", className)}>
                {children}
            </div>

            <div className="absolute bottom-2 left-1/2 -translate-x-1/2 w-32 h-1.5 bg-neutral-600 rounded-full opacity-80 group-hover:opacity-100 transition-opacity z-20"></div>
        </div>
    );
}
