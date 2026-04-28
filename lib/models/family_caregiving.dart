enum CaregivingType {
  parenting,
  elderCare,
  disabilityCare,
  fosterCare,
  guardianship,
  coParenting,
  sharedCustody,
}

enum CaregivingArrangement {
  sole,
  joint,
  shared,
  split,
  grandparentCustody,
}

class FamilyCaregiving {
  final String id;
  final String familyId;
  final String caregiverId;
  final String recipientId;
  final CaregivingType caregivingType;
  final CaregivingArrangement arrangement;
  final double responsibilityPercentage;
  final bool isPrimary;
  final bool isLegalCustody;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;

  FamilyCaregiving({
    required this.id,
    required this.familyId,
    required this.caregiverId,
    required this.recipientId,
    required this.caregivingType,
    this.arrangement = CaregivingArrangement.sole,
    this.responsibilityPercentage = 100.0,
    this.isPrimary = false,
    this.isLegalCustody = false,
    this.startDate,
    this.endDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'caregiverId': caregiverId,
      'recipientId': recipientId,
      'caregivingType': caregivingType.name,
      'arrangement': arrangement.name,
      'responsibilityPercentage': responsibilityPercentage,
      'isPrimary': isPrimary,
      'isLegalCustody': isLegalCustody,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory FamilyCaregiving.fromMap(Map<String, dynamic> map) {
    return FamilyCaregiving(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      caregiverId: map['caregiverId'] as String,
      recipientId: map['recipientId'] as String,
      caregivingType: CaregivingType.values.firstWhere((e) => e.name == map['caregivingType']),
      arrangement: CaregivingArrangement.values.firstWhere(
        (e) => e.name == map['arrangement'],
        orElse: () => CaregivingArrangement.sole,
      ),
      responsibilityPercentage: (map['responsibilityPercentage'] as num?)?.toDouble() ?? 100.0,
      isPrimary: map['isPrimary'] as bool? ?? false,
      isLegalCustody: map['isLegalCustody'] as bool? ?? false,
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate'] as String) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      notes: map['notes'] as String?,
    );
  }
}