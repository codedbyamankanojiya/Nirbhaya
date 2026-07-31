/**
 * API Client for communicating with the NestJS backend.
 *
 * All backend responses are wrapped by the TransformInterceptor:
 *   { success: boolean; message: string; data: T }
 *
 * This client automatically attaches JWT tokens, handles token
 * refresh on 401 responses, and provides typed request helpers.
 */

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000";

// ---------------------------------------------------------------------------
// Token storage (in-memory – cleared on page refresh for security)
// ---------------------------------------------------------------------------
let accessToken: string | null = null;
let refreshToken: string | null = null;

export function setTokens(access: string, refresh: string) {
  accessToken = access;
  refreshToken = refresh;
  // Persist refresh token so the session survives page reloads
  if (typeof window !== "undefined") {
    localStorage.setItem("nirbhaya_rt", refresh);
  }
}

export function getAccessToken() {
  return accessToken;
}

export function clearTokens() {
  accessToken = null;
  refreshToken = null;
  if (typeof window !== "undefined") {
    localStorage.removeItem("nirbhaya_rt");
  }
}

export function loadRefreshTokenFromStorage(): string | null {
  if (typeof window !== "undefined") {
    return localStorage.getItem("nirbhaya_rt");
  }
  return null;
}

// ---------------------------------------------------------------------------
// Response types
// ---------------------------------------------------------------------------
export interface ApiResponse<T = unknown> {
  success: boolean;
  message: string;
  data: T;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  user: { id: string; email: string; role: string };
}

export interface ProfileData {
  id: string;
  userId: string;
  name: string;
  dob: string | null;
  gender: string | null;
  bloodGroup: string | null;
  emergencyEmail: string | null;
  emergencyPhone: string | null;
  address: string | null;
  profileImageUrl: string | null;
}

export interface ContactData {
  id: string;
  userId: string;
  name: string;
  phone: string;
  email: string | null;
  priority: number;
  isPrimary: boolean;
}

// ---------------------------------------------------------------------------
// Core fetch wrapper
// ---------------------------------------------------------------------------
let isRefreshing = false;
let refreshPromise: Promise<boolean> | null = null;

async function attemptTokenRefresh(): Promise<boolean> {
  const rt = refreshToken || loadRefreshTokenFromStorage();
  if (!rt) return false;

  try {
    const res = await fetch(`${API_BASE_URL}/api/v1/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken: rt }),
    });

    if (!res.ok) {
      clearTokens();
      return false;
    }

    const json: ApiResponse<{ accessToken: string; refreshToken: string }> =
      await res.json();
    setTokens(json.data.accessToken, json.data.refreshToken);
    return true;
  } catch {
    clearTokens();
    return false;
  }
}

async function apiFetch<T>(
  path: string,
  options: RequestInit = {}
): Promise<ApiResponse<T>> {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  };

  if (accessToken) {
    headers["Authorization"] = `Bearer ${accessToken}`;
  }

  let res: Response;
  try {
    res = await fetch(`${API_BASE_URL}${path}`, { ...options, headers });
  } catch (error: any) {
    throw new ApiError(
      0,
      "Unable to connect to backend server. Operating in offline mode.",
      error
    );
  }

  // Attempt a single token refresh on 401
  if (res.status === 401 && (refreshToken || loadRefreshTokenFromStorage())) {
    if (!isRefreshing) {
      isRefreshing = true;
      refreshPromise = attemptTokenRefresh().finally(() => {
        isRefreshing = false;
        refreshPromise = null;
      });
    }

    const refreshed = await (refreshPromise ?? Promise.resolve(false));

    if (refreshed && accessToken) {
      headers["Authorization"] = `Bearer ${accessToken}`;
      try {
        res = await fetch(`${API_BASE_URL}${path}`, { ...options, headers });
      } catch (error: any) {
        throw new ApiError(
          0,
          "Unable to connect to backend server.",
          error
        );
      }
    }
  }

  let json: any = {};
  try {
    json = await res.json();
  } catch {
    throw new ApiError(
      res.status,
      `Server error (${res.status}). Invalid response received.`,
      null
    );
  }

  if (!res.ok) {
    const errMsg =
      typeof json?.message === "string"
        ? json.message
        : Array.isArray(json?.message)
        ? json.message[0]
        : `Request failed with status ${res.status}`;
    throw new ApiError(res.status, errMsg, json);
  }

  return json as ApiResponse<T>;
}

// ---------------------------------------------------------------------------
// Error class
// ---------------------------------------------------------------------------
export class ApiError extends Error {
  status: number;
  body: unknown;

  constructor(status: number, message: string, body?: unknown) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.body = body;
  }
}

// ---------------------------------------------------------------------------
// Convenience methods
// ---------------------------------------------------------------------------
export const api = {
  get: <T>(path: string) => apiFetch<T>(path, { method: "GET" }),

  post: <T>(path: string, body?: unknown) =>
    apiFetch<T>(path, {
      method: "POST",
      body: body ? JSON.stringify(body) : undefined,
    }),

  patch: <T>(path: string, body?: unknown) =>
    apiFetch<T>(path, {
      method: "PATCH",
      body: body ? JSON.stringify(body) : undefined,
    }),

  delete: <T>(path: string) => apiFetch<T>(path, { method: "DELETE" }),
};
