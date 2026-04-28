enum RelationshipType {
  spouse,
  parent,
  child,
  sibling,
  grandparent,
  grandchild,
  aunt,
  uncle,
  cousin,
  niece,
  nephew,
  inLaw,
  stepParent,
  stepChild,
  stepSibling,
  guardian,
  ward,
}

class FamilyRelationship {
  final String id;
  final String familyId;
  final String memberAId;
  final String memberBId;
  final RelationshipType type;

  FamilyRelationship({
    required this.id,
    required this.familyId,
    required this.memberAId,
    required this.memberBId,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'memberAId': memberAId,
      'memberBId': memberBId,
      'type': type.name,
    };
  }

  factory FamilyRelationship.fromMap(Map<String, dynamic> map) {
    return FamilyRelationship(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      memberAId: map['memberAId'] as String,
      memberBId: map['memberBId'] as String,
      type: RelationshipType.values.firstWhere((e) => e.name == map['type']),
    );
  }
}