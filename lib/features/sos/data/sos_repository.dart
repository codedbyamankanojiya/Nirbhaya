import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirbhaya/features/auth/domain/user_model.dart';
import 'package:nirbhaya/features/sos/data/sos_api.dart';
import 'package:nirbhaya/features/location/data/location_service.dart';
import 'package:nirbhaya/core/services/firebase_sync_service.dart';
import 'package:nirbhaya/shared/models/api_response.dart';

class SosTriggerResult {
  final bool success;
  final String? sosId;
  final double? latitude;
  final double? longitude;
  final String message;

  SosTriggerResult({
    required this.success,
    this.sosId,
    this.latitude,
    this.longitude,
    required this.message,
  });
}

class SosRepository {
  final SosApi _sosApi;
  final LocationService _locationService;
  final FirebaseSyncService _firebaseSyncService = FirebaseSyncService();
  static const String _cachedProfileKey = 'cached_profile';

  SosRepository(this._sosApi, this._locationService);

  Future<ProfileModel?> _getCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_cachedProfileKey);
      if (data != null) {
        return ProfileModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<SosTriggerResult> triggerSos([String? description]) async {
    double? latitude;
    double? longitude;

    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
      }
    } catch (_) {
      // Proceed even if location retrieval fails
    }

    // Hydrate distress payload with user medical & emergency identifiers
    String effectiveDescription = description ?? 'EMERGENCY DISTRESS DISPATCH';
    final profile = await _getCachedProfile();
    if (profile != null) {
      final details = <String>[];
      if (profile.name.isNotEmpty) details.add('Victim: ${profile.name}');
      if (profile.bloodGroup != null) details.add('Blood: ${profile.bloodGroup}');
      if (profile.allergies != null) details.add('Allergies: ${profile.allergies}');
      if (profile.conditions != null) details.add('Conditions: ${profile.conditions}');
      if (profile.emergencyPhone != null) details.add('Emergency Contact: ${profile.emergencyPhone}');
      if (profile.vehicleNumber != null) details.add('Vehicle: ${profile.vehicleNumber}');

      if (details.isNotEmpty) {
        effectiveDescription = '$effectiveDescription | [${details.join('; ')}]';
      }
    }

    // Dispatch distress to Cloud Firestore
    String? firestoreSosId;
    try {
      firestoreSosId = await _firebaseSyncService.recordSosAlert(
        latitude: latitude,
        longitude: longitude,
        description: effectiveDescription,
      );
    } catch (_) {}

    try {
      final response = await _sosApi.triggerSos(
        latitude: latitude,
        longitude: longitude,
        description: effectiveDescription,
      );

      if (response.success && response.data != null) {
        return SosTriggerResult(
          success: true,
          sosId: response.data['id']?.toString() ?? firestoreSosId,
          latitude: latitude,
          longitude: longitude,
          message: response.message,
        );
      } else {
        return SosTriggerResult(
          success: firestoreSosId != null,
          sosId: firestoreSosId,
          latitude: latitude,
          longitude: longitude,
          message: response.message.isNotEmpty ? response.message : 'API failed',
        );
      }
    } catch (e) {
      // Offline & Firestore fallback: return coordinates so local emergency protocols can trigger
      return SosTriggerResult(
        success: firestoreSosId != null,
        sosId: firestoreSosId,
        latitude: latitude,
        longitude: longitude,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<dynamic>> getSosHistory({int page = 1, int limit = 10}) async {
    return _sosApi.getSosHistory(page: page, limit: limit);
  }

  Future<ApiResponse<dynamic>> cancelSos(String id) async {
    try {
      await _firebaseSyncService.updateSosStatus(id, 'FALSE_ALARM');
    } catch (_) {}
    if (id.startsWith('local_')) {
      return ApiResponse(success: true, message: 'Local SOS cancelled', data: null);
    }
    return _sosApi.updateSosStatus(id, 'FALSE_ALARM');
  }

  Future<ApiResponse<dynamic>> resolveSos(String id) async {
    try {
      await _firebaseSyncService.updateSosStatus(id, 'RESOLVED');
    } catch (_) {}
    if (id.startsWith('local_')) {
      return ApiResponse(success: true, message: 'Local SOS resolved', data: null);
    }
    return _sosApi.updateSosStatus(id, 'RESOLVED');
  }
}
