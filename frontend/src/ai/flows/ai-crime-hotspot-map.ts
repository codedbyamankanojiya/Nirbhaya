'use server';
/**
 * @fileOverview Generates a crime heatmap and safe route suggestions based on a given location.
 *
 * - generateCrimeHotspotMap - A function that generates crime hotspot map data and safe route suggestions.
 * - CrimeHotspotMapInput - The input type for the generateCrimeHotspotMap function.
 * - CrimeHotspotMapOutput - The return type for the generateCrimeHotspotMap function.
 */

import { ai } from '@/ai/genkit';
import { z } from 'genkit';

const CrimeHotspotMapInputSchema = z.object({
    location: z.string().describe('The location for which to generate the crime heatmap and safe route suggestions.'),
    timeOfDay: z.string().describe('The time of day for which to generate the crime heatmap (e.g., morning, evening, night).'),
});
export type CrimeHotspotMapInput = z.infer<typeof CrimeHotspotMapInputSchema>;

const CrimeHotspotMapOutputSchema = z.object({
    crimeHeatmapData: z.string().describe('AI-generated data representing a crime heatmap for the specified location and time of day.'),
    safeRouteSuggestions: z.string().describe('AI-generated safe route suggestions for the specified location, considering lighting, crowd density, and police station proximity.'),
});
export type CrimeHotspotMapOutput = z.infer<typeof CrimeHotspotMapOutputSchema>;

export async function generateCrimeHotspotMap(input: CrimeHotspotMapInput): Promise<CrimeHotspotMapOutput> {
    return crimeHotspotMapFlow(input);
}

const crimeHotspotMapPrompt = ai.definePrompt({
    name: 'crimeHotspotMapPrompt',
    input: { schema: CrimeHotspotMapInputSchema },
    output: { schema: CrimeHotspotMapOutputSchema },
    prompt: `You are an AI assistant designed to generate crime heatmaps and safe route suggestions for users.

  Based on the provided location and time of day, generate a crime heatmap that highlights areas with higher crime rates.
  Also, provide safe route suggestions, considering factors like lighting score, crowd density, and proximity to police stations.

  Location: {{{location}}}
  Time of Day: {{{timeOfDay}}}

  Format the output as follows:
  {
    crimeHeatmapData: "...",
    safeRouteSuggestions: "..."
  }`,
});

const crimeHotspotMapFlow = ai.defineFlow(
    {
        name: 'crimeHotspotMapFlow',
        inputSchema: CrimeHotspotMapInputSchema,
        outputSchema: CrimeHotspotMapOutputSchema,
    },
    async input => {
        const { output } = await crimeHotspotMapPrompt(input);
        return output!;
    }
);
