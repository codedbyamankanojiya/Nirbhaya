import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../shared/models/api_response.dart';

class ContactsApi {
  final ApiClient _apiClient;

  ContactsApi(this._apiClient);

  Future<ApiResponse<dynamic>> getContacts() async {
    return _apiClient.get<dynamic>(ApiEndpoints.contacts);
  }

  Future<ApiResponse<dynamic>> addContact({
    required String name,
    required String phone,
    String? email,
    bool isPrimary = false,
    int priority = 0,
    String? relation,
  }) async {
    return _apiClient.post<dynamic>(ApiEndpoints.contacts, data: {
      'name': name,
      'phone': phone,
      'email': email,
      'isPrimary': isPrimary,
      'priority': priority,
      'relation': relation,
    });
  }

  Future<ApiResponse<dynamic>> updateContact(String id, Map<String, dynamic> data) async {
    return _apiClient.post<dynamic>('${ApiEndpoints.contacts}/$id', data: data); 
  }

  Future<ApiResponse<dynamic>> deleteContact(String id) async {
    return _apiClient.post<dynamic>('${ApiEndpoints.contacts}/$id/delete'); 
  }
}
