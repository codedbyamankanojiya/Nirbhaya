'use client';

import { useState, useEffect, useCallback } from 'react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Switch } from '@/components/ui/switch';
import { Label } from '@/components/ui/label';
import { Users, Route, UserPlus } from 'lucide-react';
import { Separator } from '@/components/ui/separator';
import { Button } from '@/components/ui/button';
import React from 'react';
import AppHeader from './app-header';
import { useAuth } from '@/context/auth-context';
import { api, type ContactData } from '@/lib/api';

interface Guardian {
    id: string;
    name: string;
    relation: string;
    avatarUrl?: string;
    status: string;
}

export default function TrackingScreen({ onBack }: { onBack: () => void }) {
    const { isAuthenticated } = useAuth();
    const [guardians, setGuardians] = useState<Guardian[]>([]);

    // Load guardians from API contacts or localStorage
    const loadGuardians = useCallback(async () => {
        // Try API first when authenticated
        if (isAuthenticated) {
            try {
                const res = await api.get<ContactData[] | { data: ContactData[] }>('/api/v1/contacts');
                const list = Array.isArray(res.data) ? res.data : (res.data as any)?.data ?? [];
                if (list.length > 0) {
                    const formatted = list.map((c: any, i: number) => ({
                        id: c.id,
                        name: c.name,
                        relation: c.isPrimary ? 'Primary Contact' : 'Guardian',
                        avatarId: `guardian-${i % 6}`,
                        status: 'Idle',
                    }));
                    setGuardians(formatted);
                    return;
                }
            } catch {
                // Fall through to localStorage
            }
        }

        // Try localStorage
        const storedContacts = typeof window !== 'undefined' ? localStorage.getItem('nirbhaya_user_contacts') : null;
        if (storedContacts) {
            try {
                const parsed = JSON.parse(storedContacts);
                const formatted = parsed.map((c: any, i: number) => ({
                    id: c.id || String(i),
                    name: c.name,
                    relation: c.relation || 'Guardian',
                    avatarId: c.avatarId || `guardian-${i % 6}`,
                    status: 'Idle',
                }));
                setGuardians(formatted);
            } catch {
                setGuardians([]);
            }
        }
    }, [isAuthenticated]);

    useEffect(() => {
        loadGuardians();
    }, [loadGuardians]);

    return (
        <div className="h-full bg-background flex flex-col">
            <AppHeader title="Guardian Live Tracking" description="Share your location with trusted contacts." onBack={onBack} showBackButton={true} icon={Users} />
            <div className="flex-grow p-4 space-y-6 overflow-y-auto pb-28">
                <Card>
                    <CardHeader>
                        <CardTitle>My Guardians</CardTitle>
                        <CardDescription>Your location is shared with these contacts.</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        {guardians.length === 0 ? (
                            <div className="flex flex-col items-center gap-3 py-6 text-center">
                                <UserPlus className="w-10 h-10 text-muted-foreground/50" />
                                <div>
                                    <p className="text-sm font-medium text-muted-foreground">No guardians added yet</p>
                                    <p className="text-xs text-muted-foreground/70 mt-1">
                                        Add emergency contacts in your Profile to see them here.
                                    </p>
                                </div>
                            </div>
                        ) : (
                            guardians.map((guardian, index) => {
                                return (
                                    <React.Fragment key={guardian.id}>
                                        <div className="flex items-center space-x-3">
                                            <Avatar>
                                                {guardian.avatarUrl && (
                                                    <AvatarImage src={guardian.avatarUrl} alt={guardian.name} />
                                                )}
                                                <AvatarFallback>{guardian.name.charAt(0).toUpperCase()}</AvatarFallback>
                                            </Avatar>
                                            <div className="flex-grow">
                                                <p className="font-medium">{guardian.name}</p>
                                                <p className="text-xs text-muted-foreground">{guardian.relation}</p>
                                            </div>
                                            <div className="flex items-center gap-1.5">
                                                <div className={`w-2 h-2 rounded-full ${guardian.status === 'Viewing' ? 'bg-green-500' : 'bg-gray-400'}`}></div>
                                                <span className="text-xs text-muted-foreground">{guardian.status}</span>
                                            </div>
                                        </div>
                                        {index < guardians.length - 1 && <Separator />}
                                    </React.Fragment>
                                );
                            })
                        )}
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2"><Route className="w-5 h-5" /> Walking With Me</CardTitle>
                        <CardDescription>Live track your movement and alert guardians on route deviation.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="flex items-center justify-between rounded-lg border p-4">
                            <Label htmlFor="walking-mode" className="flex flex-col space-y-1">
                                <span>Activate Session</span>
                                <span className="font-normal leading-snug text-muted-foreground">
                                    Your guardians will be notified and can follow your trip.
                                </span>
                            </Label>
                            <Switch id="walking-mode" aria-label="Activate Walking With Me session" />
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
