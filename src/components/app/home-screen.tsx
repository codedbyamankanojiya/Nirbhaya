
"use client";

import type { FC } from "react";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { useToast } from "@/hooks/use-toast";
import { Phone, Video, Shield, Siren } from "lucide-react";
import type { ScreenId } from "@/app/page";
import AppHeader from "./app-header";
import { AlertDialogTrigger } from "@radix-ui/react-alert-dialog";

interface ScreenProps {
    onNavigate: (screen: ScreenId) => void;
    onFakeCall: () => void;
    onBack: () => void;
    isHomeScreen: boolean;
}

const ActionButton: FC<{ icon: React.ElementType, title: string, onClick: () => void }> = ({ icon: Icon, title, onClick }) => (
    <div className="flex flex-col items-center gap-2">
        <Button onClick={onClick} variant="outline" size="icon" className="w-16 h-16 rounded-2xl bg-card shadow-sm hover:bg-muted transition-colors border">
            <Icon className="w-7 h-7 text-primary" />
        </Button>
        <p className="text-sm font-medium text-foreground">{title}</p>
    </div>
);

export default function HomeScreen({ onNavigate, onFakeCall, onBack, isHomeScreen }: ScreenProps) {
    const { toast } = useToast();
    const [isSosPressed, setIsSosPressed] = useState(false);

    const handleSos = () => {
        toast({
            title: "SOS Activated!",
            description: "Emergency alerts sent to contacts and authorities.",
            variant: "destructive",
            duration: 5000,
        });
    };

    const handleEvidenceCapture = () => {
        toast({
            title: "Evidence Capture On",
            description: "Silently recording audio and video.",
            duration: 3000,
        });
    };


    return (
        <div className="h-full flex flex-col app-gradient">
            <AppHeader title="Priya" showBackButton={!isHomeScreen} onBack={onBack} welcomeMessage="Welcome Back," />

            <div className="flex-grow flex flex-col justify-center items-center px-6 space-y-4">
                <AlertDialog>
                    <AlertDialogTrigger asChild>
                        <button
                            onMouseDown={() => setIsSosPressed(true)}
                            onMouseUp={() => setIsSosPressed(false)}
                            onTouchStart={() => setIsSosPressed(true)}
                            onTouchEnd={() => setIsSosPressed(false)}
                            onMouseLeave={() => setIsSosPressed(false)}
                            className="relative flex flex-col items-center justify-center w-52 h-52 rounded-full bg-red-500/10 transition-transform duration-200 active:scale-95"
                        >
                            <div className="absolute inset-0 rounded-full bg-red-500/20 animate-sos-pulse"></div>
                            <div className={`absolute inset-3 rounded-full bg-destructive shadow-lg flex flex-col items-center justify-center text-destructive-foreground transition-transform duration-200 ${isSosPressed ? 'scale-90' : 'scale-100'}`}>
                                <Siren className="w-20 h-20" />
                                <span className="text-2xl font-bold tracking-widest mt-1">SOS</span>
                            </div>
                        </button>
                    </AlertDialogTrigger>
                    <AlertDialogContent>
                        <AlertDialogHeader>
                            <AlertDialogTitle>Activate Emergency SOS?</AlertDialogTitle>
                            <AlertDialogDescription>
                                This will send your live location and an emergency alert to your guardians and local authorities. Are you sure?
                            </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                            <AlertDialogCancel>Cancel</AlertDialogCancel>
                            <AlertDialogAction onClick={handleSos} className="bg-destructive hover:bg-destructive/90">
                                Activate SOS
                            </AlertDialogAction>
                        </AlertDialogFooter>
                    </AlertDialogContent>
                </AlertDialog>
                <p className="text-muted-foreground text-center max-w-xs pt-4">Press the button to send an SOS alert to your emergency contacts.</p>
            </div>

            <div className="px-6 py-6 space-y-4 bg-card/60 backdrop-blur-xl rounded-t-3xl border-t">
                <div className="flex justify-around">
                    <ActionButton icon={Phone} title="Fake Call" onClick={onFakeCall} />
                    <ActionButton icon={Video} title="Record" onClick={handleEvidenceCapture} />
                    <ActionButton icon={Shield} title="Safety Tips" onClick={() => onNavigate('resources')} />
                </div>
            </div>
        </div>
    );
}
