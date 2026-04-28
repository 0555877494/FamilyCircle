import 'family_user.dart';

enum FamilyFunctionType {
  procreation,
  childRearing,
  economicCooperation,
  socialization,
  emotionalSupport,
  identityTransmission,
  culturalHeritage,
  education,
  healthcare,
  protection,
}

enum FunctionStatus {
  active,
  inactive,
  shared,
}

class FamilyFunction {
  final String id;
  final String familyId;
  final FamilyFunctionType functionType;
  final FunctionStatus status;
  final List<String> responsibleMemberIds;
  final String? description;
  final DateTime? establishedDate;

  FamilyFunction({
    required this.id,
    required this.familyId,
    required this.functionType,
    this.status = FunctionStatus.active,
    required this.responsibleMemberIds,
    this.description,
    this.establishedDate,
  });

  String get displayName {
    switch (functionType) {
      case FamilyFunctionType.procreation:
        return 'Procreation & Child-bearing';
      case FamilyFunctionType.childRearing:
        return 'Child-rearing';
      case FamilyFunctionType.economicCooperation:
        return 'Economic Cooperation';
      case FamilyFunctionType.socialization:
        return 'Socialization';
      case FamilyFunctionType.emotionalSupport:
        return 'Emotional Support';
      case FamilyFunctionType.identityTransmission:
        return 'Identity Transmission';
      case FamilyFunctionType.culturalHeritage:
        return 'Cultural Heritage';
      case FamilyFunctionType.education:
        return 'Education';
      case FamilyFunctionType.healthcare:
        return 'Healthcare';
      case FamilyFunctionType.protection:
        return 'Protection & Safety';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'functionType': functionType.name,
      'status': status.name,
      'responsibleMemberIds': responsibleMemberIds,
      'description': description,
      'establishedDate': establishedDate?.toIso8601String(),
    };
  }

  factory FamilyFunction.fromMap(Map<String, dynamic> map) {
    return FamilyFunction(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      functionType: FamilyFunctionType.values.firstWhere((e) => e.name == map['functionType']),
      status: FunctionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => FunctionStatus.active,
      ),
      responsibleMemberIds: List<String>.from(map['responsibleMemberIds'] as List),
      description: map['description'] as String?,
      establishedDate: map['establishedDate'] != null 
          ? DateTime.parse(map['establishedDate'] as String) 
          : null,
    );
  }
}