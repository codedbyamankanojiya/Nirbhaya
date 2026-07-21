"use client";

import {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  type ReactNode,
} from "react";
import {
  api,
  setTokens,
  clearTokens,
  loadRefreshTokenFromStorage,
  type LoginResponse,
  type ProfileData,
  type ApiError,
} from "@/lib/api";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------
export interface AuthUser {
  id: string;
  email: string;
  role: string;
  profile: ProfileData | null;
}

interface AuthContextValue {
  user: AuthUser | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (name: string, email: string, password: string) => Promise<string>;
  logout: () => Promise<void>;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Fetch the user profile using the current access token
  const fetchProfile = useCallback(async (): Promise<AuthUser | null> => {
    try {
      const profileRes = await api.get<ProfileData>("/api/v1/profile");
      const profile = profileRes.data;

      return {
        id: profile.userId,
        email: "", // will be filled if we can get it
        role: "USER",
        profile,
      };
    } catch {
      return null;
    }
  }, []);

  // Attempt to restore session from stored refresh token on mount
  useEffect(() => {
    const restore = async () => {
      const storedRt = loadRefreshTokenFromStorage();
      if (!storedRt) {
        setIsLoading(false);
        return;
      }

      try {
        // Attempt a token refresh to get a fresh access token
        const res = await api.post<{ accessToken: string; refreshToken: string }>(
          "/api/v1/auth/refresh",
          { refreshToken: storedRt }
        );
        setTokens(res.data.accessToken, res.data.refreshToken);

        const profile = await fetchProfile();
        if (profile) setUser(profile);
      } catch {
        clearTokens();
      } finally {
        setIsLoading(false);
      }
    };

    restore();
  }, [fetchProfile]);

  // ------ Login ------
  const login = useCallback(
    async (email: string, password: string) => {
      const res = await api.post<LoginResponse>("/api/v1/auth/login", {
        email,
        password,
      });

      setTokens(res.data.accessToken, res.data.refreshToken);

      const profile = await fetchProfile();
      setUser(
        profile ?? {
          id: res.data.user.id,
          email: res.data.user.email,
          role: res.data.user.role,
          profile: null,
        }
      );
    },
    [fetchProfile]
  );

  // ------ Register ------
  const register = useCallback(
    async (name: string, email: string, password: string): Promise<string> => {
      const res = await api.post<{ message: string }>("/api/v1/auth/register", {
        name,
        email,
        password,
      });
      return res.data.message ?? res.message;
    },
    []
  );

  // ------ Logout ------
  const logout = useCallback(async () => {
    try {
      const storedRt = loadRefreshTokenFromStorage();
      if (storedRt) {
        await api.post("/api/v1/auth/logout", { refreshToken: storedRt });
      }
    } catch {
      // ignore
    } finally {
      clearTokens();
      setUser(null);
    }
  }, []);

  // ------ Refresh Profile ------
  const refreshProfile = useCallback(async () => {
    const profile = await fetchProfile();
    if (profile) setUser(profile);
  }, [fetchProfile]);

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        isLoading,
        login,
        register,
        logout,
        refreshProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

// ---------------------------------------------------------------------------
// Hook
// ---------------------------------------------------------------------------
export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return ctx;
}
