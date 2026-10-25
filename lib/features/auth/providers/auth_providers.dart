import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/features/auth/data/auth_api.dart';
import 'package:nirbhaya/features/auth/data/auth_repository.dart';
import 'package:nirbhaya/features/auth/domain/user_model.dart';
import 'package:nirbhaya/core/storage/secure_storage.dart';
import 'package:nirbhaya/core/network/api_client.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(secureStorageProvider));
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authApiProvider), ref.watch(secureStorageProvider));
});

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  AuthState({
    required this.status,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(AuthState(status: AuthStatus.initial));

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await repository.login(email, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user, error: null);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await repository.register(email, password);
      // Auto login after registration
      await login(email, password);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await repository.logout();
    } finally {
      state = state.copyWith(status: AuthStatus.unauthenticated, user: null, error: null);
    }
  }

  Future<void> tryAutoLogin() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await repository.tryAutoLogin();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user, error: null);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
    }
  }

  Future<void> refreshProfile() async {
    if (state.status != AuthStatus.authenticated) return;
    try {
      final user = await repository.loadProfile();
      state = state.copyWith(user: user);
    } catch (e) {
      // Keep existing user data but you could set an error
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await repository.forgotPassword(email);
      state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword(String email, String token, String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await repository.resetPassword(email, token, newPassword);
      state = state.copyWith(status: AuthStatus.unauthenticated, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e.toString());
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
