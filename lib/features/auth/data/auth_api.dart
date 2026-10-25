import 'package:nirbhaya/core/network/api_client.dart';
import 'package:nirbhaya/core/network/api_endpoints.dart';
import 'package:nirbhaya/shared/models/api_response.dart';

class AuthApi {
  final ApiClient apiClient;

  AuthApi(this.apiClient);

  Future<ApiResponse<dynamic>> login(String email, String password) async {
    return apiClient.post<dynamic>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
  }

  Future<ApiResponse<dynamic>> register(String email, String password) async {
    return apiClient.post<dynamic>(
      ApiEndpoints.register,
      data: {'email': email, 'password': password},
    );
  }

  Future<ApiResponse<dynamic>> refreshToken(String refreshToken) async {
    return apiClient.post<dynamic>(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
    );
  }

  Future<ApiResponse<dynamic>> logout(String refreshToken) async {
    return apiClient.post<dynamic>(
      ApiEndpoints.logout,
      data: {'refreshToken': refreshToken},
    );
  }

  Future<ApiResponse<dynamic>> getProfile() async {
    return apiClient.get<dynamic>(ApiEndpoints.profile);
  }

  Future<ApiResponse<dynamic>> forgotPassword(String email) async {
    return apiClient.post<dynamic>(
      '${ApiEndpoints.auth}/forgot-password',
      data: {'email': email},
    );
  }

  Future<ApiResponse<dynamic>> resetPassword(String email, String token, String newPassword) async {
    return apiClient.post<dynamic>(
      '${ApiEndpoints.auth}/reset-password',
      data: {
        'email': email,
        'token': token,
        'newPassword': newPassword,
      },
    );
  }
}
