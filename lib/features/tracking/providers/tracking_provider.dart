import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirbhaya/features/tracking/domain/tracking_model.dart';

class TrackingState {
  final bool isTracking;
  final Journey? currentJourney;
  final int elapsedDuration; // in seconds
  final Position? currentPosition;
  final List<Journey> history;

  TrackingState({
    this.isTracking = false,
    this.currentJourney,
    this.elapsedDuration = 0,
    this.currentPosition,
    this.history = const [],
  });

  TrackingState copyWith({
    bool? isTracking,
    Journey? currentJourney,
    int? elapsedDuration,
    Position? currentPosition,
    List<Journey>? history,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      currentJourney: currentJourney ?? this.currentJourney,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      currentPosition: currentPosition ?? this.currentPosition,
      history: history ?? this.history,
    );
  }
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  static const String _historyKey = 'tracking_journey_history';
  StreamSubscription<Position>? _positionSubscription;
  Timer? _durationTimer;

  TrackingNotifier() : super(TrackingState()) {
    _loadSavedHistory();
  }

  Future<void> _loadSavedHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_historyKey);
      if (jsonStr != null) {
        final List<dynamic> list = jsonDecode(jsonStr);
        final loaded = list.map((e) => Journey.fromJson(e as Map<String, dynamic>)).toList();
        state = state.copyWith(history: loaded);
      }
    } catch (_) {}
  }

  Future<void> _persistHistory(List<Journey> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = history.map((j) => j.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(list));
    } catch (_) {}
  }

  Future<void> startJourney() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final newJourney = Journey(
      id: 'journey_${DateTime.now().millisecondsSinceEpoch}',
      startTime: DateTime.now(),
      waypoints: [],
      isActive: true,
    );

    state = state.copyWith(
      isTracking: true,
      currentJourney: newJourney,
      elapsedDuration: 0,
    );

    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedDuration: state.elapsedDuration + 1);
    });

    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(_onPositionUpdate);
  }

  void _onPositionUpdate(Position position) {
    if (state.currentJourney != null) {
      final waypoint = LatLngPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );

      final updatedWaypoints = List<LatLngPoint>.from(state.currentJourney!.waypoints)..add(waypoint);
      final updatedJourney = state.currentJourney!.copyWith(waypoints: updatedWaypoints);

      state = state.copyWith(
        currentPosition: position,
        currentJourney: updatedJourney,
      );
    }
  }

  void stopJourney() {
    _positionSubscription?.cancel();
    _durationTimer?.cancel();

    if (state.currentJourney != null) {
      final finishedJourney = state.currentJourney!.copyWith(
        endTime: DateTime.now(),
        isActive: false,
      );

      final updatedHistory = List<Journey>.from(state.history)..insert(0, finishedJourney);
      _persistHistory(updatedHistory);

      state = state.copyWith(
        isTracking: false,
        currentJourney: null,
        elapsedDuration: 0,
        currentPosition: null,
        history: updatedHistory,
      );
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }
}

final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier();
});
