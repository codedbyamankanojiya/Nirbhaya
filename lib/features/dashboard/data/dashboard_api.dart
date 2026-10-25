import 'package:nirbhaya/core/network/api_client.dart';
import 'package:nirbhaya/core/network/api_endpoints.dart';
import 'package:nirbhaya/shared/models/api_response.dart';

class DashboardApi {
  final ApiClient apiClient;

  DashboardApi(this.apiClient);

  Future<ApiResponse<dynamic>> getUserStats() async {
    return apiClient.get<dynamic>('${ApiEndpoints.dashboard}/user-stats');
  }
}
