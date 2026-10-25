import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirbhaya/features/auth/data/auth_api.dart';
import 'package:nirbhaya/features/auth/domain/user_model.dart';
import 'package:nirbhaya/core/storage/secure_storage.dart';
import 'package:nirbhaya/core/errors/app_exception.dart';

class AuthRepository {
  final AuthApi api;
  final SecureStorageService storage;
  static const String _cachedUserKey = 'cached_user_session';

  AuthRepository(this.api, this.storage);

  Future<void> _saveCachedUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedUserKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_cachedUserKey);
    if (data != null) {
      try {
        return UserModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedUserKey);
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await api.login(email, password);
      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        await storage.saveAccessToken(data['accessToken'] as String);
        await storage.saveRefreshToken(data['refreshToken'] as String);
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        await _saveCachedUser(user);
        return user;
      } else {
        throw AppException(response.message);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('An error occurred during login');
    }
  }

  Future<void> register(String email, String password) async {
    try {
      final response = await api.register(email, password);
      if (!response.success) {
        throw AppException(response.message);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('An error occurred during registration');
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken != null) {
        await api.logout(refreshToken);
      }
    } finally {
      await storage.clearTokens();
      await _clearCachedUser();
    }
  }

  Future<UserModel?> tryAutoLogin() async {
    try {
      final accessToken = await storage.getAccessToken();
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null && accessToken == null) {
        return null;
      }

      // Check offline cache first so offline boot remains authenticated
      final cached = await getCachedUser();

      if (refreshToken != null) {
        try {
          final refreshResponse = await api.refreshToken(refreshToken);
          if (refreshResponse.success) {
            final data = refreshResponse.data as Map<String, dynamic>;
            await storage.saveAccessToken(data['accessToken'] as String);
            await storage.saveRefreshToken(data['refreshToken'] as String);
            final liveUser = await loadProfile();
            await _saveCachedUser(liveUser);
            return liveUser;
          }
        } catch (_) {
          // If network is offline, keep cached user session alive
          if (cached != null) return cached;
        }
      }

      return cached;
    } catch (e) {
      return await getCachedUser();
    }
  }

  Future<UserModel> loadProfile() async {
    try {
      final response = await api.getProfile();
      if (response.success) {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        await _saveCachedUser(user);
        return user;
      } else {
        throw AppException(response.message);
      }
    } catch (e) {
      final cached = await getCachedUser();
      if (cached != null) return cached;
      if (e is AppException) rethrow;
      throw AppException('An error occurred while loading profile');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await api.forgotPassword(email);
      if (!response.success) {
        throw AppException(response.message);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Could not send password reset request');
    }
  }

  Future<void> resetPassword(String email, String token, String newPassword) async {
    try {
      final response = await api.resetPassword(email, token, newPassword);
      if (!response.success) {
        throw AppException(response.message);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Could not reset password');
    }
  }
}
