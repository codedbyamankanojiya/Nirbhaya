class Journey {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<LatLngPoint> waypoints;
  final bool isActive;

  Journey({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.waypoints,
    this.isActive = true,
  });

  Journey copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    List<LatLngPoint>? waypoints,
    bool? isActive,
  }) {
    return Journey(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      waypoints: waypoints ?? this.waypoints,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      waypoints: (json['waypoints'] as List<dynamic>?)
              ?.map((e) => LatLngPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'waypoints': waypoints.map((e) => e.toJson()).toList(),
      'isActive': isActive,
    };
  }
}

class LatLngPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LatLngPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LatLngPoint.fromJson(Map<String, dynamic> json) {
    return LatLngPoint(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
