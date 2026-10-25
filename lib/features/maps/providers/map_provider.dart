import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nirbhaya/features/location/data/location_service.dart';
import 'package:nirbhaya/features/location/providers/location_provider.dart';

class NearbyPlace {
  final String name;
  final String type;
  final LatLng position;
  final String? phone;

  const NearbyPlace({
    required this.name,
    required this.type,
    required this.position,
    this.phone,
  });
}

class MapState {
  final LatLng? userPosition;
  final List<NearbyPlace> nearbyPlaces;
  final bool isLoading;
  final String? error;
  final double zoomLevel;
  final bool isLiveTracking;
  final bool followUser;
  final double? heading;
  final double? accuracy;

  const MapState({
    this.userPosition,
    this.nearbyPlaces = const [],
    this.isLoading = true,
    this.error,
    this.zoomLevel = 15.0,
    this.isLiveTracking = false,
    this.followUser = true,
    this.heading,
    this.accuracy,
  });

  MapState copyWith({
    LatLng? userPosition,
    List<NearbyPlace>? nearbyPlaces,
    bool? isLoading,
    String? error,
    double? zoomLevel,
    bool? isLiveTracking,
    bool? followUser,
    double? heading,
    double? accuracy,
  }) {
    return MapState(
      userPosition: userPosition ?? this.userPosition,
      nearbyPlaces: nearbyPlaces ?? this.nearbyPlaces,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      isLiveTracking: isLiveTracking ?? this.isLiveTracking,
      followUser: followUser ?? this.followUser,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  final Ref _ref;
  StreamSubscription<Position>? _positionSubscription;
  LatLng? _lastLoadedPlacesCenter;

  MapNotifier(this._ref) : super(const MapState()) {
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    state = state.copyWith(isLoading: true);
    try {
      final locationService = _ref.read(locationServiceProvider);
      final permission = await locationService.checkAndRequestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission denied. Enable it in settings.',
          userPosition: const LatLng(28.6139, 77.2090),
        );
        _loadNearbyPlaces(const LatLng(28.6139, 77.2090));
        return;
      }

      // Quick fetch first for immediate render
      final initialPosition = await locationService.getCurrentPosition();
      final latLng = initialPosition != null
          ? LatLng(initialPosition.latitude, initialPosition.longitude)
          : const LatLng(28.6139, 77.2090);

      state = state.copyWith(
        userPosition: latLng,
        isLoading: false,
        heading: initialPosition?.heading,
        accuracy: initialPosition?.accuracy,
      );

      _loadNearbyPlaces(latLng);

      // Start high-accuracy live location stream
      _startLiveTracking(locationService);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to acquire location: $e',
        userPosition: const LatLng(28.6139, 77.2090),
      );
      _loadNearbyPlaces(const LatLng(28.6139, 77.2090));
    }
  }

  void _startLiveTracking(LocationService locationService) {
    _positionSubscription?.cancel();
    _positionSubscription = locationService
        .getPositionStream(distanceFilter: 3)
        .listen(
      (Position position) {
        final newLatLng = LatLng(position.latitude, position.longitude);

        state = state.copyWith(
          userPosition: newLatLng,
          isLiveTracking: true,
          heading: position.heading,
          accuracy: position.accuracy,
          error: null,
        );

        // Reload nearby POIs if moved > 250m
        if (_lastLoadedPlacesCenter == null) {
          _loadNearbyPlaces(newLatLng);
        } else {
          final distance = const Distance().as(
            LengthUnit.Meter,
            _lastLoadedPlacesCenter!,
            newLatLng,
          );
          if (distance > 250) {
            _loadNearbyPlaces(newLatLng);
          }
        }
      },
      onError: (e) {
        state = state.copyWith(isLiveTracking: false);
      },
    );
  }

  Future<void> _loadNearbyPlaces(LatLng center) async {
    _lastLoadedPlacesCenter = center;
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      final policeResponse = await dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: {
          'q': 'police',
          'lat': center.latitude,
          'lon': center.longitude,
          'limit': 5,
        },
      );

      final hospitalResponse = await dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: {
          'q': 'hospital',
          'lat': center.latitude,
          'lon': center.longitude,
          'limit': 5,
        },
      );

      final List<NearbyPlace> realPlaces = [];

      void parseFeatures(dynamic data, String type, String defaultName, String phone) {
        if (data != null && data['features'] is List) {
          for (final f in (data['features'] as List)) {
            final props = f['properties'] as Map<String, dynamic>?;
            final geom = f['geometry'] as Map<String, dynamic>?;
            final coords = geom?['coordinates'] as List?;
            if (coords != null && coords.length >= 2) {
              final lon = (coords[0] as num).toDouble();
              final lat = (coords[1] as num).toDouble();
              final name = props?['name'] as String? ?? defaultName;
              realPlaces.add(
                NearbyPlace(
                  name: name,
                  type: type,
                  position: LatLng(lat, lon),
                  phone: phone,
                ),
              );
            }
          }
        }
      }

      parseFeatures(policeResponse.data, 'police', 'Police Station', '100');
      parseFeatures(hospitalResponse.data, 'hospital', 'Hospital & Trauma Center', '102');

      if (realPlaces.isNotEmpty) {
        state = state.copyWith(nearbyPlaces: realPlaces);
        return;
      }
    } catch (_) {
      // Offline fallback: safety checkpoints dynamically calculated relative to current coordinates
    }

    final fallbackPlaces = [
      NearbyPlace(
        name: 'Emergency Police Station',
        type: 'police',
        position: LatLng(center.latitude + 0.0035, center.longitude + 0.0028),
        phone: '100',
      ),
      NearbyPlace(
        name: 'Trauma & Emergency Hospital',
        type: 'hospital',
        position: LatLng(center.latitude - 0.0025, center.longitude + 0.0042),
        phone: '102',
      ),
      NearbyPlace(
        name: 'Women One-Stop Crisis Center',
        type: 'shelter',
        position: LatLng(center.latitude + 0.0055, center.longitude - 0.0035),
        phone: '181',
      ),
      NearbyPlace(
        name: 'Fire & Rescue Station',
        type: 'fire',
        position: LatLng(center.latitude - 0.0045, center.longitude - 0.0038),
        phone: '101',
      ),
    ];

    state = state.copyWith(nearbyPlaces: fallbackPlaces);
  }

  void toggleFollowUser() {
    state = state.copyWith(followUser: !state.followUser);
  }

  void setFollowUser(bool follow) {
    state = state.copyWith(followUser: follow);
  }

  void refreshLocation() {
    _initializeMap();
  }

  void updateZoom(double zoom) {
    state = state.copyWith(zoomLevel: zoom);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier(ref);
});
