"use client";

import { useEffect, useState } from 'react';
import { Phone, PhoneOff } from 'lucide-react';
import { Avatar, AvatarFallback, AvatarImage } from '../ui/avatar';

interface CallScreenProps {
    onHangUp: () => void;
    callerName?: string;
    callerSubtext?: string;
    callerInitial?: string;
    callerAvatar?: string;
    autoAnswer?: boolean;
}

export default function CallScreen({
    onHangUp,
    callerName = "Mom",
    callerSubtext = "iPhone",
    callerInitial = "M",
    callerAvatar,
    autoAnswer = false
}: CallScreenProps) {
    const [callStatus, setCallStatus] = useState<'ringing' | 'active'>(autoAnswer ? 'active' : 'ringing');
    const [timer, setTimer] = useState(0);

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
        <div className="absolute inset-0 bg-gradient-to-b from-gray-900 via-gray-800 to-gray-900 z-50 flex flex-col items-center justify-between text-white p-8">
            {/* Top Section - Caller Info */}
            <div className="text-center mt-16 flex flex-col items-center">
                <Avatar className="w-32 h-32 border-4 border-white/20 mb-6">
                    {callerAvatar && <AvatarImage src={callerAvatar} alt={callerName} />}
                    <AvatarFallback className="text-4xl bg-gray-700">{callerInitial}</AvatarFallback>
                </Avatar>
                <h1 className="text-4xl font-bold mb-2">{callerName}</h1>
                <p className="text-xl text-gray-400">
                    {callStatus === 'ringing' ? callerSubtext : formatTime(timer)}
                </p>
            </div>

            {/* Middle Section - Call Status */}
            <div className="flex flex-col items-center">
                {callStatus === 'ringing' && (
                    <div className="flex flex-col items-center gap-2 animate-pulse">
                        <div className="w-16 h-16 rounded-full bg-green-500/20 flex items-center justify-center">
                            <Phone className="w-8 h-8 text-green-400" />
                        </div>
                        <p className="text-lg text-gray-300">Incoming Call...</p>
                    </div>
                )}
                {callStatus === 'active' && (
                    <div className="flex flex-col items-center gap-2">
                        <div className="w-3 h-3 rounded-full bg-green-500 animate-pulse"></div>
                        <p className="text-sm text-gray-400">Call in progress</p>
                    </div>
                )}
            </div>

            {/* Bottom Section - Action Buttons */}
            <div className="w-full flex justify-around items-center mb-12">
                {callStatus === 'ringing' && (
                    <button
                        onClick={() => setCallStatus('active')}
                        className="flex flex-col items-center gap-3 active:scale-95 transition-transform"
                    >
                        <div className="w-20 h-20 rounded-full bg-green-500 flex items-center justify-center shadow-lg shadow-green-500/50 hover:bg-green-600 transition-colors">
                            <Phone className="w-9 h-9 text-white" />
                        </div>
                        <span className="text-sm font-medium text-gray-300">Accept</span>
                    </button>
                )}

                <button
                    onClick={onHangUp}
                    className="flex flex-col items-center gap-3 active:scale-95 transition-transform"
                >
                    <div className="w-20 h-20 rounded-full bg-red-500 flex items-center justify-center shadow-lg shadow-red-500/50 hover:bg-red-600 transition-colors">
                        <PhoneOff className="w-9 h-9 text-white" />
                    </div>
                    <span className="text-sm font-medium text-gray-300">
                        {callStatus === 'ringing' ? 'Decline' : 'End Call'}
                    </span>
                </button>
            </div>
        </div>
    );
}
