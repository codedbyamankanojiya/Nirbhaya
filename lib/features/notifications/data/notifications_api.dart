import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../shared/models/api_response.dart';

class NotificationsApi {
  final ApiClient _apiClient;

  NotificationsApi(this._apiClient);

  Future<ApiResponse<dynamic>> getNotifications() async {
    return _apiClient.get<dynamic>(ApiEndpoints.notifications);
  }

  Future<ApiResponse<dynamic>> markAsRead(String id) async {
    return _apiClient.post<dynamic>('${ApiEndpoints.notifications}/$id/read');
  }

  Future<ApiResponse<dynamic>> markAllAsRead() async {
    return _apiClient.post<dynamic>('${ApiEndpoints.notifications}/read-all');
  }

  Future<ApiResponse<dynamic>> deleteNotification(String id) async {
    return _apiClient.post<dynamic>('${ApiEndpoints.notifications}/$id/delete');
  }
}
