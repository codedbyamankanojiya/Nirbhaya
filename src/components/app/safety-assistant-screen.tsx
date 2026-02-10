"use client";

import { useState, useRef, useEffect, useCallback } from 'react';
import type { FC } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { ScrollArea, ScrollBar } from '@/components/ui/scroll-area';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
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
            const result: SafetyAdviceOutput = await getSafetyAdvice({
                location: 'Mumbai, India', // Example location
                timeOfDay: new Date().toLocaleTimeString(),
                recentCrimeData: `User asked: "${textToSend}"`,
            });

            const aiMessage: Message = {
                id: Date.now() + 1,
                text: result.advice,
                sender: 'ai',
            };
            setMessages((prev) => [...prev, aiMessage]);
        } catch (error) {
            toast({
                title: 'Error fetching advice',
                description: 'Could not get a response from the AI. Please try again.',
                variant: 'destructive',
            });
            const errorMessage: Message = {
                id: Date.now() + 1,
                text: 'Sorry, I am unable to provide advice at the moment.',
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
                                <Avatar className="w-8 h-8 bg-primary text-primary-foreground">
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
                            <Avatar className="w-8 h-8 bg-primary text-primary-foreground">
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
