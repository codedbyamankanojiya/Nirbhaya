"use client";

import { useState } from 'react';
import type { FC } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Skeleton } from '@/components/ui/skeleton';
import { useToast } from '@/hooks/use-toast';
import { getPlaceholderImage } from '@/lib/placeholder-images';
import { generateCrimeHotspotMap, type CrimeHotspotMapOutput } from '@/ai/flows/ai-crime-hotspot-map';
import { Lightbulb, ShieldCheck, Map } from 'lucide-react';
import AppHeader from './app-header';

export default function MapScreen({ onBack }: { onBack: () => void }) {
    const { toast } = useToast();
    const [location, setLocation] = useState('Bandra, Mumbai');
    const [loading, setLoading] = useState(false);
    const [mapData, setMapData] = useState<CrimeHotspotMapOutput | null>(null);

    const buildDemoMapData = (loc: string, time: string): CrimeHotspotMapOutput => {
        return {
            crimeHeatmapData: `Demo heatmap for ${loc} (${time}). Highlighted zones are illustrative only.\n\n- Higher activity: main junctions, transit hubs, poorly lit stretches\n- Medium activity: market streets after peak hours\n- Lower activity: well-lit streets with CCTV/shops open`,
            safeRouteSuggestions: `Demo suggestions for ${loc} (${time}):\n\n1) Prefer well-lit, main roads even if slightly longer.\n2) Avoid isolated shortcuts, empty parks/lanes, and poorly lit flyovers.\n3) Stay near open shops/petrol pumps; keep emergency dial ready.\n4) Share live location with a trusted contact for the duration of travel.\n5) If you feel unsafe, move to a populated place and call 112/181.`,
        };
    };

    const crimeMapImage = getPlaceholderImage('crime-heatmap');

    const withTimeout = async <T,>(promise: Promise<T>, ms: number): Promise<T> => {
        return await Promise.race([
            promise,
            new Promise<T>((_, reject) => setTimeout(() => reject(new Error("timeout")), ms)),
        ]);
    };

    const handleGenerateMap = async () => {
        if (!location) {
            toast({
                title: 'Location required',
                description: 'Please enter a location to generate a map.',
                variant: 'destructive',
            });
            return;
        }
        setLoading(true);
        setMapData(null);
        try {
            const timeOfDay = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
            const result = await withTimeout(generateCrimeHotspotMap({
                location,
                timeOfDay,
            }), 6000);
            setMapData(result);
        } catch (error) {
            toast({
                title: 'Error generating map',
                description: 'AI response unavailable. Showing demo map insights instead.',
                duration: 3500,
            });
            const timeOfDay = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
            setMapData(buildDemoMapData(location, timeOfDay));
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="h-full bg-background flex flex-col">
            <AppHeader title="Community Safety Map" description="Explore safe routes and view crime hotspots." onBack={onBack} showBackButton={true} icon={Map} />
            <div className="flex-grow p-4 space-y-4 overflow-y-auto">
                <Card>
                    <CardHeader>
                        <CardTitle>Find Safe Routes</CardTitle>
                        <CardDescription>Enter a location to get AI-powered safety insights.</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="space-y-2">
                            <Label htmlFor="location">Your Location or Destination</Label>
                            <Input
                                id="location"
                                placeholder="e.g., Koramangala, Bengaluru"
                                value={location}
                                onChange={(e) => setLocation(e.target.value)}
                            />
                        </div>
                        <Button onClick={handleGenerateMap} disabled={loading} className="w-full">
                            {loading ? 'Generating...' : 'Get Safety Map'}
                        </Button>
                    </CardContent>
                </Card>

                {loading && (
                    <div className="space-y-4">
                        <Skeleton className="h-48 w-full rounded-lg" />
                        <Skeleton className="h-8 w-1/2" />
                        <Skeleton className="h-20 w-full" />
                    </div>
                )}

                {mapData && (
                    <div className="space-y-4">
                        <Card>
                            <CardHeader>
                                <CardTitle>Crime Hotspot Map</CardTitle>
                            </CardHeader>
                            <CardContent>
                                {crimeMapImage && (
                                    <img
                                        src={crimeMapImage.imageUrl}
                                        alt={crimeMapImage.description}
                                        data-ai-hint={crimeMapImage.imageHint}
                                        className="rounded-lg border aspect-video object-cover w-full"
                                    />
                                )}
                                <p className="text-xs text-muted-foreground mt-2">{mapData.crimeHeatmapData}</p>
                            </CardContent>
                        </Card>

                        <Alert>
                            <ShieldCheck className="h-4 w-4" />
                            <AlertTitle>Safe Route Suggestions</AlertTitle>
                            <AlertDescription>{mapData.safeRouteSuggestions}</AlertDescription>
                        </Alert>
                    </div>
                )}

                {!loading && !mapData && (
                    <div className="text-center py-10">
                        <Lightbulb className="mx-auto h-12 w-12 text-muted-foreground" />
                        <h3 className="mt-2 text-sm font-semibold text-foreground">Safety Insights Await</h3>
                        <p className="mt-1 text-sm text-muted-foreground">Enter a location to see your personalized safety map.</p>
                    </div>
                )}
            </div>
        </div>
    );
}
