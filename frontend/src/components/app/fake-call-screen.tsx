"use client";

import { useEffect, useState } from 'react';
import CallScreen from './call-screen';
import { useAuth } from '@/context/auth-context';

interface FakeCallScreenProps {
    onHangUp: () => void;
}

export default function FakeCallScreen({ onHangUp }: FakeCallScreenProps) {
    const { isAuthenticated } = useAuth();
    const [caller, setCaller] = useState({
        name: 'Mom',
        subtext: 'Incoming Call',
        initial: 'M',
        avatar: '',
    });

    useEffect(() => {
        // Try to load primary contact from localStorage
        const storedContacts = typeof window !== 'undefined' ? localStorage.getItem('nirbhaya_user_contacts') : null;
        if (storedContacts) {
            try {
                const contacts = JSON.parse(storedContacts);
                const primary = contacts.find((c: any) => c.isPrimary) || contacts[0];
                if (primary) {
                    setCaller({
                        name: primary.name,
                        subtext: 'Incoming Call',
                        initial: primary.name.charAt(0).toUpperCase(),
                        avatar: '',
                    });
                }
            } catch {
                // Keep default
            }
        }
    }, [isAuthenticated]);

    return (
        <CallScreen
            onHangUp={onHangUp}
            callerName={caller.name}
            callerSubtext={caller.subtext}
            callerInitial={caller.initial}
            callerAvatar={caller.avatar}
            autoAnswer={false}
        />
    );
}
