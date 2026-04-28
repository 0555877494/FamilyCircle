enum PartnershipType {
  marriage,
  civil_union,
  domestic_partnership,
  co_parenting,
  common_law,
}

enum PartnershipStatus {
  active,
  separated,
  divorced,
  widowed,
}

class FamilyPartnership {
  final String id;
  final String familyId;
  final String partnerAId;
  final String partnerBId;
  final PartnershipType partnershipType;
  final PartnershipStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLegal;

  FamilyPartnership({
    required this.id,
    required this.familyId,
    required this.partnerAId,
    required this.partnerBId,
    required this.partnershipType,
    this.status = PartnershipStatus.active,
    this.startDate,
    this.endDate,
    this.isLegal = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'partnerAId': partnerAId,
      'partnerBId': partnerBId,
      'partnershipType': partnershipType.name,
      'status': status.name,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isLegal': isLegal,
    };
  }

  factory FamilyPartnership.fromMap(Map<String, dynamic> map) {
    return FamilyPartnership(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      partnerAId: map['partnerAId'] as String,
      partnerBId: map['partnerBId'] as String,
      partnershipType: PartnershipType.values.firstWhere((e) => e.name == map['partnershipType']),
      status: PartnershipStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => PartnershipStatus.active),
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate'] as String) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      isLegal: map['isLegal'] as bool? ?? false,
    );
  }
}