import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/features/auth/providers/auth_providers.dart';
import 'package:nirbhaya/features/incidents/data/incidents_api.dart';
import 'package:nirbhaya/features/incidents/domain/incident_model.dart';

final incidentsApiProvider = Provider<IncidentsApi>((ref) {
  return IncidentsApi(ref.watch(apiClientProvider));
});

class IncidentsNotifier extends StateNotifier<AsyncValue<List<Incident>>> {
  final IncidentsApi _api;

  IncidentsNotifier(this._api) : super(const AsyncValue.loading()) {
    loadIncidents();
  }

  Future<void> loadIncidents() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getMyIncidents();
      if (response.success) {
        final List<dynamic> data = response.data as List<dynamic>;
        final incidents = data.map((json) => Incident.fromJson(json as Map<String, dynamic>)).toList();
        state = AsyncValue.data(incidents);
      } else {
        state = AsyncValue.error(response.message, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createIncident({
    required String title,
    required String description,
    required String category,
    double? latitude,
    double? longitude,
    bool isAnonymous = false,
    List<String>? mediaIds,
  }) async {
    try {
      final response = await _api.createIncident(
        title: title,
        description: description,
        category: category,
        latitude: latitude,
        longitude: longitude,
        isAnonymous: isAnonymous,
        mediaIds: mediaIds,
      );
      if (response.success) {
        await loadIncidents();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteIncident(String id) async {
    try {
      final response = await _api.deleteIncident(id);
      if (response.success) {
        await loadIncidents();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }
}

final incidentsProvider = StateNotifierProvider<IncidentsNotifier, AsyncValue<List<Incident>>>((ref) {
  return IncidentsNotifier(ref.watch(incidentsApiProvider));
});
