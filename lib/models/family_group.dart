enum GroupType { parents, kids, everyone }

class FamilyGroup {
  final String id;
  final String familyId;
  final String name;
  final GroupType type;
  final List<String> memberIds;
  final DateTime createdAt;

  FamilyGroup({
    required this.id,
    required this.familyId,
    required this.name,
    required this.type,
    required this.memberIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'name': name,
      'type': type.name,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyGroup.fromMap(Map<String, dynamic> map) {
    return FamilyGroup(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      name: map['name'] as String,
      type: GroupType.values.firstWhere((e) => e.name == map['type']),
      memberIds: List<String>.from(map['memberIds'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}