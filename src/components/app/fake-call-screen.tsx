"use client";

import { useEffect, useState } from 'react';
import { Phone, PhoneOff } from 'lucide-react';
import { Avatar, AvatarFallback, AvatarImage } from '../ui/avatar';
import { getPlaceholderImage } from '@/lib/placeholder-images';

interface FakeCallScreenProps {
    onHangUp: () => void;
}

export default function FakeCallScreen({ onHangUp }: FakeCallScreenProps) {
    const [callStatus, setCallStatus] = useState<'ringing' | 'active'>('ringing');
    const [timer, setTimer] = useState(0);

    const callerAvatar = getPlaceholderImage('guardian-2');

    useEffect(() => {
        let interval: NodeJS.Timeout;
        if (callStatus === 'active') {
            interval = setInterval(() => {
                setTimer((prev) => prev + 1);
            }, 1000);
        }
        return () => clearInterval(interval);
    }, [callStatus]);

    const formatTime = (seconds: number) => {
        const mins = Math.floor(seconds / 60).toString().padStart(2, '0');
        const secs = (seconds % 60).toString().padStart(2, '0');
        return `${mins}:${secs}`;
    };

    return (
        <div className="absolute inset-0 bg-gray-900 z-50 flex flex-col items-center justify-between text-white p-8">
            <div className="text-center mt-12">
                <h1 className="text-4xl font-bold mt-2">Mom</h1>
                <p className="text-xl opacity-80 mt-2">
                    {callStatus === 'ringing' ? 'iPhone' : formatTime(timer)}
                </p>
            </div>

            <div className="flex flex-col items-center">
                <Avatar className="w-32 h-32 border-4 border-white/20 mb-8">
                    {callerAvatar && <AvatarImage src={callerAvatar.imageUrl} alt="Caller" />}
                    <AvatarFallback>M</AvatarFallback>
                </Avatar>
            </div>

            <div className="w-full flex justify-around items-center mb-8">
                {callStatus === 'ringing' && (
                    <button
                        onClick={() => setCallStatus('active')}
                        className="flex flex-col items-center gap-2"
                    >
                        <div className="w-20 h-20 rounded-full bg-green-500/90 flex items-center justify-center hover:bg-green-500 transition-colors">
                            <Phone className="w-9 h-9 text-white" />
                        </div>
                        <span className="text-sm font-medium">Accept</span>
                    </button>
                )}

                <button onClick={onHangUp} className="flex flex-col items-center gap-2">
                    <div className="w-20 h-20 rounded-full bg-red-500/90 flex items-center justify-center hover:bg-red-500 transition-colors">
                        <PhoneOff className="w-9 h-9 text-white" />
                    </div>
                    <span className="text-sm font-medium">{callStatus === 'ringing' ? 'Decline' : 'Hang Up'}</span>
                </button>
            </div>
        </div>
    );
}
