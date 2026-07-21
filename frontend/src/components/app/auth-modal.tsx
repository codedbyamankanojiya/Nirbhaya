"use client";

import { useState, type FormEvent } from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useAuth } from "@/context/auth-context";
import { useToast } from "@/hooks/use-toast";
import { Shield, LogIn, UserPlus, Loader2, Eye, EyeOff } from "lucide-react";

interface AuthModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export default function AuthModal({ open, onOpenChange }: AuthModalProps) {
  const { login, register } = useAuth();
  const { toast } = useToast();

  const [mode, setMode] = useState<"login" | "register">("login");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  // Form fields
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const resetForm = () => {
    setName("");
    setEmail("");
    setPassword("");
    setError("");
    setShowPassword(false);
  };

  const switchMode = (m: "login" | "register") => {
    resetForm();
    setMode(m);
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError("");
    setIsSubmitting(true);

    try {
      if (mode === "login") {
        await login(email, password);
        toast({
          title: "Welcome back!",
          description: "You have been logged in successfully.",
          duration: 3000,
        });
        onOpenChange(false);
        resetForm();
      } else {
        const msg = await register(name, email, password);
        toast({
          title: "Registration Successful",
          description: msg || "Please check your email for verification.",
          duration: 5000,
        });
        switchMode("login");
      }
    } catch (err: any) {
      const message = err?.message || "Something went wrong. Please try again.";
      setError(message);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[420px]">
        <DialogHeader className="text-center space-y-3 pb-2">
          <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-primary/10">
            <Shield className="h-7 w-7 text-primary" />
          </div>
          <DialogTitle className="text-xl">
            {mode === "login" ? "Welcome Back" : "Create Account"}
          </DialogTitle>
          <DialogDescription>
            {mode === "login"
              ? "Sign in to access your safety dashboard and contacts."
              : "Register to set up your emergency contacts and safety profile."}
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="space-y-4 pt-2">
          {mode === "register" && (
            <div className="space-y-2">
              <Label htmlFor="auth-name">Full Name</Label>
              <Input
                id="auth-name"
                placeholder="e.g., Priya Sharma"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                minLength={2}
                disabled={isSubmitting}
              />
            </div>
          )}

          <div className="space-y-2">
            <Label htmlFor="auth-email">Email</Label>
            <Input
              id="auth-email"
              type="email"
              placeholder="you@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              disabled={isSubmitting}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="auth-password">Password</Label>
            <div className="relative">
              <Input
                id="auth-password"
                type={showPassword ? "text" : "password"}
                placeholder={
                  mode === "register"
                    ? "Min 8 chars, 1 upper, 1 lower, 1 number, 1 symbol"
                    : "Enter your password"
                }
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                minLength={mode === "register" ? 8 : 1}
                disabled={isSubmitting}
                className="pr-10"
              />
              <Button
                type="button"
                variant="ghost"
                size="icon"
                className="absolute right-0 top-0 h-full px-3 hover:bg-transparent"
                onClick={() => setShowPassword(!showPassword)}
                tabIndex={-1}
              >
                {showPassword ? (
                  <EyeOff className="h-4 w-4 text-muted-foreground" />
                ) : (
                  <Eye className="h-4 w-4 text-muted-foreground" />
                )}
              </Button>
            </div>
          </div>

          {error && (
            <p className="text-sm text-destructive bg-destructive/10 rounded-md px-3 py-2">
              {error}
            </p>
          )}

          <Button type="submit" className="w-full" disabled={isSubmitting}>
            {isSubmitting ? (
              <Loader2 className="h-4 w-4 animate-spin mr-2" />
            ) : mode === "login" ? (
              <LogIn className="h-4 w-4 mr-2" />
            ) : (
              <UserPlus className="h-4 w-4 mr-2" />
            )}
            {isSubmitting
              ? "Please wait…"
              : mode === "login"
              ? "Sign In"
              : "Create Account"}
          </Button>

          <div className="text-center text-sm text-muted-foreground pt-1">
            {mode === "login" ? (
              <p>
                Don&apos;t have an account?{" "}
                <button
                  type="button"
                  onClick={() => switchMode("register")}
                  className="text-primary font-medium hover:underline"
                >
                  Register
                </button>
              </p>
            ) : (
              <p>
                Already have an account?{" "}
                <button
                  type="button"
                  onClick={() => switchMode("login")}
                  className="text-primary font-medium hover:underline"
                >
                  Sign In
                </button>
              </p>
            )}
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
