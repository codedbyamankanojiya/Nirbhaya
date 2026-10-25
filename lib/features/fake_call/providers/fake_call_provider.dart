import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

class FakeCallState {
  final String callerName;
  final String callerRelation;
  final int delaySeconds;
  final bool isRinging;
  final bool isInCall;
  final int callDuration;

  FakeCallState({
    this.callerName = 'Mom',
    this.callerRelation = 'Family',
    this.delaySeconds = 0,
    this.isRinging = false,
    this.isInCall = false,
    this.callDuration = 0,
  });

  FakeCallState copyWith({
    String? callerName,
    String? callerRelation,
    int? delaySeconds,
    bool? isRinging,
    bool? isInCall,
    int? callDuration,
  }) {
    return FakeCallState(
      callerName: callerName ?? this.callerName,
      callerRelation: callerRelation ?? this.callerRelation,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      isRinging: isRinging ?? this.isRinging,
      isInCall: isInCall ?? this.isInCall,
      callDuration: callDuration ?? this.callDuration,
    );
  }
}

class FakeCallNotifier extends StateNotifier<FakeCallState> {
  FakeCallNotifier() : super(FakeCallState());

  Timer? _delayTimer;
  Timer? _callTimer;
  Timer? _vibrationTimer;

  void setCallerInfo(String name, String relation) {
    state = state.copyWith(callerName: name, callerRelation: relation);
  }

  void startFakeCall(int delaySeconds) {
    state = state.copyWith(
      delaySeconds: delaySeconds,
      isRinging: false,
      isInCall: false,
      callDuration: 0,
    );

    _delayTimer?.cancel();
    _delayTimer = Timer(Duration(seconds: delaySeconds), () {
      state = state.copyWith(isRinging: true);
      _startVibration();
    });
  }

  void _startVibration() {
    _vibrationTimer?.cancel();
    _vibrationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (state.isRinging) {
        HapticFeedback.vibrate();
      } else {
        timer.cancel();
      }
    });
  }

  void acceptCall() {
    _vibrationTimer?.cancel();
    state = state.copyWith(isRinging: false, isInCall: true);
    
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(callDuration: state.callDuration + 1);
    });
  }

  void endCall() {
    _cleanup();
    state = FakeCallState(); // Reset state
  }

  void declineCall() {
    endCall();
  }

  void _cleanup() {
    _delayTimer?.cancel();
    _callTimer?.cancel();
    _vibrationTimer?.cancel();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}

final fakeCallProvider = StateNotifierProvider<FakeCallNotifier, FakeCallState>((ref) {
  return FakeCallNotifier();
});
