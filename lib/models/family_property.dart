import 'family_user.dart';

enum PropertyType {
  realEstate,
  vehicle,
  bankAccount,
  investment,
  safeDepositBox,
  valuable,
  document,
  insurance,
  subscription,
  digitalAccount,
  other,
}

enum PropertyAccess {
  anyone,
  parentsOnly,
  adultsOnly,
  specificMembers,
}

class FamilyProperty {
  final String id;
  final String familyId;
  final String name;
  final String? description;
  final PropertyType type;
  final String? location;
  final String? notes;
  final String? value;
  final String? accountNumber;
  final String? institution;
  final String? contactPhone;
  final String? contactEmail;
  final List<String> accessMemberIds;
  final PropertyAccess accessLevel;
  final String? addedById;
  final DateTime createdAt;
  final DateTime? lastVerified;

  FamilyProperty({
    required this.id,
    required this.familyId,
    required this.name,
    this.description,
    required this.type,
    this.location,
    this.notes,
    this.value,
    this.accountNumber,
    this.institution,
    this.contactPhone,
    this.contactEmail,
    this.accessMemberIds = const [],
    this.accessLevel = PropertyAccess.anyone,
    this.addedById,
    required this.createdAt,
    this.lastVerified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'name': name,
      'description': description,
      'type': type.name,
      'location': location,
      'notes': notes,
      'value': value,
      'accountNumber': accountNumber,
      'institution': institution,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'accessMemberIds': accessMemberIds,
      'accessLevel': accessLevel.name,
      'addedById': addedById,
      'createdAt': createdAt.toIso8601String(),
      'lastVerified': lastVerified?.toIso8601String(),
    };
  }

  factory FamilyProperty.fromMap(Map<String, dynamic> map) {
    return FamilyProperty(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      type: PropertyType.values.firstWhere((e) => e.name == map['type']),
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      value: map['value'] as String?,
      accountNumber: map['accountNumber'] as String?,
      institution: map['institution'] as String?,
      contactPhone: map['contactPhone'] as String?,
      contactEmail: map['contactEmail'] as String?,
      accessMemberIds: map['accessMemberIds'] != null ? List<String>.from(map['accessMemberIds'] as List) : [],
      accessLevel: PropertyAccess.values.firstWhere(
        (e) => e.name == map['accessLevel'],
        orElse: () => PropertyAccess.anyone,
      ),
      addedById: map['addedById'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastVerified: map['lastVerified'] != null 
          ? DateTime.parse(map['lastVerified'] as String) 
          : null,
    );
  }

  FamilyProperty copyWith({DateTime? lastVerified}) {
    return FamilyProperty(
      id: id,
      familyId: familyId,
      name: name,
      description: description,
      type: type,
      location: location,
      notes: notes,
      value: value,
      accountNumber: accountNumber,
      institution: institution,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      accessMemberIds: accessMemberIds,
      accessLevel: accessLevel,
      addedById: addedById,
      createdAt: createdAt,
      lastVerified: lastVerified ?? this.lastVerified,
    );
  }
}