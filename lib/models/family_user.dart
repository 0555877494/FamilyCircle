enum UserRole { admin, parent, child, grandparent, extended }

class FamilyUser {
  final String id;
  final String familyId;
  final String firstName;
  final String? lastName;
  final String? avatarUrl;
  final UserRole role;
  final bool isKidMode;
  final DateTime? dateOfBirth;
  final String? birthplace;
  final String? nationality;
  final Map<String, String>? culturalHeritage;
  final DateTime createdAt;

  FamilyUser({
    required this.id,
    required this.familyId,
    required this.firstName,
    this.lastName,
    this.avatarUrl,
    required this.role,
    this.isKidMode = false,
    this.dateOfBirth,
    this.birthplace,
    this.nationality,
    this.culturalHeritage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'isKidMode': isKidMode,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'birthplace': birthplace,
      'nationality': nationality,
      'culturalHeritage': culturalHeritage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyUser.fromMap(Map<String, dynamic> map) {
    return FamilyUser(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      isKidMode: map['isKidMode'] as bool? ?? false,
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth'] as String) : null,
      birthplace: map['birthplace'] as String?,
      nationality: map['nationality'] as String?,
      culturalHeritage: map['culturalHeritage'] != null 
          ? Map<String, String>.from(map['culturalHeritage'] as Map)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  FamilyUser copyWith({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    bool? isKidMode,
    DateTime? dateOfBirth,
    String? birthplace,
    String? nationality,
    Map<String, String>? culturalHeritage,
  }) {
    return FamilyUser(
      id: id,
      familyId: familyId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      isKidMode: isKidMode ?? this.isKidMode,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      birthplace: birthplace ?? this.birthplace,
      nationality: nationality ?? this.nationality,
      culturalHeritage: culturalHeritage ?? this.culturalHeritage,
      createdAt: createdAt,
    );
  }
}