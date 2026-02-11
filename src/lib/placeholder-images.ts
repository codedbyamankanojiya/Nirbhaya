export type ImagePlaceholder = {
    id: string;
    description: string;
    imageUrl: string;
    imageHint: string;
};

export const PlaceHolderImages: ImagePlaceholder[] = [
    {
        id: "user-avatar",
        description: "Priya's profile picture.",
        imageUrl: "/contacts/priya.png",
        imageHint: "Priya Sharma"
    },
    {
        id: "guardian-0",
        description: "Police emergency contact",
        imageUrl: "/contacts/police.png",
        imageHint: "Police"
    },
    {
        id: "guardian-1",
        description: "Aisha Khan profile picture",
        imageUrl: "/contacts/aisha.png",
        imageHint: "Aisha Khan"
    },
    {
        id: "guardian-2",
        description: "Mom profile picture",
        imageUrl: "/contacts/mom.png",
        imageHint: "Mom"
    },
    {
        id: "guardian-3",
        description: "Dad profile picture",
        imageUrl: "/contacts/dad.png",
        imageHint: "Dad"
    },
    {
        id: "guardian-4",
        description: "Aman Kanojiya profile picture",
        imageUrl: "/contacts/aman-kanojiya.jpg",
        imageHint: "Aman Kanojiya"
    },
    {
        id: "guardian-5",
        description: "Brother profile picture",
        imageUrl: "/contacts/brother.png",
        imageHint: "Brother"
    },
    {
        id: "live-tracking-map",
        description: "A map showing live location tracking.",
        imageUrl: "https://images.unsplash.com/photo-1522678073884-26b1b87526e4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3NDE5ODJ8MHwxfHNlYXJjaHwxMHx8Y2l0eSUyMG1hcHxlbnwwfHx8fDE3NjU0NDQ3NzR8MA&ixlib=rb-4.1.0&q=80&w=1080",
        imageHint: "city map"
    },
    {
        id: "crime-heatmap",
        description: "A crime heatmap of a city area.",
        imageUrl: "https://images.unsplash.com/photo-1648529739495-d4d8a8abce4e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3NDE5ODJ8MHwxfHNlYXJjaHwzfHxtYXAlMjBuaWdodHxlbnwwfHx8fDE3NjU0NTYwNTJ8MA&ixlib=rb-4.1.0&q=80&w=1080",
        imageHint: "map night"
    }
];

export const getPlaceholderImage = (id: string): ImagePlaceholder | undefined => {
    return PlaceHolderImages.find(img => img.id === id);
};
