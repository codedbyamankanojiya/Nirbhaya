import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/features/auth/providers/auth_providers.dart';
import 'package:nirbhaya/features/dashboard/data/dashboard_api.dart';
import 'package:nirbhaya/features/dashboard/domain/dashboard_model.dart';

final dashboardApiProvider = Provider<DashboardApi>((ref) {
  return DashboardApi(ref.watch(apiClientProvider));
});

final dashboardProvider = StateNotifierProvider<DashboardNotifier, AsyncValue<UserStats>>((ref) {
  return DashboardNotifier(ref.watch(dashboardApiProvider));
});

class DashboardNotifier extends StateNotifier<AsyncValue<UserStats>> {
  final DashboardApi _dashboardApi;

  DashboardNotifier(this._dashboardApi) : super(const AsyncValue.loading()) {
    loadStats();
  }

  Future<void> loadStats() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dashboardApi.getUserStats();
      if (response.success && response.data != null) {
        state = AsyncValue.data(UserStats.fromJson(response.data as Map<String, dynamic>));
      } else {
        final msg = response.message.isNotEmpty ? response.message : 'Failed to load stats';
        state = AsyncValue.error(msg, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
