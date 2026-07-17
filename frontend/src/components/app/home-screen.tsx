
"use client";

import type { FC } from "react";
import { useEffect, useMemo, useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import { useToast } from "@/hooks/use-toast";
import { Phone, Video, Shield, Siren } from "lucide-react";
import type { ScreenId } from "@/app/page";
import AppHeader from "./app-header";
import { AlertDialogTrigger } from "@radix-ui/react-alert-dialog";

interface ScreenProps {
    onNavigate: (screen: ScreenId) => void;
    onFakeCall: () => void;
    onBack: () => void;
    isHomeScreen: boolean;
}

const ActionButton: FC<{ icon: React.ElementType, title: string, onClick: () => void }> = ({ icon: Icon, title, onClick }) => (
    <div className="flex flex-col items-center gap-2">
        <Button onClick={onClick} variant="outline" size="icon" className="w-16 h-16 rounded-2xl bg-card shadow-sm hover:bg-muted transition-colors border">
            <Icon className="w-7 h-7 text-primary" />
        </Button>
        <p className="text-sm font-medium text-foreground">{title}</p>
    </div>
);

export default function HomeScreen({ onNavigate, onFakeCall, onBack, isHomeScreen }: ScreenProps) {
    const { toast } = useToast();
    const [isSosPressed, setIsSosPressed] = useState(false);

    const [isRecordDialogOpen, setIsRecordDialogOpen] = useState(false);
    const previewVideoRef = useRef<HTMLVideoElement | null>(null);
    const streamRef = useRef<MediaStream | null>(null);
    const recorderRef = useRef<MediaRecorder | null>(null);
    const chunksRef = useRef<BlobPart[]>([]);
    const [isInitializingCamera, setIsInitializingCamera] = useState(false);
    const [isRecording, setIsRecording] = useState(false);
    const [recordedUrl, setRecordedUrl] = useState<string | null>(null);
    const [recordError, setRecordError] = useState<string | null>(null);
    const [hasStream, setHasStream] = useState(false);
    const [dialogPortalContainer, setDialogPortalContainer] = useState<HTMLElement | null>(null);

    const mediaRecorderSupported = useMemo(() => {
        return typeof window !== "undefined" && "MediaRecorder" in window;
    }, []);

    const stopStreamTracks = () => {
        const stream = streamRef.current;
        if (!stream) return;
        for (const track of stream.getTracks()) {
            try {
                track.stop();
            } catch {
                // ignore
            }
        }
        streamRef.current = null;
        setHasStream(false);
    };

    const cleanupRecorder = () => {
        recorderRef.current = null;
        chunksRef.current = [];
    };

    const resetRecordingOutput = () => {
        if (recordedUrl) {
            URL.revokeObjectURL(recordedUrl);
        }
        setRecordedUrl(null);
    };

    const pickMimeType = () => {
        const candidates = [
            "video/webm;codecs=vp9,opus",
            "video/webm;codecs=vp8,opus",
            "video/webm",
            "video/mp4",
        ];
        for (const type of candidates) {
            try {
                if (typeof MediaRecorder !== "undefined" && MediaRecorder.isTypeSupported(type)) return type;
            } catch {
                // ignore
            }
        }
        return "";
    };

    const attachStreamToPreview = (stream: MediaStream) => {
        const el = previewVideoRef.current;
        if (!el) return;
        try {
            el.srcObject = stream;
            void el.play();
        } catch {
            // ignore
        }
    };

    const initCamera = async () => {
        if (isInitializingCamera) return;
        setIsInitializingCamera(true);
        setRecordError(null);

        try {
            if (typeof window !== "undefined" && !window.isSecureContext) {
                setRecordError("Camera access requires HTTPS (or localhost). Open the site over HTTPS and try again.");
                return;
            }
            stopStreamTracks();
            cleanupRecorder();

            if (!navigator.mediaDevices?.getUserMedia) {
                setRecordError("Camera is not available in this browser.");
                return;
            }

            const stream = await navigator.mediaDevices.getUserMedia({
                video: { facingMode: { ideal: "environment" } },
                audio: true,
            });
            streamRef.current = stream;
            setHasStream(true);
            attachStreamToPreview(stream);
        } catch (err: any) {
            const message =
                err?.name === "NotAllowedError"
                    ? "Camera/Microphone permission was denied. Please allow access and try again."
                    : err?.name === "NotFoundError"
                        ? "No camera was found on this device."
                        : "Unable to access camera/microphone.";
            setRecordError(message);
        } finally {
            setIsInitializingCamera(false);
        }
    };

    const startRecording = () => {
        setRecordError(null);
        resetRecordingOutput();

        const stream = streamRef.current;
        if (!stream) {
            setRecordError("Camera is not started yet.");
            return;
        }
        if (!mediaRecorderSupported) {
            setRecordError("Video recording is not supported in this browser.");
            return;
        }

        try {
            const mimeType = pickMimeType();
            const recorder = new MediaRecorder(stream, mimeType ? { mimeType } : undefined);
            recorderRef.current = recorder;
            chunksRef.current = [];

            recorder.ondataavailable = (e: BlobEvent) => {
                if (e.data && e.data.size > 0) {
                    chunksRef.current.push(e.data);
                }
            };

            recorder.onstop = () => {
                const chunks = chunksRef.current;
                const blob = new Blob(chunks, { type: recorder.mimeType || "video/webm" });
                const url = URL.createObjectURL(blob);
                setRecordedUrl(url);
                setIsRecording(false);
                cleanupRecorder();
            };

            recorder.onerror = () => {
                setRecordError("Recording error occurred.");
                setIsRecording(false);
            };

            recorder.start();
            setIsRecording(true);
        } catch {
            setRecordError("Unable to start recording.");
        }
    };

    const stopRecording = () => {
        const recorder = recorderRef.current;
        if (!recorder) return;
        try {
            recorder.stop();
        } catch {
            setIsRecording(false);
        }
    };

    const handleEvidenceCapture = async () => {
        setIsRecordDialogOpen(true);
        toast({
            title: "Evidence Capture",
            description: "Opening camera…",
            duration: 2000,
        });
        await initCamera();
    };

    const handleFallbackFilePicked: React.ChangeEventHandler<HTMLInputElement> = (e) => {
        const file = e.target.files?.[0];
        if (!file) return;
        resetRecordingOutput();
        const url = URL.createObjectURL(file);
        setRecordedUrl(url);
    };

    const handleSos = () => {
        toast({
            title: "SOS Activated!",
            description: "Emergency alerts sent to contacts and authorities.",
            variant: "destructive",
            duration: 5000,
        });
    };

    useEffect(() => {
        if (!isRecordDialogOpen) {
            setIsRecording(false);
            setIsInitializingCamera(false);
            setRecordError(null);
            cleanupRecorder();
            stopStreamTracks();
            resetRecordingOutput();
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [isRecordDialogOpen]);

    useEffect(() => {
        return () => {
            cleanupRecorder();
            stopStreamTracks();
            if (recordedUrl) URL.revokeObjectURL(recordedUrl);
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    useEffect(() => {
        if (typeof document === "undefined") return;
        const el = document.getElementById("app-shell-container");
        setDialogPortalContainer(el);
    }, []);


    return (
        <div className="h-full flex flex-col app-gradient">
            <AppHeader title="Priya" showBackButton={!isHomeScreen} onBack={onBack} welcomeMessage="Welcome Back," />

            <Dialog open={isRecordDialogOpen} onOpenChange={setIsRecordDialogOpen}>
                <DialogContent
                    portalContainer={dialogPortalContainer}
                    mobileFullScreen
                    className="p-0 overflow-hidden sm:p-0 sm:max-h-[90vh] sm:overflow-hidden"
                >
                    <div className="flex flex-col h-screen min-h-[100dvh] sm:h-auto sm:min-h-0 sm:max-h-[90vh] sm:overflow-hidden">
                        <div className="bg-black">
                            <video
                                ref={previewVideoRef}
                                playsInline
                                muted
                                autoPlay
                                className="w-full h-[52dvh] max-h-[420px] object-cover sm:h-[42vh] sm:max-h-[360px]"
                            />
                        </div>

                        <div className="p-4 space-y-3 overflow-y-auto flex-1 min-h-0">
                            <DialogHeader>
                                <DialogTitle>Record Evidence</DialogTitle>
                                <DialogDescription>
                                    Grant camera/microphone access, then start recording.
                                </DialogDescription>
                            </DialogHeader>

                            {recordError ? (
                                <p className="text-sm text-destructive">{recordError}</p>
                            ) : null}

                            {!hasStream ? (
                                <Button
                                    onClick={initCamera}
                                    disabled={isInitializingCamera}
                                    className="w-full"
                                >
                                    {isInitializingCamera ? "Starting Camera…" : "Start Camera"}
                                </Button>
                            ) : null}

                            {hasStream && mediaRecorderSupported ? (
                                <div className="grid grid-cols-2 gap-3">
                                    <Button
                                        onClick={startRecording}
                                        disabled={isRecording}
                                        className="w-full"
                                    >
                                        Start
                                    </Button>
                                    <Button
                                        onClick={stopRecording}
                                        disabled={!isRecording}
                                        variant="destructive"
                                        className="w-full"
                                    >
                                        Stop
                                    </Button>
                                </div>
                            ) : null}

                            {!mediaRecorderSupported ? (
                                <div className="space-y-2">
                                    <p className="text-sm text-muted-foreground">
                                        This browser does not support in-app recording. Use the fallback capture below.
                                    </p>
                                    <input
                                        type="file"
                                        accept="video/*"
                                        capture="environment"
                                        onChange={handleFallbackFilePicked}
                                        className="block w-full text-sm"
                                    />
                                </div>
                            ) : null}

                            {recordedUrl ? (
                                <div className="space-y-3">
                                    <video controls playsInline src={recordedUrl} className="w-full rounded-md" />
                                    <a
                                        href={recordedUrl}
                                        download={`evidence-${new Date().toISOString().replace(/[:.]/g, "-")}.webm`}
                                        className="inline-flex w-full"
                                    >
                                        <Button className="w-full" variant="outline">
                                            Download Video
                                        </Button>
                                    </a>
                                </div>
                            ) : null}

                            <DialogFooter>
                                <Button
                                    variant="outline"
                                    className="w-full"
                                    onClick={() => setIsRecordDialogOpen(false)}
                                >
                                    Close
                                </Button>
                            </DialogFooter>
                        </div>
                    </div>
                </DialogContent>
            </Dialog>

            <div className="flex-grow flex flex-col justify-center items-center px-6 space-y-4">
                <AlertDialog>
                    <AlertDialogTrigger asChild>
                        <button
                            onMouseDown={() => setIsSosPressed(true)}
                            onMouseUp={() => setIsSosPressed(false)}
                            onTouchStart={() => setIsSosPressed(true)}
                            onTouchEnd={() => setIsSosPressed(false)}
                            onMouseLeave={() => setIsSosPressed(false)}
                            className="relative flex flex-col items-center justify-center w-52 h-52 rounded-full bg-red-500/10 transition-transform duration-200 active:scale-95"
                        >
                            <div className="absolute inset-0 rounded-full bg-red-500/20 animate-sos-pulse"></div>
                            <div className={`absolute inset-3 rounded-full bg-destructive shadow-lg flex flex-col items-center justify-center text-destructive-foreground transition-transform duration-200 ${isSosPressed ? 'scale-90' : 'scale-100'}`}>
                                <Siren className="w-20 h-20" />
                                <span className="text-2xl font-bold tracking-widest mt-1">SOS</span>
                            </div>
                        </button>
                    </AlertDialogTrigger>
                    <AlertDialogContent>
                        <AlertDialogHeader>
                            <AlertDialogTitle>Activate Emergency SOS?</AlertDialogTitle>
                            <AlertDialogDescription>
                                This will send your live location and an emergency alert to your guardians and local authorities. Are you sure?
                            </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                            <AlertDialogCancel>Cancel</AlertDialogCancel>
                            <AlertDialogAction onClick={handleSos} className="bg-destructive hover:bg-destructive/90">
                                Activate SOS
                            </AlertDialogAction>
                        </AlertDialogFooter>
                    </AlertDialogContent>
                </AlertDialog>
                <p className="text-muted-foreground text-center max-w-xs pt-4">Press the button to send an SOS alert to your emergency contacts.</p>
            </div>

            <div className="px-6 py-6 space-y-4 bg-card/60 backdrop-blur-xl rounded-t-3xl border-t">
                <div className="flex justify-around">
                    <ActionButton icon={Phone} title="Fake Call" onClick={onFakeCall} />
                    <ActionButton icon={Video} title="Record" onClick={handleEvidenceCapture} />
                    <ActionButton icon={Shield} title="Safety Tips" onClick={() => onNavigate('resources')} />
                </div>
            </div>
        </div>
    );
}
