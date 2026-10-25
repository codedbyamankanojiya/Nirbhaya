enum SosStatus { idle, countdown, activating, active, resolving, resolved, cancelled, failed }

class SosState {
  final SosStatus status;
  final int countdownSeconds;
  final String? sosId;
  final String? errorMessage;
  final double? latitude;
  final double? longitude;

  SosState({
    this.status = SosStatus.idle,
    this.countdownSeconds = 0,
    this.sosId,
    this.errorMessage,
    this.latitude,
    this.longitude,
  });

  SosState copyWith({
    SosStatus? status,
    int? countdownSeconds,
    String? sosId,
    String? errorMessage,
    double? latitude,
    double? longitude,
  }) {
    return SosState(
      status: status ?? this.status,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      sosId: sosId ?? this.sosId,
      errorMessage: errorMessage ?? this.errorMessage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
