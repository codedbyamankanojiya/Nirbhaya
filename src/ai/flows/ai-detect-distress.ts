'use server';

/**
 * @fileOverview AI-powered distress detection flow.
 * 
 * This file defines a Genkit flow that uses device sensors (simulated) and microphone (optional) to detect potential distress events.
 * It exports the `detectDistress` function to initiate the distress detection process.
 * 
 * @interface DetectDistressInput - Defines the input schema for the distress detection flow.
 * @interface DetectDistressOutput - Defines the output schema for the distress detection flow.
 *
 * @function detectDistress - Main function to trigger the distress detection flow.
 */

import { ai } from '@/ai/genkit';
import { z } from 'genkit';

const DetectDistressInputSchema = z.object({
    movementData: z
        .string()
        .describe(
            'Simulated sensor data representing device movement as a data URI. Expected format: \'data:<mimetype>;base64,<encoded_data>\'.' // Passing as data URI to align with image/audio patterns
        ),
    audioData: z
        .string()
        .optional()
        .describe(
            'Optional audio data as a data URI that must include a MIME type and use Base64 encoding. Expected format: \'data:<mimetype>;base64,<encoded_data>\'.' // Passing as data URI to align with image/audio patterns
        ),
});
export type DetectDistressInput = z.infer<typeof DetectDistressInputSchema>;

const DetectDistressOutputSchema = z.object({
    isDistress: z.boolean().describe('Whether a distress event is detected.'),
    promptUser: z
        .boolean()
        .describe('Whether the user should be prompted to confirm safety.'),
    autoSendSOS: z
        .boolean()
        .describe('Whether an SOS should be automatically sent.'),
    reason: z.string().describe('The reason for the distress detection.'),
});
export type DetectDistressOutput = z.infer<typeof DetectDistressOutputSchema>;

export async function detectDistress(input: DetectDistressInput): Promise<DetectDistressOutput> {
    return detectDistressFlow(input);
}

const detectDistressPrompt = ai.definePrompt({
    name: 'detectDistressPrompt',
    input: { schema: DetectDistressInputSchema },
    output: { schema: DetectDistressOutputSchema },
    prompt: `You are an AI safety assistant. You will analyze sensor data and audio data to detect potential distress events. Based on the data, you will determine if a distress event is likely, whether the user should be prompted for confirmation, and whether an SOS should be automatically sent.

Consider these factors:

- Sudden or erratic movements (running, shaking, dropping the device) indicated by movementData: {{movementData}}
- Distress keywords spoken by the user in audioData: {{audioData}}

Output the isDistress, promptUser, and autoSendSOS fields appropriately.  Explain your reasoning in the reason field.

If movement data indicates a fall (sudden stop after rapid movement) and audio data contains a distress keyword (e.g., \"help\"), set isDistress to true, promptUser to true, and autoSendSOS to false. If the user does not respond to the prompt, autoSendSOS will be triggered.
If movement data shows continued erratic movement and distress keywords are present, set isDistress to true, promptUser to false, and autoSendSOS to true.
If there's not enough information, make reasonable defaults.
`,
});

const detectDistressFlow = ai.defineFlow(
    {
        name: 'detectDistressFlow',
        inputSchema: DetectDistressInputSchema,
        outputSchema: DetectDistressOutputSchema,
    },
    async input => {
        const { output } = await detectDistressPrompt(input);
        return output!;
    }
);
