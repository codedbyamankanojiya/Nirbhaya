"use client";

import CallScreen from './call-screen';

interface FakeCallScreenProps {
    onHangUp: () => void;
}

export default function FakeCallScreen({ onHangUp }: FakeCallScreenProps) {
    return (
        <CallScreen
            onHangUp={onHangUp}
            callerName="Mom"
            callerSubtext="iPhone"
            callerInitial="M"
            autoAnswer={false}
        />
    );
}
