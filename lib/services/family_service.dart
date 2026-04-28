import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../models/family.dart';
import '../models/family_group.dart';
import '../models/family_kinship.dart';
import '../models/family_partnership.dart';
import '../models/family_household.dart';
import '../models/family_caregiving.dart';
import '../models/family_function.dart';

class FamilyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<Family?> createFamily(String name, String creatorId) async {
    final familyId = _uuid.v4();
    final inviteCode = _generateInviteCode();
    
    final family = Family(
      id: familyId,
      name: name,
      createdBy: creatorId,
      members: [],
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );
    
    await _firestore.collection('families').doc(familyId).set(family.toMap());
    
    await _createDefaultGroups(familyId);
    
    return family;
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (i) => chars[(random + i * 7) % chars.length]).join();
  }

  Future<void> _createDefaultGroups(String familyId) async {
    final defaultGroups = [
      FamilyGroup(
        id: _uuid.v4(),
        familyId: familyId,
        name: 'Parents',
        type: GroupType.parents,
        memberIds: [],
        createdAt: DateTime.now(),
      ),
      FamilyGroup(
        id: _uuid.v4(),
        familyId: familyId,
        name: 'Kids',
        type: GroupType.kids,
        memberIds: [],
        createdAt: DateTime.now(),
      ),
      FamilyGroup(
        id: _uuid.v4(),
        familyId: familyId,
        name: 'Everyone',
        type: GroupType.everyone,
        memberIds: [],
        createdAt: DateTime.now(),
      ),
    ];
    
    for (final group in defaultGroups) {
      await _firestore.collection('groups').doc(group.id).set(group.toMap());
    }
  }

  Future<Family?> getFamily(String familyId) async {
    final doc = await _firestore.collection('families').doc(familyId).get();
    if (!doc.exists) return null;
    return Family.fromMap(doc.data() as Map<String, dynamic>);
  }

  Stream<Family?> getFamilyStream(String familyId) {
    return _firestore.collection('families').doc(familyId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return Family.fromMap(doc.data() as Map<String, dynamic>);
        });
  }

  Future<FamilyUser?> addMember(String familyId, String firstName, UserRole role) async {
    final memberId = _uuid.v4();
    final member = FamilyUser(
      id: memberId,
      familyId: familyId,
      firstName: firstName,
      role: role,
      createdAt: DateTime.now(),
    );
    
    final familyDoc = _firestore.collection('families').doc(familyId);
    await familyDoc.update({
      'members': FieldValue.arrayUnion([member.toMap()]),
    });
    
    await _addMemberToGroup(familyId, memberId, role);
    
    return member;
  }

  Future<void> _addMemberToGroup(String familyId, String memberId, UserRole role) async {
    if (role == UserRole.parent) {
      final parentGroup = await _firestore.collection('groups')
          .where('familyId', isEqualTo: familyId)
          .where('type', isEqualTo: 'parents')
          .get();
      if (parentGroup.docs.isNotEmpty) {
        await parentGroup.docs.first.reference.update({
          'memberIds': FieldValue.arrayUnion([memberId]),
        });
      }
    } else if (role == UserRole.child) {
      final kidsGroup = await _firestore.collection('groups')
          .where('familyId', isEqualTo: familyId)
          .where('type', isEqualTo: 'kids')
          .get();
      if (kidsGroup.docs.isNotEmpty) {
        await kidsGroup.docs.first.reference.update({
          'memberIds': FieldValue.arrayUnion([memberId]),
        });
      }
    }
    
    final everyoneGroup = await _firestore.collection('groups')
        .where('familyId', isEqualTo: familyId)
        .where('type', isEqualTo: 'everyone')
        .get();
    if (everyoneGroup.docs.isNotEmpty) {
      await everyoneGroup.docs.first.reference.update({
        'memberIds': FieldValue.arrayUnion([memberId]),
      });
    }
  }

  Future<bool> joinFamilyWithCode(String inviteCode, String userId, String firstName, UserRole role) async {
    final query = await _firestore.collection('families')
        .where('inviteCode', isEqualTo: inviteCode)
        .get();
    
    if (query.docs.isEmpty) return false;
    
    final familyDoc = query.docs.first;
    final familyId = familyDoc.id;
    
    await addMember(familyId, firstName, role);
    
    return true;
  }

  Future<void> removeMember(String familyId, String memberId) async {
    final familyDoc = _firestore.collection('families').doc(familyId);
    final family = await familyDoc.get();
    final members = (family.data()!['members'] as List)
        .where((m) => m['id'] != memberId)
        .toList();
    
    await familyDoc.update({'members': members});
    
    await _firestore.collection('groups')
        .where('familyId', isEqualTo: familyId)
        .get();
  }

  Future<void> addKinshipTie(String familyId, FamilyKinshipTie kinship) async {
    await _firestore.collection('families').doc(familyId).update({
      'kinshipTies': FieldValue.arrayUnion([kinship.toMap()]),
    });
  }

  Future<void> addPartnership(String familyId, FamilyPartnership partnership) async {
    await _firestore.collection('families').doc(familyId).update({
      'partnerships': FieldValue.arrayUnion([partnership.toMap()]),
    });
  }

  Future<void> addHousehold(String familyId, FamilyHousehold household) async {
    await _firestore.collection('families').doc(familyId).update({
      'households': FieldValue.arrayUnion([household.toMap()]),
    });
  }

  Future<void> addCaregiving(String familyId, FamilyCaregiving caregiving) async {
    await _firestore.collection('families').doc(familyId).update({
      'caregiving': FieldValue.arrayUnion([caregiving.toMap()]),
    });
  }

  Future<void> addFunction(String familyId, FamilyFunction function) async {
    await _firestore.collection('families').doc(familyId).update({
      'functions': FieldValue.arrayUnion([function.toMap()]),
    });
  }

  Future<void> updateFamilyStructure(String familyId, FamilyStructureType structureType) async {
    await _firestore.collection('families').doc(familyId).update({
      'structureType': structureType.name,
    });
  }

  Future<void> setHeadOfHousehold(String familyId, String memberId) async {
    await _firestore.collection('families').doc(familyId).update({
      'headOfHouseholdId': memberId,
    });
  }

  Future<void> setHouseholdName(String familyId, String name) async {
    await _firestore.collection('families').doc(familyId).update({
      'householdName': name,
    });
  }
}