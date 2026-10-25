class UserStats {
  final int sosCount;
  final int incidentsCount;
  final int contactsCount;

  const UserStats({
    required this.sosCount,
    required this.incidentsCount,
    required this.contactsCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      sosCount: json['sosCount'] as int? ?? 0,
      incidentsCount: json['incidentsCount'] as int? ?? 0,
      contactsCount: json['contactsCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sosCount': sosCount,
      'incidentsCount': incidentsCount,
      'contactsCount': contactsCount,
    };
  }

  UserStats copyWith({
    int? sosCount,
    int? incidentsCount,
    int? contactsCount,
  }) {
    return UserStats(
      sosCount: sosCount ?? this.sosCount,
      incidentsCount: incidentsCount ?? this.incidentsCount,
      contactsCount: contactsCount ?? this.contactsCount,
    );
  }
}
