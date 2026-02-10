'use server';

/**
 * @fileOverview AI Safety Assistant for real-time advice based on location and time of day.
 *
 * - getSafetyAdvice - A function that provides safety advice.
 * - SafetyAdviceInput - The input type for the getSafetyAdvice function.
 * - SafetyAdviceOutput - The return type for the getSafetyAdvice function.
 */

import { ai } from '@/ai/genkit';
import { z } from 'genkit';

const SafetyAdviceInputSchema = z.object({
    location: z
        .string()
        .describe('The current location of the user (e.g., city and street address).'),
    timeOfDay: z
        .string()
        .describe('The current time of day (e.g., 3:00 PM).'),
    recentCrimeData: z
        .string()
        .optional()
        .describe(
            'Optional recent crime data for the location, to provide more accurate advice.'
        ),
});
export type SafetyAdviceInput = z.infer<typeof SafetyAdviceInputSchema>;

const SafetyAdviceOutputSchema = z.object({
    advice: z
        .string()
        .describe('Safety advice based on the location, time of day, and crime data.'),
});
export type SafetyAdviceOutput = z.infer<typeof SafetyAdviceOutputSchema>;

export async function getSafetyAdvice(input: SafetyAdviceInput): Promise<SafetyAdviceOutput> {
    return safetyAdviceFlow(input);
}

const prompt = ai.definePrompt({
    name: 'safetyAdvicePrompt',
    input: { schema: SafetyAdviceInputSchema },
    output: { schema: SafetyAdviceOutputSchema },
    prompt: `You are a safety advisor. Provide safety advice based on the following information:

Location: {{{location}}}
Time of Day: {{{timeOfDay}}}

{{#if recentCrimeData}}
Recent Crime Data: {{{recentCrimeData}}}
{{/if}}

Provide specific and actionable advice to ensure the user's safety.`,
});

const safetyAdviceFlow = ai.defineFlow(
    {
        name: 'safetyAdviceFlow',
        inputSchema: SafetyAdviceInputSchema,
        outputSchema: SafetyAdviceOutputSchema,
    },
    async input => {
        const { output } = await prompt(input);
        return output!;
    }
);
