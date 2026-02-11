
'use client';

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { getPlaceholderImage } from '@/lib/placeholder-images';
import { User, Shield, HeartPulse, Phone, Users, Settings, Globe, Moon, Sun } from 'lucide-react';
import React from 'react';
import { useTheme } from 'next-themes';
import { Switch } from '../ui/switch';
import { Button } from '@/components/ui/button';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select"
import { useToast } from '@/hooks/use-toast';
import AppHeader from './app-header';


const contacts = [
    { id: '1', name: 'Mom', relation: 'Family', avatarId: 'guardian-2' },
    { id: '2', name: 'Dad', relation: 'Family', avatarId: 'guardian-3' },
    { id: '3', name: 'Aman Kanojiya', relation: 'Friend', avatarId: 'guardian-4' },
    { id: '4', name: 'Brother', relation: 'Family', avatarId: 'guardian-5' },
];

const guardians = [
    { id: '1', name: 'Mom', relation: 'Guardian', avatarId: 'guardian-2' },
    { id: '2', name: 'Aisha Khan', relation: 'Guardian', avatarId: 'guardian-1' },
];

const SettingsItem: React.FC<{ icon: React.ElementType, title: string, description: string, children: React.ReactNode }> = ({ icon: Icon, title, description, children }) => (
    <div className="flex items-center">
        <div className="flex items-center gap-4 flex-grow">
            <Icon className="w-5 h-5 text-primary" />
            <div>
                <p className="font-medium">{title}</p>
                <p className="text-sm text-muted-foreground">{description}</p>
            </div>
        </div>
        {children}
    </div>
)


export default function ProfileScreen({ onBack }: { onBack: () => void }) {
    const userAvatar = getPlaceholderImage('user-avatar');
    const { theme, setTheme } = useTheme();
    const { toast } = useToast();

    const handleCallFriend = (contactName: string) => {
        toast({
            title: `Calling ${contactName}...`,
            description: "Opening dialer to call your trusted contact.",
            duration: 3000,
        });
    };

    return (
        <div className="h-full bg-background flex flex-col">
            <AppHeader title="My Profile" onBack={onBack} showBackButton={true} icon={User} />
            <div className="flex-grow p-4 space-y-6 overflow-y-auto">
                <div className="flex items-center space-x-4">
                    <Avatar className="h-20 w-20 border-4 border-primary/50">
                        {userAvatar && (
                            <AvatarImage src={userAvatar.imageUrl} alt={userAvatar.description} data-ai-hint={userAvatar.imageHint} />
                        )}
                        <AvatarFallback>P</AvatarFallback>
                    </Avatar>
                    <div>
                        <h2 className="text-2xl font-bold">Priya Sharma</h2>
                        <p className="text-muted-foreground">priya.s@email.com</p>
                    </div>
                </div>

                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Settings className="w-5 h-5 text-primary" />
                            Settings
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-6">
                        <SettingsItem icon={Globe} title="Language" description="Select your preferred language">
                            <Select defaultValue="en">
                                <SelectTrigger className="w-[180px]">
                                    <SelectValue placeholder="Language" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="en">English</SelectItem>
                                    <SelectItem value="hi">Hindi (हिन्दी)</SelectItem>
                                    <SelectItem value="ta">Tamil (தமிழ்)</SelectItem>
                                    <SelectItem value="te">Telugu (తెలుగు)</SelectItem>
                                    <SelectItem value="gu">Gujarati (ગુજરાતી)</SelectItem>
                                </SelectContent>
                            </Select>
                        </SettingsItem>
                        <SettingsItem icon={theme === 'dark' ? Moon : Sun} title="Display Mode" description={theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode'}>
                            <Switch
                                checked={theme === 'dark'}
                                onCheckedChange={() => setTheme(theme === 'light' ? 'dark' : 'light')}
                                aria-label="Toggle dark mode"
                            />
                        </SettingsItem>
                    </CardContent>
                </Card>

                <Card className="overflow-hidden">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <HeartPulse className="w-5 h-5 text-primary" />
                            Medical Information
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4 text-sm">
                        <div className="flex justify-between items-center">
                            <span className="text-muted-foreground">Blood Type:</span>
                            <span className="font-semibold text-base">O+</span>
                        </div>
                        <div className="flex justify-between items-center">
                            <span className="text-muted-foreground">Allergies:</span>
                            <span className="font-semibold text-base">Peanuts</span>
                        </div>
                        <div className="flex justify-between items-center">
                            <span className="text-muted-foreground">Medical Conditions:</span>
                            <span className="font-semibold text-base">Asthma</span>
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Phone className="w-5 h-5 text-primary" />
                            Emergency Contacts
                        </CardTitle>
                        <CardDescription>These contacts will be sent an SMS during an SOS.</CardDescription>
                    </CardHeader>
                    <CardContent className="p-0">
                        <div className="divide-y">
                            {contacts.map((contact) => {
                                const avatar = getPlaceholderImage(contact.avatarId);
                                return (
                                    <div key={contact.id} className="flex items-center space-x-4 px-6 py-4 hover:bg-muted/50 transition-colors">
                                        <Avatar className="h-12 w-12">
                                            {avatar && (
                                                <AvatarImage src={avatar.imageUrl} alt={avatar.description} data-ai-hint={avatar.imageHint} />
                                            )}
                                            <AvatarFallback>{contact.name.charAt(0)}</AvatarFallback>
                                        </Avatar>
                                        <div className="flex-grow">
                                            <p className="font-semibold">{contact.name}</p>
                                            <p className="text-sm text-muted-foreground">{contact.relation}</p>
                                        </div>
                                        <Button variant="ghost" size="icon" onClick={() => handleCallFriend(contact.name)}>
                                            <Phone className="w-5 h-5 text-primary" />
                                        </Button>
                                    </div>
                                );
                            })}
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Users className="w-5 h-5 text-primary" />
                            Guardians
                        </CardTitle>
                        <CardDescription>These contacts can view your live location.</CardDescription>
                    </CardHeader>
                    <CardContent className="p-0">
                        <div className="divide-y">
                            {guardians.map((guardian) => {
                                const avatar = getPlaceholderImage(guardian.avatarId);
                                return (
                                    <div key={guardian.id} className="flex items-center space-x-4 px-6 py-4 hover:bg-muted/50 cursor-pointer transition-colors">
                                        <Avatar className="h-12 w-12">
                                            {avatar && (
                                                <AvatarImage src={avatar.imageUrl} alt={avatar.description} data-ai-hint={avatar.imageHint} />
                                            )}
                                            <AvatarFallback>{guardian.name.charAt(0)}</AvatarFallback>
                                        </Avatar>
                                        <div className="flex-grow">
                                            <p className="font-semibold">{guardian.name}</p>
                                            <p className="text-sm text-muted-foreground">{guardian.relation}</p>
                                        </div>
                                        <Shield className="w-5 h-5 text-primary" />
                                    </div>
                                );
                            })}
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
