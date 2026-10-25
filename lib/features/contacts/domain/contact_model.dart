class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final int priority;
  final bool isPrimary;
  final String? relation;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.priority = 0,
    this.isPrimary = false,
    this.relation,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      priority: json['priority'] as int? ?? 0,
      isPrimary: json['isPrimary'] as bool? ?? false,
      relation: json['relation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'priority': priority,
      'isPrimary': isPrimary,
      'relation': relation,
    };
  }

  EmergencyContact copyWith({
    String? id, String? name, String? phone, String? email,
    int? priority, bool? isPrimary, String? relation,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      priority: priority ?? this.priority,
      isPrimary: isPrimary ?? this.isPrimary,
      relation: relation ?? this.relation,
    );
  }
}
