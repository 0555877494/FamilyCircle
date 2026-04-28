enum KinshipType {
  parent,
  child,
  sibling,
  halfSibling,
  grandparent,
  grandchild,
  greatGrandparent,
  greatGrandchild,
  aunt,
  uncle,
  niece,
  nephew,
  cousin,
  firstCousin,
  secondCousin,
}

class FamilyKinshipTie {
  final String id;
  final String familyId;
  final String memberAId;
  final String memberBId;
  final KinshipType kinshipType;
  final bool isBloodRelation;
  final int generationGap;

  FamilyKinshipTie({
    required this.id,
    required this.familyId,
    required this.memberAId,
    required this.memberBId,
    required this.kinshipType,
    this.isBloodRelation = true,
    this.generationGap = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'memberAId': memberAId,
      'memberBId': memberBId,
      'kinshipType': kinshipType.name,
      'isBloodRelation': isBloodRelation,
      'generationGap': generationGap,
    };
  }

  factory FamilyKinshipTie.fromMap(Map<String, dynamic> map) {
    return FamilyKinshipTie(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      memberAId: map['memberAId'] as String,
      memberBId: map['memberBId'] as String,
      kinshipType: KinshipType.values.firstWhere((e) => e.name == map['kinshipType']),
      isBloodRelation: map['isBloodRelation'] as bool? ?? true,
      generationGap: map['generationGap'] as int? ?? 0,
    );
  }
}