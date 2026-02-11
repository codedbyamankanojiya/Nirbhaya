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
            callerSubtext="Samsung Galaxy S25+ 5G"
            callerInitial="M"
            callerAvatar="/contacts/mom.png"
            autoAnswer={false}
        />
    );
}
