'use client';

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { getPlaceholderImage } from '@/lib/placeholder-images';
import { Switch } from '@/components/ui/switch';
import { Label } from '@/components/ui/label';
import { Users, Route } from 'lucide-react';
import { Separator } from '@/components/ui/separator';
import React from 'react';
import AppHeader from './app-header';

const guardians = [
    { id: '1', name: 'Mom', relation: 'Guardian', avatarId: 'guardian-2', status: 'Viewing' },
    { id: '2', name: 'Aisha Khan', relation: 'Guardian', avatarId: 'guardian-1', status: 'Idle' },
];

export default function TrackingScreen({ onBack }: { onBack: () => void }) {

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
                        {guardians.map((guardian, index) => {
                            const avatar = getPlaceholderImage(guardian.avatarId);
                            return (
                                <React.Fragment key={guardian.id}>
                                    <div className="flex items-center space-x-3">
                                        <Avatar>
                                            {avatar && (
                                                <AvatarImage src={avatar.imageUrl} alt={avatar.description} data-ai-hint={avatar.imageHint} />
                                            )}
                                            <AvatarFallback>{guardian.name.charAt(0)}</AvatarFallback>
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
                        })}
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
