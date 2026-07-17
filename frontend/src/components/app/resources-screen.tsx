
"use client";

import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Button } from "@/components/ui/button";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import { BookOpen, ChevronRight, ExternalLink, Phone } from "lucide-react";
import React, { useEffect, useMemo, useState } from 'react';
import AppHeader from './app-header';

type ResourceItem =
    | {
        id: string;
        kind: "article";
        title: string;
        category: string;
        summary: string;
        content: string[];
    }
    | {
        id: string;
        kind: "helpline";
        title: string;
        category: string;
        summary: string;
        phone: string;
    }
    | {
        id: string;
        kind: "link";
        title: string;
        category: string;
        summary: string;
        url: string;
    };

const resources: ResourceItem[] = [
    {
        id: '1',
        kind: "article",
        title: 'Situational Awareness: Your First Line of Defense',
        category: 'Prevention',
        summary: 'Learn to be more aware of your surroundings to prevent dangerous situations before they happen.',
        content: [
            'Keep your head up and scan your surroundings.',
            'Avoid distractions (low volume, minimal screen time) in unfamiliar areas.',
            'Trust your intuition—if something feels off, leave.',
            'Identify exits and safe places (shops, police booths, populated areas).',
        ],
    },
    {
        id: '2',
        kind: "article",
        title: '5 Essential Self-Defense Moves Everyone Should Know',
        category: 'Self-Defense',
        summary: 'Simple but effective techniques to help you protect yourself in an emergency.',
        content: [
            'Aim for vulnerable areas: eyes, nose, throat, groin, knees.',
            'Use your voice: shout, attract attention, create distance.',
            'Practice a strong palm-heel strike and knee strike.',
            'If grabbed, break the grip by targeting the thumb-side of the hold.',
        ],
    },
    {
        id: '3',
        kind: "article",
        title: 'How to Safely Use Ride-Sharing Services',
        category: 'Daily Life',
        summary: 'Tips for verifying your ride, sharing your trip details, and staying safe as a passenger.',
        content: [
            'Match the car number plate and driver photo before entering.',
            'Share your trip status/live location with a trusted contact.',
            'Sit in the back seat and keep the door-side window slightly open.',
            'If route looks wrong, ask to stop in a crowded/safe place.',
        ],
    },
    {
        id: '4',
        kind: "article",
        title: 'Creating a Personal Safety Plan',
        category: 'Planning',
        summary: 'Steps to build a comprehensive safety plan for your daily routines and unexpected events.',
        content: [
            'Pick 2-3 emergency contacts and share your usual routes.',
            'Set a check-in routine (arrived home / reached office).',
            'Keep emergency numbers on speed dial and phone charged.',
            'Plan safe locations you can reach quickly.',
        ],
    },
    {
        id: '5',
        kind: "article",
        title: 'Recognizing and Avoiding Unsafe Situations',
        category: 'Prevention',
        summary: 'Trusting your intuition and identifying red flags in people and places.',
        content: [
            'Watch for someone following your pace repeatedly.',
            'Avoid isolated areas if you feel uncomfortable.',
            'Move toward groups and well-lit streets.',
            'Call a friend and stay on the line while relocating.',
        ],
    },
    {
        id: '6',
        kind: "article",
        title: 'Digital Safety: Protecting Yourself Online',
        category: 'Online Security',
        summary: 'Best practices for managing your online presence, securing accounts, and avoiding online harassment.',
        content: [
            'Enable 2-factor authentication (2FA) on important accounts.',
            'Review privacy settings on social apps regularly.',
            'Avoid sharing real-time location publicly.',
            'Save evidence and report harassment—do not engage.',
        ],
    },
    {
        id: '7',
        kind: "helpline",
        title: 'Emergency Helpline (India)',
        category: 'Helpline',
        summary: 'Call for immediate police/ambulance/fire assistance.',
        phone: '112',
    },
    {
        id: '8',
        kind: "helpline",
        title: 'Women Helpline (India)',
        category: 'Helpline',
        summary: '24x7 helpline for women in distress.',
        phone: '181',
    },
    {
        id: '9',
        kind: "link",
        title: 'Cyber Crime Reporting Portal',
        category: 'Online Security',
        summary: 'Report cyber harassment and online abuse.',
        url: 'https://cybercrime.gov.in/',
    },
];

export default function ResourcesScreen({ onBack }: { onBack: () => void }) {
    const [selected, setSelected] = useState<ResourceItem | null>(null);
    const [portalContainer, setPortalContainer] = useState<HTMLElement | null>(null);

    useEffect(() => {
        if (typeof document === "undefined") return;
        setPortalContainer(document.getElementById("app-shell-container"));
    }, []);

    const isOpen = useMemo(() => Boolean(selected), [selected]);

    const handleOpenResource = (item: ResourceItem) => {
        setSelected(item);
    };

    const handlePrimaryAction = () => {
        if (!selected) return;

        if (selected.kind === "helpline") {
            window.location.href = `tel:${selected.phone}`;
        }
        if (selected.kind === "link") {
            window.open(selected.url, "_blank", "noopener,noreferrer");
        }
    };

    return (
        <div className="h-full bg-background flex flex-col">
            <AppHeader title="Safety Resources" description="Empower yourself with knowledge." onBack={onBack} showBackButton={true} icon={BookOpen} />

            <Dialog open={isOpen} onOpenChange={(open) => (open ? null : setSelected(null))}>
                <DialogContent portalContainer={portalContainer} className="sm:max-w-lg">
                    <DialogHeader>
                        <DialogTitle>{selected?.title}</DialogTitle>
                        <DialogDescription>{selected?.category}</DialogDescription>
                    </DialogHeader>

                    {selected ? (
                        <div className="space-y-4">
                            <p className="text-sm text-muted-foreground">{selected.summary}</p>

                            {selected.kind === "article" ? (
                                <div className="space-y-2">
                                    {selected.content.map((line, idx) => (
                                        <p key={idx} className="text-sm text-foreground">{line}</p>
                                    ))}
                                </div>
                            ) : null}

                            {selected.kind === "helpline" ? (
                                <div className="flex items-center justify-between rounded-md border p-3">
                                    <div>
                                        <p className="text-sm font-medium">Call</p>
                                        <p className="text-sm text-muted-foreground">{selected.phone}</p>
                                    </div>
                                    <Phone className="h-4 w-4 text-muted-foreground" />
                                </div>
                            ) : null}

                            {selected.kind === "link" ? (
                                <div className="flex items-center justify-between rounded-md border p-3">
                                    <div className="min-w-0">
                                        <p className="text-sm font-medium">Open website</p>
                                        <p className="text-sm text-muted-foreground truncate">{selected.url}</p>
                                    </div>
                                    <ExternalLink className="h-4 w-4 text-muted-foreground" />
                                </div>
                            ) : null}
                        </div>
                    ) : null}

                    <DialogFooter className="gap-2 sm:gap-0">
                        <Button variant="outline" onClick={() => setSelected(null)}>
                            Close
                        </Button>
                        {selected?.kind === "article" ? null : (
                            <Button onClick={handlePrimaryAction}>
                                {selected?.kind === "helpline" ? "Call" : "Open"}
                            </Button>
                        )}
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            <ScrollArea className="flex-grow">
                <div className="p-4 space-y-4">
                    {resources.map((item) => (
                        <Card
                            key={item.id}
                            className="hover:bg-muted/50 transition-colors cursor-pointer"
                            onClick={() => handleOpenResource(item)}
                        >
                            <CardHeader className="flex flex-row items-center justify-between p-4">
                                <div className="space-y-1.5">
                                    <CardTitle className="text-base font-semibold leading-snug">{item.title}</CardTitle>
                                    <CardDescription className="text-xs !mt-1">{item.category}</CardDescription>
                                </div>
                                <ChevronRight className="w-5 h-5 text-muted-foreground" />
                            </CardHeader>
                        </Card>
                    ))}
                </div>
            </ScrollArea>
        </div>
    );
}
