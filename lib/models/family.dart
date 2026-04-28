import 'family_user.dart';
import 'relationship.dart';
import 'family_kinship.dart';
import 'family_partnership.dart';
import 'family_household.dart';
import 'family_caregiving.dart';
import 'family_function.dart';
import 'family_property.dart';

enum FamilyStructureType {
  nuclear,
  extended,
  singleParent,
  blended,
  chosen,
}

class Family {
  final String id;
  final String name;
  final String createdBy;
  final List<FamilyUser> members;
  final String? inviteCode;
  final DateTime createdAt;
  final FamilyStructureType structureType;
  final String? householdName;
  final List<FamilyRelationship> relationships;
  final String? headOfHouseholdId;
  final List<FamilyKinshipTie> kinshipTies;
  final List<FamilyPartnership> partnerships;
  final List<FamilyHousehold> households;
  final List<FamilyCaregiving> caregiving;
  final List<FamilyFunction> functions;
  final List<FamilyProperty> properties;

  Family({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.members,
    this.inviteCode,
    required this.createdAt,
    this.structureType = FamilyStructureType.nuclear,
    this.householdName,
    this.relationships = const [],
    this.headOfHouseholdId,
    this.kinshipTies = const [],
    this.partnerships = const [],
    this.households = const [],
    this.caregiving = const [],
    this.functions = const [],
    this.properties = const [],
  });

  List<FamilyUser> get parents => 
      members.where((m) => m.role == UserRole.parent).toList();
  
  List<FamilyUser> get children => 
      members.where((m) => m.role == UserRole.child).toList();

  List<FamilyUser> get grandparents =>
      members.where((m) => m.role == UserRole.grandparent).toList();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'members': members.map((m) => m.toMap()).toList(),
      'inviteCode': inviteCode,
      'createdAt': createdAt.toIso8601String(),
      'structureType': structureType.name,
      'householdName': householdName,
      'relationships': relationships.map((r) => r.toMap()).toList(),
      'headOfHouseholdId': headOfHouseholdId,
      'kinshipTies': kinshipTies.map((k) => k.toMap()).toList(),
      'partnerships': partnerships.map((p) => p.toMap()).toList(),
      'households': households.map((h) => h.toMap()).toList(),
      'caregiving': caregiving.map((c) => c.toMap()).toList(),
      'functions': functions.map((f) => f.toMap()).toList(),
      'properties': properties.map((p) => p.toMap()).toList(),
    };
  }

  factory Family.fromMap(Map<String, dynamic> map) {
    return Family(
      id: map['id'] as String,
      name: map['name'] as String,
      createdBy: map['createdBy'] as String,
      members: (map['members'] as List)
          .map((m) => FamilyUser.fromMap(m as Map<String, dynamic>))
          .toList(),
      inviteCode: map['inviteCode'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      structureType: FamilyStructureType.values.firstWhere(
        (e) => e.name == map['structureType'],
        orElse: () => FamilyStructureType.nuclear,
      ),
      householdName: map['householdName'] as String?,
      relationships: map['relationships'] != null
          ? (map['relationships'] as List)
              .map((r) => FamilyRelationship.fromMap(r as Map<String, dynamic>))
              .toList()
          : [],
      headOfHouseholdId: map['headOfHouseholdId'] as String?,
      kinshipTies: map['kinshipTies'] != null
          ? (map['kinshipTies'] as List)
              .map((k) => FamilyKinshipTie.fromMap(k as Map<String, dynamic>))
              .toList()
          : [],
      partnerships: map['partnerships'] != null
          ? (map['partnerships'] as List)
              .map((p) => FamilyPartnership.fromMap(p as Map<String, dynamic>))
              .toList()
          : [],
      households: map['households'] != null
          ? (map['households'] as List)
              .map((h) => FamilyHousehold.fromMap(h as Map<String, dynamic>))
              .toList()
          : [],
      caregiving: map['caregiving'] != null
          ? (map['caregiving'] as List)
              .map((c) => FamilyCaregiving.fromMap(c as Map<String, dynamic>))
              .toList()
          : [],
      functions: map['functions'] != null
          ? (map['functions'] as List)
              .map((f) => FamilyFunction.fromMap(f as Map<String, dynamic>))
              .toList()
          : [],
      properties: map['properties'] != null
          ? (map['properties'] as List)
              .map((p) => FamilyProperty.fromMap(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}