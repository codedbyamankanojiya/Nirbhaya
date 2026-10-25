import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:nirbhaya/features/auth/providers/auth_providers.dart';
import 'package:nirbhaya/features/location/providers/location_provider.dart';
import 'package:nirbhaya/features/sos/data/sos_api.dart';
import 'package:nirbhaya/features/sos/data/sos_repository.dart';
import '../domain/sos_state.dart';

final sosApiProvider = Provider<SosApi>((ref) => SosApi(ref.watch(apiClientProvider)));

final sosRepositoryProvider = Provider<SosRepository>((ref) {
  return SosRepository(
    ref.watch(sosApiProvider),
    ref.watch(locationServiceProvider),
  );
});

final sosProvider = StateNotifierProvider<SosNotifier, SosState>((ref) {
  return SosNotifier(ref.watch(sosRepositoryProvider));
});

class SosNotifier extends StateNotifier<SosState> {
  final SosRepository _sosRepository;
  Timer? _countdownTimer;
  bool _isCancelled = false;

  SosNotifier(this._sosRepository) : super(SosState());

  void triggerSos({int countdownDuration = 3}) {
    _cancelTimer();
    _isCancelled = false;
    state = state.copyWith(
      status: SosStatus.countdown,
      countdownSeconds: countdownDuration,
      errorMessage: null,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isCancelled) {
        timer.cancel();
        return;
      }

      if (state.countdownSeconds > 1) {
        state = state.copyWith(countdownSeconds: state.countdownSeconds - 1);
      } else {
        timer.cancel();
        _countdownTimer = null;
        if (!_isCancelled) {
          _activateSos();
        }
      }
    });
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  Future<void> cancelSos() async {
    _isCancelled = true;
    _cancelTimer();

    final activeSosId = state.sosId;

    // Reset state immediately so UI updates synchronously
    state = SosState(status: SosStatus.idle);

    try {
      await WakelockPlus.disable();
    } catch (_) {}

    try {
      await Vibration.cancel();
    } catch (_) {}

    if (activeSosId != null) {
      try {
        await _sosRepository.cancelSos(activeSosId);
      } catch (_) {}
    }
  }

  Future<void> _activateSos() async {
    if (_isCancelled) return;
    state = state.copyWith(status: SosStatus.activating);

    try {
      await WakelockPlus.enable();
    } catch (_) {}

    try {
      final result = await _sosRepository.triggerSos();
      if (_isCancelled) return;

      final effectiveSosId = result.sosId ?? 'local_sos_${DateTime.now().millisecondsSinceEpoch}';

      state = state.copyWith(
        status: SosStatus.active,
        sosId: effectiveSosId,
        latitude: result.latitude,
        longitude: result.longitude,
        errorMessage: result.success ? null : 'Offline emergency dispatch active',
      );
    } catch (e) {
      if (_isCancelled) return;
      state = state.copyWith(
        status: SosStatus.active,
        sosId: 'local_sos_${DateTime.now().millisecondsSinceEpoch}',
        errorMessage: 'Local emergency mode active',
      );
    }
  }

  Future<void> resolveSos() async {
    _isCancelled = true;
    _cancelTimer();

    final activeSosId = state.sosId;

    try {
      await WakelockPlus.disable();
    } catch (_) {}

    try {
      await Vibration.cancel();
    } catch (_) {}

    state = state.copyWith(status: SosStatus.resolved);

    if (activeSosId != null) {
      try {
        await _sosRepository.resolveSos(activeSosId);
      } catch (_) {}
    }

    // Clean reset to idle state
    state = SosState(status: SosStatus.idle);
  }

  void resetToIdle() {
    _isCancelled = true;
    _cancelTimer();
    state = SosState(status: SosStatus.idle);
  }

  @override
  void dispose() {
    _cancelTimer();
    _isCancelled = true;
    WakelockPlus.disable();
    Vibration.cancel();
    super.dispose();
  }
}
