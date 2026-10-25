import 'package:nirbhaya/core/network/api_client.dart';
import 'package:nirbhaya/core/network/api_endpoints.dart';
import 'package:nirbhaya/shared/models/api_response.dart';

class ProfileApi {
  final ApiClient apiClient;

  ProfileApi(this.apiClient);

  Future<ApiResponse<dynamic>> getProfile() async {
    return apiClient.get<dynamic>(ApiEndpoints.profile);
  }

  Future<ApiResponse<dynamic>> updateProfile({
    String? name,
    String? dob,
    String? gender,
    String? bloodGroup,
    String? emergencyEmail,
    String? emergencyPhone,
    String? address,
    String? profileImageUrl,
    String? allergies,
    String? conditions,
    String? primaryPhysician,
    String? medicalNotes,
    String? govtId,
    String? emergencyCode,
    String? vehicleNumber,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (dob != null) data['dob'] = dob;
    if (gender != null) data['gender'] = gender;
    if (bloodGroup != null) data['bloodGroup'] = bloodGroup;
    if (emergencyEmail != null) data['emergencyEmail'] = emergencyEmail;
    if (emergencyPhone != null) data['emergencyPhone'] = emergencyPhone;
    if (address != null) data['address'] = address;
    if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;
    if (allergies != null) data['allergies'] = allergies;
    if (conditions != null) data['conditions'] = conditions;
    if (primaryPhysician != null) data['primaryPhysician'] = primaryPhysician;
    if (medicalNotes != null) data['medicalNotes'] = medicalNotes;
    if (govtId != null) data['govtId'] = govtId;
    if (emergencyCode != null) data['emergencyCode'] = emergencyCode;
    if (vehicleNumber != null) data['vehicleNumber'] = vehicleNumber;

    return apiClient.post<dynamic>(ApiEndpoints.profile, data: data);
  }
}
