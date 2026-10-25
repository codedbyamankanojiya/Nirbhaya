import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/features/auth/domain/user_model.dart';
import 'package:nirbhaya/features/auth/providers/auth_providers.dart';
import 'package:nirbhaya/features/profile/data/profile_api.dart';
import 'package:nirbhaya/features/profile/data/profile_repository.dart';

final profileApiProvider = Provider<ProfileApi>((ref) {
  return ProfileApi(ref.watch(apiClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(profileApiProvider));
});

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel?>> {
  final ProfileRepository repository;

  ProfileNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      // First, try loading cached profile for faster UI
      final cached = await repository.getCachedProfile();
      if (cached != null) {
        state = AsyncValue.data(cached);
      }

      // Then fetch fresh data from API
      final profile = await repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      if (!state.hasValue) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> updatePersonalInfo({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? dob,
    String? gender,
  }) async {
    state = const AsyncValue.loading();
    try {
      final updatedProfile = await repository.updateProfile(
        name: name,
        emergencyPhone: phone,
        emergencyEmail: email,
        address: address,
        dob: dob,
        gender: gender,
      );
      state = AsyncValue.data(updatedProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateMedicalInfo({
    String? bloodGroup,
    String? allergies,
    String? conditions,
    String? primaryPhysician,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final updatedProfile = await repository.updateProfile(
        bloodGroup: bloodGroup,
        allergies: allergies,
        conditions: conditions,
        primaryPhysician: primaryPhysician,
        medicalNotes: notes,
      );
      state = AsyncValue.data(updatedProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateEmergencyIdentifiers({
    String? govtId,
    String? emergencyCode,
    String? vehicleNumber,
  }) async {
    state = const AsyncValue.loading();
    try {
      final updatedProfile = await repository.updateProfile(
        govtId: govtId,
        emergencyCode: emergencyCode,
        vehicleNumber: vehicleNumber,
      );
      state = AsyncValue.data(updatedProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel?>>((ref) {
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});
