'use client';

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import {
    User, Shield, HeartPulse, Phone, Users, Settings, Globe, Moon, Sun,
    LogIn, LogOut, Pencil, Plus, Trash2, MapPin, Mail, Calendar, FileText, Check, AlertCircle, Loader2
} from 'lucide-react';
import React, { useCallback, useEffect, useState, type FormEvent } from 'react';
import { useTheme } from 'next-themes';
import { Switch } from '../ui/switch';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
    DialogFooter,
} from "@/components/ui/dialog";
import { useToast } from '@/hooks/use-toast';
import AppHeader from './app-header';
import CallScreen from './call-screen';
import { useAuth } from '@/context/auth-context';
import AuthModal from './auth-modal';
import { api, type ContactData } from '@/lib/api';

// Initial default fallback contacts if no contacts exist in storage
const defaultContacts: Array<{
    id: string;
    name: string;
    phone: string;
    relation: string;
    isPrimary?: boolean;
    avatarId?: string;
}> = [];

const SettingsItem: React.FC<{ icon: React.ElementType; title: string; description: string; children: React.ReactNode }> = ({ icon: Icon, title, description, children }) => (
    <div className="flex items-center">
        <div className="flex items-center gap-4 flex-grow">
            <Icon className="w-5 h-5 text-primary" />
            <div>
                <p className="font-medium text-sm">{title}</p>
                <p className="text-xs text-muted-foreground">{description}</p>
            </div>
        </div>
        {children}
    </div>
);

export default function ProfileScreen({ onBack }: { onBack: () => void }) {
    const { theme, setTheme } = useTheme();
    const { toast } = useToast();
    const { user, isAuthenticated, logout, refreshProfile } = useAuth();

    const [activeCall, setActiveCall] = useState<{ name: string; avatar: string; initial: string } | null>(null);
    const [portalContainer, setPortalContainer] = useState<HTMLElement | null>(null);
    const [authModalOpen, setAuthModalOpen] = useState(false);

    // Dialog state
    const [editProfileOpen, setEditProfileOpen] = useState(false);
    const [editMedicalOpen, setEditMedicalOpen] = useState(false);
    const [addContactOpen, setAddContactOpen] = useState(false);

    // Saving loading states
    const [isSavingProfile, setIsSavingProfile] = useState(false);
    const [isSavingMedical, setIsSavingMedical] = useState(false);
    const [isSavingContact, setIsSavingContact] = useState(false);

    // ---------------------------------------------------------------------------
    // User Personal Data State
    // ---------------------------------------------------------------------------
    const [personalInfo, setPersonalInfo] = useState({
        name: '',
        phone: '',
        address: '',
        dob: '',
        gender: '',
        emergencyEmail: '',
    });

    // ---------------------------------------------------------------------------
    // User Medical Info State
    // ---------------------------------------------------------------------------
    const [medicalInfo, setMedicalInfo] = useState({
        bloodGroup: '',
        allergies: '',
        conditions: '',
        notes: '',
    });

    // ---------------------------------------------------------------------------
    // Emergency Contacts State
    // ---------------------------------------------------------------------------
    const [userContacts, setUserContacts] = useState<Array<{
        id: string;
        name: string;
        phone: string;
        relation: string;
        isPrimary?: boolean;
        avatarId?: string;
    }>>([]);

    useEffect(() => {
        if (typeof document === "undefined") return;
        setPortalContainer(document.getElementById("app-shell-container"));
    }, []);

    // Load stored data from localStorage / Auth context on mount
    useEffect(() => {
        // Personal info
        const storedPersonal = typeof window !== 'undefined' ? localStorage.getItem('nirbhaya_personal_info') : null;
        if (storedPersonal) {
            try {
                setPersonalInfo((prev) => ({ ...prev, ...JSON.parse(storedPersonal) }));
            } catch { }
        } else if (user?.profile) {
            setPersonalInfo((prev) => ({
                ...prev,
                name: user.profile?.name || prev.name,
                phone: user.profile?.emergencyPhone || prev.phone,
                address: user.profile?.address || prev.address,
                dob: user.profile?.dob || prev.dob,
                gender: user.profile?.gender || prev.gender,
                emergencyEmail: user.profile?.emergencyEmail || prev.emergencyEmail,
            }));
        }

        // Medical info
        const storedMedical = typeof window !== 'undefined' ? localStorage.getItem('nirbhaya_medical_info') : null;
        if (storedMedical) {
            try {
                setMedicalInfo((prev) => ({ ...prev, ...JSON.parse(storedMedical) }));
            } catch { }
        } else if (user?.profile?.bloodGroup) {
            setMedicalInfo((prev) => ({ ...prev, bloodGroup: user.profile?.bloodGroup || prev.bloodGroup }));
        }

        // Contacts info
        const storedContacts = typeof window !== 'undefined' ? localStorage.getItem('nirbhaya_user_contacts') : null;
        if (storedContacts) {
            try {
                setUserContacts(JSON.parse(storedContacts));
            } catch {
                setUserContacts(defaultContacts);
            }
        } else {
            setUserContacts(defaultContacts);
        }
    }, [user]);

    // Fetch contacts from API when authenticated
    const fetchApiContacts = useCallback(async () => {
        if (!isAuthenticated) return;
        try {
            const res = await api.get<ContactData[] | { data: ContactData[] }>('/api/v1/contacts');
            const list = Array.isArray(res.data) ? res.data : (res.data as any)?.data ?? [];
            if (list.length > 0) {
                const formatted = list.map((c: any, i: number) => ({
                    id: c.id,
                    name: c.name,
                    phone: c.phone,
                    relation: c.isPrimary ? 'Primary Contact' : 'Emergency Contact',
                    isPrimary: c.isPrimary,
                    avatarId: `guardian-${i % 6}`,
                }));
                setUserContacts(formatted);
                if (typeof window !== 'undefined') {
                    localStorage.setItem('nirbhaya_user_contacts', JSON.stringify(formatted));
                }
            }
        } catch {
            // Silently retain current local contacts
        }
    }, [isAuthenticated]);

    useEffect(() => {
        fetchApiContacts();
    }, [fetchApiContacts]);

    // ---------------------------------------------------------------------------
    // Handlers for Profile Updates
    // ---------------------------------------------------------------------------
    const handleSaveProfile = async (e: FormEvent) => {
        e.preventDefault();
        setIsSavingProfile(true);

        try {
            if (typeof window !== 'undefined') {
                localStorage.setItem('nirbhaya_personal_info', JSON.stringify(personalInfo));
            }

            if (isAuthenticated) {
                await api.patch('/api/v1/profile', {
                    name: personalInfo.name,
                    emergencyPhone: personalInfo.phone,
                    address: personalInfo.address,
                    dob: personalInfo.dob,
                    gender: personalInfo.gender,
                    emergencyEmail: personalInfo.emergencyEmail,
                });
                await refreshProfile();
            }

            toast({
                title: "Profile Updated",
                description: "Your personal details have been saved successfully.",
            });
            setEditProfileOpen(false);
        } catch (err: any) {
            toast({
                title: "Saved Locally",
                description: "Personal details updated on device.",
            });
            setEditProfileOpen(false);
        } finally {
            setIsSavingProfile(false);
        }
    };

    const handleSaveMedical = async (e: FormEvent) => {
        e.preventDefault();
        setIsSavingMedical(true);

        try {
            if (typeof window !== 'undefined') {
                localStorage.setItem('nirbhaya_medical_info', JSON.stringify(medicalInfo));
            }

            if (isAuthenticated) {
                await api.patch('/api/v1/profile', {
                    bloodGroup: medicalInfo.bloodGroup,
                });
                await refreshProfile();
            }

            toast({
                title: "Medical Info Updated",
                description: "Your medical emergency profile has been saved.",
            });
            setEditMedicalOpen(false);
        } catch {
            toast({
                title: "Saved Locally",
                description: "Medical information updated on device.",
            });
            setEditMedicalOpen(false);
        } finally {
            setIsSavingMedical(false);
        }
    };

    const handleAddContact = async (newContact: { name: string; phone: string; relation: string; email?: string; isPrimary: boolean }) => {
        setIsSavingContact(true);
        const contactObj = {
            id: String(Date.now()),
            name: newContact.name,
            phone: newContact.phone,
            relation: newContact.relation || 'Emergency Contact',
            isPrimary: newContact.isPrimary,
            avatarId: `guardian-${userContacts.length % 6}`,
        };

        try {
            let updatedList = [contactObj, ...userContacts];

            if (isAuthenticated) {
                const res = await api.post<ContactData>('/api/v1/contacts', {
                    name: newContact.name,
                    phone: newContact.phone,
                    email: newContact.email || undefined,
                    isPrimary: newContact.isPrimary,
                });
                if (res.data?.id) {
                    contactObj.id = res.data.id;
                }
            }

            setUserContacts(updatedList);
            if (typeof window !== 'undefined') {
                localStorage.setItem('nirbhaya_user_contacts', JSON.stringify(updatedList));
            }

            toast({
                title: "Contact Added",
                description: `${newContact.name} added to emergency contacts.`,
            });
            setAddContactOpen(false);
        } catch {
            const updatedList = [contactObj, ...userContacts];
            setUserContacts(updatedList);
            if (typeof window !== 'undefined') {
                localStorage.setItem('nirbhaya_user_contacts', JSON.stringify(updatedList));
            }
            toast({
                title: "Contact Added (Local)",
                description: `${newContact.name} added to your device emergency list.`,
            });
            setAddContactOpen(false);
        } finally {
            setIsSavingContact(false);
        }
    };

    const handleDeleteContact = async (id: string, name: string) => {
        try {
            if (isAuthenticated) {
                await api.delete(`/api/v1/contacts/${id}`).catch(() => {});
            }
            const filtered = userContacts.filter((c) => c.id !== id);
            setUserContacts(filtered);
            if (typeof window !== 'undefined') {
                localStorage.setItem('nirbhaya_user_contacts', JSON.stringify(filtered));
            }
            toast({
                title: "Contact Removed",
                description: `${name} has been removed from contacts.`,
            });
        } catch {
            const filtered = userContacts.filter((c) => c.id !== id);
            setUserContacts(filtered);
            if (typeof window !== 'undefined') {
                localStorage.setItem('nirbhaya_user_contacts', JSON.stringify(filtered));
            }
        }
    };

    const handleCallContact = (contact: { name: string; avatarUrl?: string }) => {
        setActiveCall({
            name: contact.name,
            avatar: contact.avatarUrl || '',
            initial: contact.name.charAt(0),
        });
    };

    const handleLogout = async () => {
        await logout();
        toast({ title: 'Logged Out', description: 'You have been signed out.', duration: 3000 });
    };

    // Derive display info
    const displayName = isAuthenticated
        ? (user?.profile?.name || user?.email?.split('@')[0] || 'User')
        : personalInfo.name || 'Guest User';

    const displayEmail = isAuthenticated
        ? (user?.email || 'Signed In')
        : personalInfo.emergencyEmail || 'Sign in to sync your data';

    const displayInitial = displayName.charAt(0).toUpperCase();

    return (
        <div className="h-full bg-background flex flex-col">
            {activeCall && (
                <CallScreen
                    onHangUp={() => setActiveCall(null)}
                    callerName={activeCall.name}
                    callerSubtext="Emergency Dialing..."
                    callerInitial={activeCall.initial}
                    callerAvatar={activeCall.avatar}
                    autoAnswer={false}
                    callType="outgoing"
                />
            )}

            <AuthModal open={authModalOpen} onOpenChange={setAuthModalOpen} portalContainer={portalContainer} />

            <AppHeader title="My Safety Profile" onBack={onBack} showBackButton={true} icon={User} />

            <div className="flex-grow p-4 space-y-6 overflow-y-auto">

                {!isAuthenticated && (
                    <div className="bg-amber-500/10 border border-amber-500/30 rounded-xl p-3 flex items-start gap-2.5 text-xs text-amber-700 dark:text-amber-300">
                        <AlertCircle className="w-4 h-4 text-amber-500 shrink-0 mt-0.5" />
                        <div>
                            <p className="font-semibold text-xs text-amber-800 dark:text-amber-200">Guest Mode</p>
                            <p className="text-[11px] text-amber-700/90 dark:text-amber-300/90 mt-0.5">
                                Sign in to save your profile, emergency contacts, and medical info. Your data will sync across devices.
                            </p>
                        </div>
                    </div>
                )}

                {/* ---------------- User Header Card ---------------- */}
                <div className="flex items-center space-x-4 bg-card p-4 rounded-xl border shadow-sm">
                    <Avatar className="h-16 w-16 border-2 border-primary/50 shrink-0">
                        {user?.profile?.profileImageUrl && (
                            <AvatarImage src={user.profile.profileImageUrl} alt={displayName} />
                        )}
                        <AvatarFallback className="text-lg font-bold bg-primary/10 text-primary">
                            {displayInitial}
                        </AvatarFallback>
                    </Avatar>
                    <div className="flex-grow min-w-0">
                        <div className="flex items-center gap-1.5">
                            <h2 className="text-lg font-bold truncate">{displayName}</h2>
                        </div>
                        <p className="text-muted-foreground text-xs truncate">{displayEmail}</p>
                        <div className="mt-1">
                            {isAuthenticated ? (
                                <span className="inline-flex items-center gap-1 text-[11px] px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-500 font-medium">
                                    <Shield className="w-3 h-3" /> Cloud Synced
                                </span>
                            ) : (
                                <span className="inline-flex items-center gap-1 text-[11px] px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-600 dark:text-amber-400 font-medium">
                                    Guest Mode
                                </span>
                            )}
                        </div>
                    </div>
                    {isAuthenticated ? (
                        <Button variant="ghost" size="icon" onClick={handleLogout} title="Logout" className="shrink-0 text-destructive hover:bg-destructive/10">
                            <LogOut className="w-5 h-5" />
                        </Button>
                    ) : (
                        <Button variant="outline" size="sm" onClick={() => setAuthModalOpen(true)} className="shrink-0 gap-1 text-xs">
                            <LogIn className="w-3.5 h-3.5" /> Sign In
                        </Button>
                    )}
                </div>

                {!isAuthenticated && (
                    <Card className="border-dashed border-primary/40 bg-gradient-to-br from-primary/5 via-background to-accent/10">
                        <CardHeader className="pb-2">
                            <CardTitle className="text-sm font-semibold flex items-center gap-2">
                                <Shield className="w-4 h-4 text-primary" />
                                Cloud Safety Account
                            </CardTitle>
                            <CardDescription className="text-xs">
                                Create an account to sync emergency contacts, receive real-time SOS alerts, and backup data across devices.
                            </CardDescription>
                        </CardHeader>
                        <CardContent className="pt-0">
                            <Button size="sm" onClick={() => setAuthModalOpen(true)} className="w-full gap-2 text-xs font-semibold">
                                <LogIn className="w-4 h-4" /> Sign In to Edit & Sync Profile
                            </Button>
                        </CardContent>
                    </Card>
                )}

                {/* ---------------- Personal Details Card ---------------- */}
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-3">
                        <div>
                            <CardTitle className="text-base flex items-center gap-2">
                                <User className="w-4 h-4 text-primary" />
                                Personal Details
                            </CardTitle>
                            <CardDescription className="text-xs">Information shared with first responders during emergency.</CardDescription>
                        </div>
                        <Button variant="outline" size="sm" onClick={() => setEditProfileOpen(true)} className="h-8 gap-1 text-xs">
                            <Pencil className="w-3.5 h-3.5" /> Edit
                        </Button>
                    </CardHeader>
                    <CardContent className="space-y-3 text-sm pt-0">
                        <div className="flex justify-between items-center py-1 border-b border-border/40">
                            <span className="text-muted-foreground text-xs flex items-center gap-1.5">
                                <User className="w-3.5 h-3.5" /> Full Name:
                            </span>
                            <span className="font-semibold text-xs">{personalInfo.name || 'Not provided'}</span>
                        </div>
                        <div className="flex justify-between items-center py-1 border-b border-border/40">
                            <span className="text-muted-foreground text-xs flex items-center gap-1.5">
                                <Phone className="w-3.5 h-3.5" /> Emergency Phone:
                            </span>
                            <span className="font-semibold text-xs">{personalInfo.phone || 'Not provided'}</span>
                        </div>
                        <div className="flex justify-between items-center py-1 border-b border-border/40">
                            <span className="text-muted-foreground text-xs flex items-center gap-1.5">
                                <Mail className="w-3.5 h-3.5" /> Contact Email:
                            </span>
                            <span className="font-semibold text-xs truncate max-w-[180px]">{personalInfo.emergencyEmail || 'Not provided'}</span>
                        </div>
                        <div className="flex justify-between items-center py-1 border-b border-border/40">
                            <span className="text-muted-foreground text-xs flex items-center gap-1.5">
                                <MapPin className="w-3.5 h-3.5" /> Address / Home:
                            </span>
                            <span className="font-semibold text-xs truncate max-w-[180px]">{personalInfo.address || 'Not provided'}</span>
                        </div>
                        <div className="flex justify-between items-center py-1 border-b border-border/40">
                            <span className="text-muted-foreground text-xs flex items-center gap-1.5">
                                <Calendar className="w-3.5 h-3.5" /> DOB & Gender:
                            </span>
                            <span className="font-semibold text-xs">
                                {personalInfo.dob ? `${personalInfo.dob} (${personalInfo.gender})` : 'Not provided'}
                            </span>
                        </div>
                    </CardContent>
                </Card>

                {/* ---------------- Medical Information Card ---------------- */}
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-3">
                        <div>
                            <CardTitle className="text-base flex items-center gap-2">
                                <HeartPulse className="w-4 h-4 text-destructive" />
                                Medical Profile
                            </CardTitle>
                            <CardDescription className="text-xs">Critical medical data for paramedics & hospital care.</CardDescription>
                        </div>
                        <Button variant="outline" size="sm" onClick={() => setEditMedicalOpen(true)} className="h-8 gap-1 text-xs">
                            <Pencil className="w-3.5 h-3.5" /> Edit
                        </Button>
                    </CardHeader>
                    <CardContent className="space-y-3 text-sm pt-0">
                        <div className="flex justify-between items-center py-1 border-b border-border/40">
                            <span className="text-muted-foreground text-xs">Blood Group:</span>
                            <span className={`font-bold text-xs px-2 py-0.5 rounded ${medicalInfo.bloodGroup ? 'bg-destructive/10 text-destructive' : 'bg-muted text-muted-foreground'}`}>
                                {medicalInfo.bloodGroup || 'Not set'}
                            </span>
                        </div>
                        <div className="flex justify-between items-center py-1 border-b border-border/40">
                            <span className="text-muted-foreground text-xs">Allergies:</span>
                            <span className="font-semibold text-xs text-amber-500">{medicalInfo.allergies || 'None'}</span>
                        </div>
                        <div className="flex justify-between items-center py-1 border-b border-border/40">
                            <span className="text-muted-foreground text-xs">Medical Conditions:</span>
                            <span className="font-semibold text-xs">{medicalInfo.conditions || 'None'}</span>
                        </div>
                        {medicalInfo.notes && (
                            <div className="py-1">
                                <span className="text-muted-foreground text-xs block mb-1">Emergency Care Notes:</span>
                                <p className="text-xs bg-muted/60 p-2 rounded italic text-muted-foreground">
                                    &quot;{medicalInfo.notes}&quot;
                                </p>
                            </div>
                        )}
                    </CardContent>
                </Card>

                {/* ---------------- Emergency Contacts Card ---------------- */}
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <div>
                            <CardTitle className="text-base flex items-center gap-2">
                                <Phone className="w-4 h-4 text-primary" />
                                Emergency Contacts ({userContacts.length})
                            </CardTitle>
                            <CardDescription className="text-xs">Alerted immediately with location during an SOS emergency.</CardDescription>
                        </div>
                        <Button size="sm" onClick={() => setAddContactOpen(true)} className="h-8 gap-1 text-xs font-semibold">
                            <Plus className="w-3.5 h-3.5" /> Add
                        </Button>
                    </CardHeader>
                    <CardContent className="p-0">
                        {userContacts.length === 0 ? (
                            <div className="p-6 text-center text-muted-foreground text-xs">
                                No emergency contacts added yet. Click &quot;Add&quot; above to set one.
                            </div>
                        ) : (
                            <div className="divide-y">
                                {userContacts.map((contact) => {
                                    const avatarUrl = (contact as any).avatarUrl;
                                    return (
                                        <div key={contact.id} className="flex items-center space-x-3 px-4 py-3 hover:bg-muted/50 transition-colors">
                                            <Avatar className="h-10 w-10 shrink-0">
                                                {avatarUrl && (
                                                    <AvatarImage src={avatarUrl} alt={contact.name} />
                                                )}
                                                <AvatarFallback>{contact.name.charAt(0).toUpperCase()}</AvatarFallback>
                                            </Avatar>
                                            <div className="flex-grow min-w-0">
                                                <div className="flex items-center gap-1.5">
                                                    <p className="font-semibold text-xs truncate">{contact.name}</p>
                                                    {contact.isPrimary && (
                                                        <span className="text-[10px] px-1.5 py-0.2 rounded bg-primary/10 text-primary font-medium">
                                                            Primary
                                                        </span>
                                                    )}
                                                </div>
                                                <p className="text-[11px] text-muted-foreground truncate">{contact.phone} • {contact.relation}</p>
                                            </div>
                                            <div className="flex items-center gap-1 shrink-0">
                                                <Button variant="ghost" size="icon" className="h-8 w-8" onClick={() => handleCallContact(contact)} title="Call">
                                                    <Phone className="w-4 h-4 text-primary" />
                                                </Button>
                                                <Button
                                                    variant="ghost"
                                                    size="icon"
                                                    className="h-8 w-8 text-destructive hover:bg-destructive/10"
                                                    onClick={() => handleDeleteContact(contact.id, contact.name)}
                                                    title="Delete Contact"
                                                >
                                                    <Trash2 className="w-4 h-4" />
                                                </Button>
                                            </div>
                                        </div>
                                    );
                                })}
                            </div>
                        )}
                    </CardContent>
                </Card>

                {/* ---------------- Guardians Section ---------------- */}
                <Card>
                    <CardHeader>
                        <CardTitle className="text-base flex items-center gap-2">
                            <Users className="w-4 h-4 text-primary" />
                            Live Guardians
                        </CardTitle>
                        <CardDescription className="text-xs">Trusted individuals permitted to track your live GPS route.</CardDescription>
                    </CardHeader>
                    <CardContent className="p-0">
                        {userContacts.length === 0 ? (
                            <div className="flex flex-col items-center gap-2 py-6 text-center px-4">
                                <Users className="w-8 h-8 text-muted-foreground/50" />
                                <p className="text-xs text-muted-foreground">No guardians added yet. Add emergency contacts above to see them here.</p>
                            </div>
                        ) : (
                            <div className="divide-y">
                                {userContacts.map((contact) => {
                                    const avatarUrl = (contact as any).avatarUrl;
                                    return (
                                        <div key={contact.id} className="flex items-center space-x-3 px-4 py-3 hover:bg-muted/50 transition-colors">
                                            <Avatar className="h-10 w-10 shrink-0">
                                                {avatarUrl && (
                                                    <AvatarImage src={avatarUrl} alt={contact.name} />
                                                )}
                                                <AvatarFallback>{contact.name.charAt(0).toUpperCase()}</AvatarFallback>
                                            </Avatar>
                                            <div className="flex-grow min-w-0">
                                                <p className="font-semibold text-xs truncate">{contact.name}</p>
                                                <p className="text-[11px] text-muted-foreground">{contact.phone} • {contact.relation}</p>
                                            </div>
                                            <Shield className="w-4 h-4 text-emerald-500 shrink-0" />
                                        </div>
                                    );
                                })}
                            </div>
                        )}
                    </CardContent>
                </Card>

                {/* ---------------- Settings Card ---------------- */}
                <Card>
                    <CardHeader>
                        <CardTitle className="text-base flex items-center gap-2">
                            <Settings className="w-4 h-4 text-primary" />
                            App Settings
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <SettingsItem icon={Globe} title="App Language" description="Select preferred display language">
                            <Select defaultValue="en">
                                <SelectTrigger className="w-[130px] h-8 text-xs">
                                    <SelectValue placeholder="Language" />
                                </SelectTrigger>
                                <SelectContent portalContainer={portalContainer} className="max-w-[220px]">
                                    <SelectItem value="en">English</SelectItem>
                                    <SelectItem value="hi">Hindi (हिन्दी)</SelectItem>
                                    <SelectItem value="mr">Marathi (मराठी)</SelectItem>
                                    <SelectItem value="bn">Bengali (বাংলা)</SelectItem>
                                    <SelectItem value="gu">Gujarati (ગુજરાતી)</SelectItem>
                                    <SelectItem value="ta">Tamil (தமிழ்)</SelectItem>
                                    <SelectItem value="te">Telugu (తెలుగు)</SelectItem>
                                </SelectContent>
                            </Select>
                        </SettingsItem>

                        <SettingsItem icon={theme === 'dark' ? Moon : Sun} title="Dark Mode" description="Toggle theme appearance">
                            <Switch
                                checked={theme === 'dark'}
                                onCheckedChange={() => setTheme(theme === 'light' ? 'dark' : 'light')}
                                aria-label="Toggle dark mode"
                            />
                        </SettingsItem>
                    </CardContent>
                </Card>
            </div>

            {/* =========================================================================== */}
            {/* Modal 1: Edit Personal Information */}
            {/* =========================================================================== */}
            <Dialog open={editProfileOpen} onOpenChange={setEditProfileOpen}>
                <DialogContent portalContainer={portalContainer} className="w-[92%] max-w-[360px] rounded-2xl p-4 max-h-[85vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle className="text-base flex items-center gap-2">
                            <User className="w-4 h-4 text-primary" />
                            Edit Personal Details
                        </DialogTitle>
                        <DialogDescription className="text-xs">
                            Update your contact and identification details.
                        </DialogDescription>
                    </DialogHeader>

                    <form onSubmit={handleSaveProfile} className="space-y-3 pt-2">
                        <div className="space-y-1">
                            <Label className="text-xs">Full Name</Label>
                            <Input
                                value={personalInfo.name}
                                onChange={(e) => setPersonalInfo({ ...personalInfo, name: e.target.value })}
                                placeholder="e.g. Priya Sharma"
                                required
                                className="h-9 text-xs"
                            />
                        </div>

                        <div className="space-y-1">
                            <Label className="text-xs">Emergency Phone</Label>
                            <Input
                                value={personalInfo.phone}
                                onChange={(e) => setPersonalInfo({ ...personalInfo, phone: e.target.value })}
                                placeholder="e.g. +91 98765 43210"
                                required
                                className="h-9 text-xs"
                            />
                        </div>

                        <div className="space-y-1">
                            <Label className="text-xs">Emergency Contact Email</Label>
                            <Input
                                type="email"
                                value={personalInfo.emergencyEmail}
                                onChange={(e) => setPersonalInfo({ ...personalInfo, emergencyEmail: e.target.value })}
                                placeholder="e.g. contact@example.com"
                                className="h-9 text-xs"
                            />
                        </div>

                        <div className="space-y-1">
                            <Label className="text-xs">Home Address / Location</Label>
                            <Input
                                value={personalInfo.address}
                                onChange={(e) => setPersonalInfo({ ...personalInfo, address: e.target.value })}
                                placeholder="e.g. Mumbai, India"
                                className="h-9 text-xs"
                            />
                        </div>

                        <div className="grid grid-cols-2 gap-2">
                            <div className="space-y-1">
                                <Label className="text-xs">Date of Birth</Label>
                                <Input
                                    type="date"
                                    value={personalInfo.dob}
                                    onChange={(e) => setPersonalInfo({ ...personalInfo, dob: e.target.value })}
                                    className="h-9 text-xs"
                                />
                            </div>

                            <div className="space-y-1">
                                <Label className="text-xs">Gender</Label>
                                <Select
                                    value={personalInfo.gender}
                                    onValueChange={(val) => setPersonalInfo({ ...personalInfo, gender: val })}
                                >
                                    <SelectTrigger className="h-9 text-xs">
                                        <SelectValue placeholder="Gender" />
                                    </SelectTrigger>
                                    <SelectContent portalContainer={portalContainer}>
                                        <SelectItem value="Female">Female</SelectItem>
                                        <SelectItem value="Male">Male</SelectItem>
                                        <SelectItem value="Non-binary">Non-binary</SelectItem>
                                        <SelectItem value="Prefer not to say">Other</SelectItem>
                                    </SelectContent>
                                </Select>
                            </div>
                        </div>

                        <DialogFooter className="pt-2">
                            <Button type="button" variant="outline" size="sm" onClick={() => setEditProfileOpen(false)}>
                                Cancel
                            </Button>
                            <Button type="submit" size="sm" disabled={isSavingProfile}>
                                {isSavingProfile ? <Loader2 className="w-3.5 h-3.5 animate-spin mr-1" /> : <Check className="w-3.5 h-3.5 mr-1" />}
                                Save Details
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* =========================================================================== */}
            {/* Modal 2: Edit Medical Profile */}
            {/* =========================================================================== */}
            <Dialog open={editMedicalOpen} onOpenChange={setEditMedicalOpen}>
                <DialogContent portalContainer={portalContainer} className="w-[92%] max-w-[360px] rounded-2xl p-4 max-h-[85vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle className="text-base flex items-center gap-2">
                            <HeartPulse className="w-4 h-4 text-destructive" />
                            Edit Medical Profile
                        </DialogTitle>
                        <DialogDescription className="text-xs">
                            Essential health data accessed by emergency personnel.
                        </DialogDescription>
                    </DialogHeader>

                    <form onSubmit={handleSaveMedical} className="space-y-3 pt-2">
                        <div className="space-y-1">
                            <Label className="text-xs">Blood Group</Label>
                            <Select
                                value={medicalInfo.bloodGroup}
                                onValueChange={(val) => setMedicalInfo({ ...medicalInfo, bloodGroup: val })}
                            >
                                <SelectTrigger className="h-9 text-xs">
                                    <SelectValue placeholder="Select Blood Group" />
                                </SelectTrigger>
                                <SelectContent portalContainer={portalContainer}>
                                    {['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((bg) => (
                                        <SelectItem key={bg} value={bg}>{bg}</SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>

                        <div className="space-y-1">
                            <Label className="text-xs">Known Allergies</Label>
                            <Input
                                value={medicalInfo.allergies}
                                onChange={(e) => setMedicalInfo({ ...medicalInfo, allergies: e.target.value })}
                                placeholder="e.g. Peanuts, Penicillin, Dust (or None)"
                                className="h-9 text-xs"
                            />
                        </div>

                        <div className="space-y-1">
                            <Label className="text-xs">Medical Conditions</Label>
                            <Input
                                value={medicalInfo.conditions}
                                onChange={(e) => setMedicalInfo({ ...medicalInfo, conditions: e.target.value })}
                                placeholder="e.g. Asthma, Diabetes, Hypertension"
                                className="h-9 text-xs"
                            />
                        </div>

                        <div className="space-y-1">
                            <Label className="text-xs">Special Emergency Instructions / Notes</Label>
                            <Input
                                value={medicalInfo.notes}
                                onChange={(e) => setMedicalInfo({ ...medicalInfo, notes: e.target.value })}
                                placeholder="e.g. Carries inhaler in purse."
                                className="h-9 text-xs"
                            />
                        </div>

                        <DialogFooter className="pt-2">
                            <Button type="button" variant="outline" size="sm" onClick={() => setEditMedicalOpen(false)}>
                                Cancel
                            </Button>
                            <Button type="submit" size="sm" disabled={isSavingMedical}>
                                {isSavingMedical ? <Loader2 className="w-3.5 h-3.5 animate-spin mr-1" /> : <Check className="w-3.5 h-3.5 mr-1" />}
                                Save Medical Info
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* =========================================================================== */}
            {/* Modal 3: Add Emergency Contact */}
            {/* =========================================================================== */}
            <AddContactModal
                open={addContactOpen}
                onOpenChange={setAddContactOpen}
                portalContainer={portalContainer}
                onAdd={handleAddContact}
                isSaving={isSavingContact}
            />
        </div>
    );
}

// ---------------------------------------------------------------------------
// Add Contact Sub-Modal Component
// ---------------------------------------------------------------------------
function AddContactModal({
    open,
    onOpenChange,
    portalContainer,
    onAdd,
    isSaving,
}: {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    portalContainer: HTMLElement | null;
    onAdd: (contact: { name: string; phone: string; relation: string; email?: string; isPrimary: boolean }) => void;
    isSaving: boolean;
}) {
    const [name, setName] = useState('');
    const [phone, setPhone] = useState('');
    const [relation, setRelation] = useState('Family');
    const [email, setEmail] = useState('');
    const [isPrimary, setIsPrimary] = useState(false);

    const handleSubmit = (e: FormEvent) => {
        e.preventDefault();
        if (!name.trim() || !phone.trim()) return;
        onAdd({ name: name.trim(), phone: phone.trim(), relation, email: email.trim(), isPrimary });
        setName('');
        setPhone('');
        setEmail('');
        setIsPrimary(false);
    };

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent portalContainer={portalContainer} className="w-[92%] max-w-[360px] rounded-2xl p-4 max-h-[85vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle className="text-base flex items-center gap-2">
                        <Phone className="w-4 h-4 text-primary" />
                        Add Emergency Contact
                    </DialogTitle>
                    <DialogDescription className="text-xs">
                        This contact will receive live SOS alerts & location links.
                    </DialogDescription>
                </DialogHeader>

                <form onSubmit={handleSubmit} className="space-y-3 pt-2">
                    <div className="space-y-1">
                        <Label className="text-xs">Contact Name</Label>
                        <Input
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                            placeholder="e.g. Brother, Mom, Dr. Sharma"
                            required
                            className="h-9 text-xs"
                        />
                    </div>

                    <div className="space-y-1">
                        <Label className="text-xs">Phone Number</Label>
                        <Input
                            value={phone}
                            onChange={(e) => setPhone(e.target.value)}
                            placeholder="e.g. +91 98765 43210"
                            required
                            className="h-9 text-xs"
                        />
                    </div>

                    <div className="space-y-1">
                        <Label className="text-xs">Relation / Category</Label>
                        <Select value={relation} onValueChange={setRelation}>
                            <SelectTrigger className="h-9 text-xs">
                                <SelectValue placeholder="Select Relation" />
                            </SelectTrigger>
                            <SelectContent portalContainer={portalContainer}>
                                <SelectItem value="Family">Family</SelectItem>
                                <SelectItem value="Friend">Friend</SelectItem>
                                <SelectItem value="Guardian">Guardian</SelectItem>
                                <SelectItem value="Doctor">Doctor / Medical</SelectItem>
                                <SelectItem value="Emergency Services">Emergency Services</SelectItem>
                                <SelectItem value="Neighbor">Neighbor</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>

                    <div className="space-y-1">
                        <Label className="text-xs">Email (Optional)</Label>
                        <Input
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder="contact@example.com"
                            className="h-9 text-xs"
                        />
                    </div>

                    <div className="flex items-center space-x-2 pt-1">
                        <input
                            type="checkbox"
                            id="isPrimaryContact"
                            checked={isPrimary}
                            onChange={(e) => setIsPrimary(e.target.checked)}
                            className="rounded border-gray-300 text-primary focus:ring-primary h-4 w-4"
                        />
                        <label htmlFor="isPrimaryContact" className="text-xs text-muted-foreground cursor-pointer">
                            Mark as Primary Emergency Contact
                        </label>
                    </div>

                    <DialogFooter className="pt-2">
                        <Button type="button" variant="outline" size="sm" onClick={() => onOpenChange(false)}>
                            Cancel
                        </Button>
                        <Button type="submit" size="sm" disabled={isSaving}>
                            {isSaving ? <Loader2 className="w-3.5 h-3.5 animate-spin mr-1" /> : <Plus className="w-3.5 h-3.5 mr-1" />}
                            Add Contact
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}
