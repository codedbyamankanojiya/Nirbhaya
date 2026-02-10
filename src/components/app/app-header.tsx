
import React from 'react';
import { Button } from '@/components/ui/button';
import { ChevronLeft } from 'lucide-react';
import type { LucideIcon } from 'lucide-react';

interface AppHeaderProps {
    title: string;
    description?: string;
    welcomeMessage?: string;
    showBackButton: boolean;
    onBack: () => void;
    icon?: LucideIcon;
}

const AppHeader: React.FC<AppHeaderProps> = ({
    title,
    description,
    welcomeMessage,
    showBackButton,
    onBack,
    icon: Icon,
}) => {
    return (
        <header className="px-4 pt-10 pb-4 flex items-center sticky top-0 bg-background/95 backdrop-blur-sm z-10 border-b">
            {showBackButton && (
                <Button onClick={onBack} variant="ghost" size="icon" className="mr-2 -ml-2">
                    <ChevronLeft className="w-6 h-6" />
                </Button>
            )}
            <div className="flex items-center gap-3">
                {Icon && <Icon className="w-6 h-6 text-primary" />}
                <div>
                    {welcomeMessage && <p className="text-muted-foreground font-medium">{welcomeMessage}</p>}
                    <h1 className="text-2xl font-bold text-foreground">{title}</h1>
                    {description && <p className="text-sm text-muted-foreground">{description}</p>}
                </div>
            </div>
        </header>
    );
};

export default AppHeader;
