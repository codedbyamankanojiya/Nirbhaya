import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nirbhaya/app/theme.dart';
import 'package:nirbhaya/shared/widgets/app_header.dart';
import 'package:nirbhaya/features/maps/providers/map_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  NearbyPlace? _selectedPlace;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _recenterOnUser(LatLng? position) {
    if (position != null) {
      ref.read(mapProvider.notifier).setFollowUser(true);
      _mapController.move(position, 16.0);
    } else {
      ref.read(mapProvider.notifier).refreshLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);

    // Auto-center when live tracking stream updates if followUser is enabled
    ref.listen<MapState>(mapProvider, (prev, next) {
      if (next.followUser && next.userPosition != null) {
        if (prev?.userPosition == null ||
            prev!.userPosition!.latitude != next.userPosition!.latitude ||
            prev.userPosition!.longitude != next.userPosition!.longitude) {
          _mapController.move(next.userPosition!, _mapController.camera.zoom);
        }
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppHeader(title: 'Safety Map'),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Follow user toggle
            FloatingActionButton.small(
              heroTag: 'map_follow_toggle',
              backgroundColor: mapState.followUser ? const Color(0xFFE11D48) : const Color(0xFF1E1E2C),
              foregroundColor: Colors.white,
              onPressed: () => ref.read(mapProvider.notifier).toggleFollowUser(),
              tooltip: mapState.followUser ? 'Locking Camera to GPS' : 'Free Camera',
              child: Icon(mapState.followUser ? Icons.lock : Icons.lock_open, size: 18),
            ),
            const SizedBox(height: 10),
            // Recenter
            FloatingActionButton(
              heroTag: 'map_recenter',
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              onPressed: () => _recenterOnUser(mapState.userPosition),
              child: const Icon(Icons.my_location),
            ),
          ],
        ),
      ),
      body: mapState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: mapState.userPosition ?? const LatLng(28.6139, 77.2090),
                    initialZoom: mapState.zoomLevel,
                    minZoom: 3,
                    maxZoom: 18,
                    onPositionChanged: (pos, hasGesture) {
                      if (hasGesture && mapState.followUser) {
                        ref.read(mapProvider.notifier).setFollowUser(false);
                      }
                    },
                    onTap: (_, __) => setState(() => _selectedPlace = null),
                  ),
                  children: [
                    // OpenStreetMap Tile Layer
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.nirbhaya.nirbhaya',
                      tileBuilder: _darkModeTileBuilder,
                    ),

                    // User Location Radar & Marker
                    if (mapState.userPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: mapState.userPosition!,
                            width: 64,
                            height: 64,
                            child: AnimatedBuilder(
                              animation: _radarController,
                              builder: (context, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Pulsing Radar Wave
                                    Container(
                                      width: 24 + (_radarController.value * 40),
                                      height: 24 + (_radarController.value * 40),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blueAccent.withValues(
                                          alpha: (1.0 - _radarController.value) * 0.4,
                                        ),
                                      ),
                                    ),
                                    // Core Beacon
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withValues(alpha: 0.6),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                    // Nearby Safe Places Markers
                    MarkerLayer(
                      markers: mapState.nearbyPlaces.map((place) {
                        return Marker(
                          point: place.position,
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPlace = place),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getPlaceColor(place.type),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getPlaceColor(place.type).withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getPlaceIcon(place.type),
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Live Tracking Status Pill
                Positioned(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101018).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: mapState.isLiveTracking ? Colors.greenAccent : Colors.amberAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          mapState.isLiveTracking ? 'Live GPS Stream Active' : 'Acquiring GPS Signal...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (mapState.accuracy != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '±${mapState.accuracy!.toStringAsFixed(0)}m',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Error Banner
                if (mapState.error != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + kToolbarHeight + 46,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade900,
                        borderRadius: AppRadius.baseRadius,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mapState.error!,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom Overlay: Selected Place Card or Legend
                Positioned(
                  bottom: 80,
                  left: 16,
                  right: 16,
                  child: _selectedPlace != null
                      ? _PlaceDetailCard(
                          place: _selectedPlace!,
                          onClose: () => setState(() => _selectedPlace = null),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101018).withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _legendItem(Colors.blue, Icons.shield, 'Police'),
                              _legendItem(Colors.red, Icons.local_hospital, 'Hospital'),
                              _legendItem(Colors.purple, Icons.home, 'Safe Shelter'),
                              _legendItem(Colors.orange, Icons.local_fire_department, 'Fire Station'),
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _darkModeTileBuilder(BuildContext context, Widget tileWidget, TileImage tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        -0.8, 0, 0, 0, 220,
        0, -0.8, 0, 0, 220,
        0, 0, -0.8, 0, 220,
        0, 0, 0, 1, 0,
      ]),
      child: tileWidget,
    );
  }

  Widget _legendItem(Color color, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  Color _getPlaceColor(String type) {
    switch (type) {
      case 'police':
        return Colors.blue;
      case 'hospital':
        return Colors.red;
      case 'shelter':
        return Colors.purple;
      case 'fire':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getPlaceIcon(String type) {
    switch (type) {
      case 'police':
        return Icons.shield;
      case 'hospital':
        return Icons.local_hospital;
      case 'shelter':
        return Icons.home;
      case 'fire':
        return Icons.local_fire_department;
      default:
        return Icons.place;
    }
  }
}

class _PlaceDetailCard extends StatelessWidget {
  final NearbyPlace place;
  final VoidCallback onClose;

  const _PlaceDetailCard({required this.place, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF181824),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: _getColor().withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIcon(), color: _getColor(), size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    place.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getColor(),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (place.phone != null)
              IconButton(
                onPressed: () => _callPlace(place.phone!),
                icon: const Icon(Icons.phone, color: Colors.greenAccent),
                tooltip: 'Direct Call',
              ),
            IconButton(
              onPressed: () => _openDirections(place.position),
              icon: const Icon(Icons.directions, color: Colors.blueAccent),
              tooltip: 'Get Directions',
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callPlace(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirections(LatLng position) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${position.latitude},${position.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color _getColor() {
    switch (place.type) {
      case 'police':
        return Colors.blue;
      case 'hospital':
        return Colors.redAccent;
      case 'shelter':
        return Colors.purpleAccent;
      case 'fire':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (place.type) {
      case 'police':
        return Icons.shield;
      case 'hospital':
        return Icons.local_hospital;
      case 'shelter':
        return Icons.home;
      case 'fire':
        return Icons.local_fire_department;
      default:
        return Icons.place;
    }
  }
}
