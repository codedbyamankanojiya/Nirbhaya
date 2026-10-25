import 'package:nirbhaya/core/network/api_client.dart';
import 'package:nirbhaya/core/network/api_endpoints.dart';
import 'package:nirbhaya/shared/models/api_response.dart';

class IncidentsApi {
  final ApiClient apiClient;

  IncidentsApi(this.apiClient);

  Future<ApiResponse<dynamic>> getMyIncidents() async {
    return apiClient.get<dynamic>('${ApiEndpoints.incidents}/my');
  }

  Future<ApiResponse<dynamic>> getIncidentById(String id) async {
    return apiClient.get<dynamic>('${ApiEndpoints.incidents}/$id');
  }

  Future<ApiResponse<dynamic>> createIncident({
    required String title,
    required String description,
    required String category,
    double? latitude,
    double? longitude,
    bool isAnonymous = false,
    List<String>? mediaIds,
  }) async {
    return apiClient.post<dynamic>(
      ApiEndpoints.incidents,
      data: {
        'title': title,
        'description': description,
        'category': category,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'isAnonymous': isAnonymous,
        if (mediaIds != null) 'mediaIds': mediaIds,
      },
    );
  }

  Future<ApiResponse<dynamic>> updateIncident(String id, Map<String, dynamic> data) async {
    // Assuming patch/post update via post
    return apiClient.post<dynamic>('${ApiEndpoints.incidents}/$id', data: data);
  }

  Future<ApiResponse<dynamic>> deleteIncident(String id) async {
    // Assuming delete via get or post delete endpoint
    return apiClient.post<dynamic>('${ApiEndpoints.incidents}/$id/delete');
  }
}
