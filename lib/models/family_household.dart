enum HouseholdType {
  nuclear,
  extended,
  multigenerational,
  singleParent,
  cohabiting,
}

enum ResidenceType {
  house,
  apartment,
  shared,
  multiUnit,
}

class FamilyHousehold {
  final String id;
  final String familyId;
  final String? name;
  final HouseholdType householdType;
  final ResidenceType residenceType;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final List<String> residentMemberIds;
  final bool isPrimaryResidence;
  final DateTime? moveInDate;

  FamilyHousehold({
    required this.id,
    required this.familyId,
    this.name,
    this.householdType = HouseholdType.nuclear,
    this.residenceType = ResidenceType.house,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    required this.residentMemberIds,
    this.isPrimaryResidence = true,
    this.moveInDate,
  });

  String get fullAddress {
    final parts = <String>[];
    if (address != null) parts.add(address!);
    if (city != null) parts.add(city!);
    if (state != null) parts.add(state!);
    if (postalCode != null) parts.add(postalCode!);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'name': name,
      'householdType': householdType.name,
      'residenceType': residenceType.name,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'residentMemberIds': residentMemberIds,
      'isPrimaryResidence': isPrimaryResidence,
      'moveInDate': moveInDate?.toIso8601String(),
    };
  }

  factory FamilyHousehold.fromMap(Map<String, dynamic> map) {
    return FamilyHousehold(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      name: map['name'] as String?,
      householdType: HouseholdType.values.firstWhere(
        (e) => e.name == map['householdType'],
        orElse: () => HouseholdType.nuclear,
      ),
      residenceType: ResidenceType.values.firstWhere(
        (e) => e.name == map['residenceType'],
        orElse: () => ResidenceType.house,
      ),
      address: map['address'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      postalCode: map['postalCode'] as String?,
      country: map['country'] as String?,
      residentMemberIds: List<String>.from(map['residentMemberIds'] as List),
      isPrimaryResidence: map['isPrimaryResidence'] as bool? ?? true,
      moveInDate: map['moveInDate'] != null ? DateTime.parse(map['moveInDate'] as String) : null,
    );
  }
}