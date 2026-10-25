import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirbhaya/features/auth/domain/user_model.dart';
import 'package:nirbhaya/features/profile/data/profile_api.dart';
import 'package:nirbhaya/core/services/firebase_sync_service.dart';

class ProfileRepository {
  final ProfileApi _profileApi;
  final FirebaseSyncService _firebaseSyncService = FirebaseSyncService();
  static const String _cachedProfileKey = 'cached_profile';

  ProfileRepository(this._profileApi);

  Future<ProfileModel?> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(_cachedProfileKey);
    if (cachedString != null) {
      try {
        final json = jsonDecode(cachedString);
        return ProfileModel.fromJson(json);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _saveCachedProfile(ProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedProfileKey, jsonEncode(profile.toJson()));
    // Sync profile and medical details to Cloud Firestore
    _firebaseSyncService.syncProfile(profile);
  }

  Future<ProfileModel> getProfile() async {
    try {
      final response = await _profileApi.getProfile();
      if (response.success && response.data != null) {
        final profile = ProfileModel.fromJson(response.data!);
        await _saveCachedProfile(profile);
        return profile;
      }
    } catch (_) {
      // Fallback on offline or unauthenticated
    }

    final cached = await getCachedProfile();
    if (cached != null) {
      return cached;
    }

    // Default guest profile if nothing cached yet
    return const ProfileModel(
      id: 'guest_profile',
      userId: 'guest_user',
      name: 'Guest User',
      bloodGroup: 'Not set',
      emergencyPhone: 'Not set',
    );
  }

  Future<ProfileModel> updateProfile({
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
    try {
      final response = await _profileApi.updateProfile(
        name: name,
        dob: dob,
        gender: gender,
        bloodGroup: bloodGroup,
        emergencyEmail: emergencyEmail,
        emergencyPhone: emergencyPhone,
        address: address,
        profileImageUrl: profileImageUrl,
        allergies: allergies,
        conditions: conditions,
        primaryPhysician: primaryPhysician,
        medicalNotes: medicalNotes,
        govtId: govtId,
        emergencyCode: emergencyCode,
        vehicleNumber: vehicleNumber,
      );
      if (response.success && response.data != null) {
        final profile = ProfileModel.fromJson(response.data!);
        await _saveCachedProfile(profile);
        return profile;
      }
    } catch (_) {
      // Local fallback for guest / offline mode
    }

    final existing = await getProfile();
    final updated = existing.copyWith(
      name: name ?? existing.name,
      dob: dob ?? existing.dob,
      gender: gender ?? existing.gender,
      bloodGroup: bloodGroup ?? existing.bloodGroup,
      emergencyEmail: emergencyEmail ?? existing.emergencyEmail,
      emergencyPhone: emergencyPhone ?? existing.emergencyPhone,
      address: address ?? existing.address,
      profileImageUrl: profileImageUrl ?? existing.profileImageUrl,
      allergies: allergies ?? existing.allergies,
      conditions: conditions ?? existing.conditions,
      primaryPhysician: primaryPhysician ?? existing.primaryPhysician,
      medicalNotes: medicalNotes ?? existing.medicalNotes,
      govtId: govtId ?? existing.govtId,
      emergencyCode: emergencyCode ?? existing.emergencyCode,
      vehicleNumber: vehicleNumber ?? existing.vehicleNumber,
    );

    await _saveCachedProfile(updated);
    return updated;
  }
}
