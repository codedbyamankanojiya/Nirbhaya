
"use client";

import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { ScrollArea } from "@/components/ui/scroll-area";
import { BookOpen, ChevronRight } from "lucide-react";
import React from 'react';
import AppHeader from './app-header';

const safetyArticles = [
    {
        id: '1',
        title: 'Situational Awareness: Your First Line of Defense',
        category: 'Prevention',
        summary: 'Learn to be more aware of your surroundings to prevent dangerous situations before they happen.'
    },
    {
        id: '2',
        title: '5 Essential Self-Defense Moves Everyone Should Know',
        category: 'Self-Defense',
        summary: 'Simple but effective techniques to help you protect yourself in an emergency.'
    },
    {
        id: '3',
        title: 'How to Safely Use Ride-Sharing Services',
        category: 'Daily Life',
        summary: 'Tips for verifying your ride, sharing your trip details, and staying safe as a passenger.'
    },
    {
        id: '4',
        title: 'Creating a Personal Safety Plan',
        category: 'Planning',
        summary: 'Steps to build a comprehensive safety plan for your daily routines and unexpected events.'
    },
    {
        id: '5',
        title: 'Recognizing and Avoiding Unsafe Situations',
        category: 'Prevention',
        summary: 'Trusting your intuition and identifying red flags in people and places.'
    },
    {
        id: '6',
        title: 'Digital Safety: Protecting Yourself Online',
        category: 'Online Security',
        summary: 'Best practices for managing your online presence, securing accounts, and avoiding online harassment.'
    },
];

export default function ResourcesScreen({ onBack }: { onBack: () => void }) {
    return (
        <div className="h-full bg-background flex flex-col">
            <AppHeader title="Safety Resources" description="Empower yourself with knowledge." onBack={onBack} showBackButton={true} icon={BookOpen} />
            <ScrollArea className="flex-grow">
                <div className="p-4 space-y-4">
                    {safetyArticles.map(article => (
                        <Card key={article.id} className="hover:bg-muted/50 transition-colors cursor-pointer">
                            <CardHeader className="flex flex-row items-center justify-between p-4">
                                <div className="space-y-1.5">
                                    <CardTitle className="text-base font-semibold leading-snug">{article.title}</CardTitle>
                                    <CardDescription className="text-xs !mt-1">{article.category}</CardDescription>
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
