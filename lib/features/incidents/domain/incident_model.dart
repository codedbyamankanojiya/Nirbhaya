class Incident {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final double? latitude;
  final double? longitude;
  final bool isAnonymous;
  final String status;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Incident({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    this.latitude,
    this.longitude,
    this.isAnonymous = false,
    this.status = 'PENDING',
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      status: json['status'] as String? ?? 'PENDING',
      adminNotes: json['adminNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'isAnonymous': isAnonymous,
      'status': status,
      'adminNotes': adminNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
