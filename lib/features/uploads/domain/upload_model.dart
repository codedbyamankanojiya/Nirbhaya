class UploadedMedia {
  final String id;
  final String url;
  final String type;
  final int size;
  final String publicId;
  final DateTime createdAt;

  UploadedMedia({
    required this.id,
    required this.url,
    required this.type,
    required this.size,
    required this.publicId,
    required this.createdAt,
  });

  UploadedMedia copyWith({
    String? id,
    String? url,
    String? type,
    int? size,
    String? publicId,
    DateTime? createdAt,
  }) {
    return UploadedMedia(
      id: id ?? this.id,
      url: url ?? this.url,
      type: type ?? this.type,
      size: size ?? this.size,
      publicId: publicId ?? this.publicId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UploadedMedia.fromJson(Map<String, dynamic> json) {
    return UploadedMedia(
      id: json['_id'] ?? json['id'] ?? '',
      url: json['url'] as String? ?? '',
      type: json['type'] as String? ?? 'image',
      size: json['size'] as int? ?? 0,
      publicId: json['publicId'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type,
      'size': size,
      'publicId': publicId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
