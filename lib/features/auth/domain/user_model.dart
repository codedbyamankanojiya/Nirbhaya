class UserModel {
  final String id;
  final String email;
  final String role;
  final ProfileModel? profile;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'USER',
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        if (profile != null) 'profile': profile!.toJson(),
      };
}

class ProfileModel {
  final String id;
  final String userId;
  final String name;
  final String? dob;
  final String? gender;
  final String? bloodGroup;
  final String? emergencyEmail;
  final String? emergencyPhone;
  final String? address;
  final String? profileImageUrl;
  final String? allergies;
  final String? conditions;
  final String? primaryPhysician;
  final String? medicalNotes;
  final String? govtId;
  final String? emergencyCode;
  final String? vehicleNumber;

  const ProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    this.dob,
    this.gender,
    this.bloodGroup,
    this.emergencyEmail,
    this.emergencyPhone,
    this.address,
    this.profileImageUrl,
    this.allergies,
    this.conditions,
    this.primaryPhysician,
    this.medicalNotes,
    this.govtId,
    this.emergencyCode,
    this.vehicleNumber,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? 'profile_${DateTime.now().millisecondsSinceEpoch}',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      emergencyEmail: json['emergencyEmail'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
      address: json['address'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      allergies: json['allergies'] as String?,
      conditions: json['conditions'] as String?,
      primaryPhysician: json['primaryPhysician'] as String?,
      medicalNotes: json['medicalNotes'] as String?,
      govtId: json['govtId'] as String?,
      emergencyCode: json['emergencyCode'] as String?,
      vehicleNumber: json['vehicleNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        if (dob != null) 'dob': dob,
        if (gender != null) 'gender': gender,
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        if (emergencyEmail != null) 'emergencyEmail': emergencyEmail,
        if (emergencyPhone != null) 'emergencyPhone': emergencyPhone,
        if (address != null) 'address': address,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (allergies != null) 'allergies': allergies,
        if (conditions != null) 'conditions': conditions,
        if (primaryPhysician != null) 'primaryPhysician': primaryPhysician,
        if (medicalNotes != null) 'medicalNotes': medicalNotes,
        if (govtId != null) 'govtId': govtId,
        if (emergencyCode != null) 'emergencyCode': emergencyCode,
        if (vehicleNumber != null) 'vehicleNumber': vehicleNumber,
      };

  ProfileModel copyWith({
    String? name,
    String? dob,
    String? gender,
    String? bloodGroup,
    String? emergencyEmail,
    String? emergencyPhone,
    String? address,
    String? profileImageUrl,
    String? allergies,
    String? conditions,
    String? primaryPhysician,
    String? medicalNotes,
    String? govtId,
    String? emergencyCode,
    String? vehicleNumber,
  }) {
    return ProfileModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      emergencyEmail: emergencyEmail ?? this.emergencyEmail,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
      primaryPhysician: primaryPhysician ?? this.primaryPhysician,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      govtId: govtId ?? this.govtId,
      emergencyCode: emergencyCode ?? this.emergencyCode,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
    );
  }
}
