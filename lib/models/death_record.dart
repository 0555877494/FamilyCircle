import 'family_user.dart';

class DeathRecord {
  final String id;
  final String familyId;
  final String memberId;
  final String memberName;
  final DateTime? dateOfDeath;
  final String? causeOfDeath;
  final String? obituary;
  final DateTime? funeralDate;
  final String? funeralLocation;
  final String? cemeteryPlot;
  final String? estateExecutor;
  final String? willLocation;
  final String? lifeInsurancePolicy;
  final List<String> financialAccounts;
  final List<String> beneficiaryIds;
  final String? notes;
  final String? createdById;
  final DateTime createdAt;

  DeathRecord({
    required this.id,
    required this.familyId,
    required this.memberId,
    required this.memberName,
    this.dateOfDeath,
    this.causeOfDeath,
    this.obituary,
    this.funeralDate,
    this.funeralLocation,
    this.cemeteryPlot,
    this.estateExecutor,
    this.willLocation,
    this.lifeInsurancePolicy,
    this.financialAccounts = const [],
    this.beneficiaryIds = const [],
    this.notes,
    this.createdById,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'memberId': memberId,
      'memberName': memberName,
      'dateOfDeath': dateOfDeath?.toIso8601String(),
      'causeOfDeath': causeOfDeath,
      'obituary': obituary,
      'funeralDate': funeralDate?.toIso8601String(),
      'funeralLocation': funeralLocation,
      'cemeteryPlot': cemeteryPlot,
      'estateExecutor': estateExecutor,
      'willLocation': willLocation,
      'lifeInsurancePolicy': lifeInsurancePolicy,
      'financialAccounts': financialAccounts,
      'beneficiaryIds': beneficiaryIds,
      'notes': notes,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DeathRecord.fromMap(Map<String, dynamic> map) {
    return DeathRecord(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      memberId: map['memberId'] as String,
      memberName: map['memberName'] as String,
      dateOfDeath: map['dateOfDeath'] != null ? DateTime.parse(map['dateOfDeath'] as String) : null,
      causeOfDeath: map['causeOfDeath'] as String?,
      obituary: map['obituary'] as String?,
      funeralDate: map['funeralDate'] != null ? DateTime.parse(map['funeralDate'] as String) : null,
      funeralLocation: map['funeralLocation'] as String?,
      cemeteryPlot: map['cemeteryPlot'] as String?,
      estateExecutor: map['estateExecutor'] as String?,
      willLocation: map['willLocation'] as String?,
      lifeInsurancePolicy: map['lifeInsurancePolicy'] as String?,
      financialAccounts: map['financialAccounts'] != null ? List<String>.from(map['financialAccounts'] as List) : [],
      beneficiaryIds: map['beneficiaryIds'] != null ? List<String>.from(map['beneficiaryIds'] as List) : [],
      notes: map['notes'] as String?,
      createdById: map['createdById'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}