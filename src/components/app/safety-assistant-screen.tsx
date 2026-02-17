"use client";

import { useState, useRef, useEffect, useCallback } from 'react';
import type { FC } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { ScrollArea, ScrollBar } from '@/components/ui/scroll-area';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { useToast } from '@/hooks/use-toast';
import { getSafetyAdvice, type SafetyAdviceOutput } from '@/ai/flows/ai-safety-advice';
import { Send, Sparkles, Bot, User, Zap } from 'lucide-react';
import { cn } from '@/lib/utils';
import AppHeader from './app-header';

interface Message {
    id: number;
    text: string;
    sender: 'user' | 'ai';
}

const quickPrompts = [
    "Tips for walking alone at night",
    "What to do if I feel unsafe?",
    "How to be safe in a taxi?",
    "Create a safety plan for my evening walk"
];

const AI_AVATAR_DATA_URI =
    "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='96' height='96' viewBox='0 0 96 96'%3E%3Cdefs%3E%3CradialGradient id='g' cx='50%25' cy='35%25' r='80%25'%3E%3Cstop offset='0%25' stop-color='%23A78BFA'/%3E%3Cstop offset='55%25' stop-color='%236D28D9'/%3E%3Cstop offset='100%25' stop-color='%23111'/%3E%3C/radialGradient%3E%3C/defs%3E%3Crect width='96' height='96' rx='48' fill='url(%23g)'/%3E%3Cpath d='M28 62c0-10 8-18 18-18h4c10 0 18 8 18 18v6H28v-6z' fill='%23fff' fill-opacity='.18'/%3E%3Cpath d='M34 40c0-8 6-14 14-14s14 6 14 14-6 14-14 14-14-6-14-14z' fill='%23fff' fill-opacity='.22'/%3E%3Cpath d='M33 41h30' stroke='%23fff' stroke-opacity='.5' stroke-width='3' stroke-linecap='round'/%3E%3Ccircle cx='40' cy='41' r='3.2' fill='%23fff'/%3E%3Ccircle cx='56' cy='41' r='3.2' fill='%23fff'/%3E%3Cpath d='M44 48c2.5 2.2 5.5 2.2 8 0' stroke='%23fff' stroke-opacity='.7' stroke-width='3' stroke-linecap='round'/%3E%3C/svg%3E";

export default function SafetyAssistantScreen({ onBack }: { onBack: () => void }) {
    const { toast } = useToast();
    const [messages, setMessages] = useState<Message[]>([
        {
            id: 1,
            text: "Hello! I'm your AI Safety Assistant. How can I help you stay safe today? You can ask me anything or select one of the prompts below.",
            sender: 'ai',
        },
    ]);
    const [input, setInput] = useState('');
    const [loading, setLoading] = useState(false);
    const scrollAreaRef = useRef<HTMLDivElement>(null);

    const withTimeout = async <T,>(promise: Promise<T>, ms: number): Promise<T> => {
        return await Promise.race([
            promise,
            new Promise<T>((_, reject) => setTimeout(() => reject(new Error("timeout")), ms)),
        ]);
    };

    const buildDemoAdvice = (prompt: string, location: string, timeOfDay: string) => {
        const p = prompt.toLowerCase();
        if (p.includes("taxi") || p.includes("cab") || p.includes("ride") || p.includes("uber") || p.includes("ola")) {
            return `Here are practical taxi/ride safety steps (demo mode):\n\n1) Verify driver + number plate before entering.\n2) Share trip details/live location with a trusted contact.\n3) Sit in the back seat (opposite the driver) and keep your phone accessible.\n4) Avoid revealing personal details; trust your instincts if something feels off.\n5) If route deviates, ask to stop at a crowded place and call 112/181.\n\nLocation: ${location}\nTime: ${timeOfDay}`;
        }
        if (p.includes("night") || p.includes("alone") || p.includes("walking")) {
            return `Night-walk safety tips (demo mode):\n\n1) Prefer well-lit main roads; avoid shortcuts and isolated lanes.\n2) Keep one ear free; reduce distractions.\n3) Walk confidently and stay near open shops/petrol pumps.\n4) Keep emergency numbers ready (112 / 181).\n5) If followed, enter a public place and call someone immediately.\n\nLocation: ${location}\nTime: ${timeOfDay}`;
        }
        if (p.includes("unsafe") || p.includes("help") || p.includes("emergency")) {
            return `If you feel unsafe right now (demo mode):\n\n1) Move to a crowded, well-lit place.\n2) Call emergency services: 112 (India) / Women helpline: 181.\n3) Share live location with a trusted contact.\n4) If possible, start recording evidence discreetly.\n5) Ask for help loudly and clearly if needed.\n\nLocation: ${location}\nTime: ${timeOfDay}`;
        }
        return `Safety plan template (demo mode):\n\n1) Choose 2 emergency contacts and enable live location sharing.\n2) Pick safe spots on your route (shops, police booth, hospital).\n3) Keep phone charged + power saving enabled; carry a small light.\n4) Decide a code word to alert your contacts quickly.\n5) Emergency numbers: 112 / 181.\n\nLocation: ${location}\nTime: ${timeOfDay}`;
    };

    const scrollToBottom = () => {
        if (scrollAreaRef.current) {
            const viewport = scrollAreaRef.current.querySelector('div');
            if (viewport) {
                viewport.scrollTop = viewport.scrollHeight;
            }
        }
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    const handleSend = useCallback(async (promptText?: string) => {
        const textToSend = promptText || input;
        if (!textToSend.trim() || loading) return;

        const userMessage: Message = {
            id: Date.now(),
            text: textToSend,
            sender: 'user',
        };
        setMessages((prev) => [...prev, userMessage]);
        setInput('');
        setLoading(true);

        try {
            const locationForDemo = 'Mumbai, India';
            const timeOfDay = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

            const result: SafetyAdviceOutput = await withTimeout(
                getSafetyAdvice({
                    location: locationForDemo,
                    timeOfDay,
                    recentCrimeData: `User asked: "${textToSend}"`,
                }),
                6000
            );

            const aiMessage: Message = {
                id: Date.now() + 1,
                text: result.advice,
                sender: 'ai',
            };
            setMessages((prev) => [...prev, aiMessage]);
        } catch (error) {
            const locationForDemo = 'Mumbai, India';
            const timeOfDay = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
            const errorMessage: Message = {
                id: Date.now() + 1,
                text: buildDemoAdvice(textToSend, locationForDemo, timeOfDay),
                sender: 'ai',
            };
            setMessages((prev) => [...prev, errorMessage]);
        } finally {
            setLoading(false);
        }
    }, [input, loading, toast]);

    return (
        <div className="h-full bg-background flex flex-col">
            <AppHeader title="AI Safety Assistant" description="Your personal guide for staying safe." onBack={onBack} showBackButton={true} icon={Sparkles} />
            <ScrollArea className="flex-grow pb-24" ref={scrollAreaRef}>
                <div className="p-4 space-y-4">
                    {messages.map((message) => (
                        <div
                            key={message.id}
                            className={cn(
                                'flex items-start gap-3',
                                message.sender === 'user' ? 'justify-end' : 'justify-start'
                            )}
                        >
                            {message.sender === 'ai' && (
                                <Avatar className="w-8 h-8">
                                    <AvatarImage src={AI_AVATAR_DATA_URI} alt="AI" />
                                    <AvatarFallback><Bot className="w-5 h-5" /></AvatarFallback>
                                </Avatar>
                            )}
                            <div
                                className={cn(
                                    'max-w-[85%] rounded-lg px-4 py-2 text-sm whitespace-pre-wrap',
                                    message.sender === 'user'
                                        ? 'bg-primary text-primary-foreground'
                                        : 'bg-muted'
                                )}
                            >
                                {message.text}
                            </div>
                            {message.sender === 'user' && (
                                <Avatar className="w-8 h-8">
                                    <AvatarFallback><User className="w-5 h-5" /></AvatarFallback>
                                </Avatar>
                            )}
                        </div>
                    ))}
                    {loading && (
                        <div className="flex items-start gap-3 justify-start">
                            <Avatar className="w-8 h-8">
                                <AvatarImage src={AI_AVATAR_DATA_URI} alt="AI" />
                                <AvatarFallback><Bot className="w-5 h-5" /></AvatarFallback>
                            </Avatar>
                            <div className="bg-muted rounded-lg px-4 py-3">
                                <div className="flex items-center space-x-1">
                                    <span className="h-2 w-2 bg-foreground/50 rounded-full animate-pulse [animation-delay:-0.3s]"></span>
                                    <span className="h-2 w-2 bg-foreground/50 rounded-full animate-pulse [animation-delay:-0.15s]"></span>
                                    <span className="h-2 w-2 bg-foreground/50 rounded-full animate-pulse"></span>
                                </div>
                            </div>
                        </div>
                    )}
                </div>
            </ScrollArea>
            <div className="absolute bottom-24 left-0 right-0 p-4 border-t bg-background space-y-3">
                <ScrollArea className="w-full whitespace-nowrap">
                    <div className="flex gap-2 pb-2">
                        {quickPrompts.map(prompt => (
                            <Button key={prompt} variant="outline" size="sm" className="text-xs h-8" onClick={() => handleSend(prompt)} disabled={loading}>
                                <Zap className="w-3 h-3 mr-1.5" />
                                {prompt}
                            </Button>
                        ))}
                    </div>
                    <ScrollBar orientation="horizontal" />
                </ScrollArea>

                <form
                    onSubmit={(e) => {
                        e.preventDefault();
                        handleSend();
                    }}
                    className="flex items-center gap-2"
                >
                    <Input
                        value={input}
                        onChange={(e) => setInput(e.target.value)}
                        placeholder="Ask for safety advice..."
                        disabled={loading}
                        autoComplete="off"
                    />
                    <Button type="submit" size="icon" disabled={loading}>
                        <Send className="w-4 h-4" />
                    </Button>
                </form>
            </div>
        </div>
    );
}
