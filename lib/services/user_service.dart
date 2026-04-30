import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<FamilyUser?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists
            ? FamilyUser.fromMap(doc.data() as Map<String, dynamic>)
            : null);
  }

  Future<FamilyUser?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return FamilyUser.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  Future<void> updateUser(FamilyUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> createUser(FamilyUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<List<FamilyUser>> getUsersByFamily(String familyId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();
      return snapshot.docs
          .map((doc) => FamilyUser.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting family users: $e');
      return [];
    }
  }
}
