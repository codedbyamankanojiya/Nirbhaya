import 'package:nirbhaya/core/network/api_client.dart';
import 'package:nirbhaya/core/network/api_endpoints.dart';
import 'package:nirbhaya/shared/models/api_response.dart';

class SosApi {
  final ApiClient apiClient;
  SosApi(this.apiClient);

  Future<ApiResponse<dynamic>> triggerSos({double? latitude, double? longitude, String? description}) async {
    return apiClient.post<dynamic>(ApiEndpoints.sos, data: {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (description != null) 'description': description,
    });
  }

  Future<ApiResponse<dynamic>> getSosHistory({int page = 1, int limit = 10}) async {
    return apiClient.get<dynamic>('${ApiEndpoints.sos}/history', queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  Future<ApiResponse<dynamic>> getSosById(String id) async {
    return apiClient.get<dynamic>('${ApiEndpoints.sos}/$id');
  }

  Future<ApiResponse<dynamic>> updateSosStatus(String id, String status) async {
    return apiClient.patch<dynamic>('${ApiEndpoints.sos}/$id/status', data: {
      'status': status,
    });
  }
}
