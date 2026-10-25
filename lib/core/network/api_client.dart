import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../app/config.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage.dart';
import '../../shared/models/api_response.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  ApiClient(this._secureStorage) : _dio = Dio() {
    _dio.options.baseUrl = AppConfig.effectiveBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token might be expired, attempt refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the request
            final opts = e.requestOptions;
            final token = await _secureStorage.getAccessToken();
            opts.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          }
        }
        return handler.next(e);
      },
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await Dio().post(
        '${AppConfig.effectiveBaseUrl}/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['access_token'];
        final newRefreshToken = response.data['data']['refresh_token'];
        if (newAccessToken != null && newRefreshToken != null) {
          await _secureStorage.saveAccessToken(newAccessToken);
          await _secureStorage.saveRefreshToken(newRefreshToken);
          return true;
        }
      }
    } catch (_) {
      await _secureStorage.clearTokens();
    }
    return false;
  }

  Future<ApiResponse<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return ApiResponse<T>.fromJson(response.data, null); // Add mapper if needed
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResponse<T>.fromJson(response.data, null);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return ApiResponse<T>.fromJson(response.data, null);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return ApiResponse<T>.fromJson(response.data, null);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout || 
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return NetworkException('Network connection failed');
      }
      
      if (error.response != null) {
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? error.message;
        
        if (statusCode == 401 || statusCode == 403) {
          return AuthException(message);
        }
        
        return ApiException(message, statusCode: statusCode);
      }
    }
    return AppException('An unexpected error occurred: $error');
  }
}
