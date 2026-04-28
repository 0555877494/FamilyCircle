import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _userIdKey = 'user_id';
  static const String _familyIdKey = 'family_id';

  Future<String?> getCurrentUserId() async {
    final user = _firebaseAuth.currentUser;
    return user?.uid;
  }

  Future<auth.User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on auth.FirebaseAuthException {
      return null;
    }
  }

  Future<auth.User?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on auth.FirebaseAuthException {
      return null;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _familyIdKey);
  }

  Future<void> saveUserSession(String userId, String familyId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
    await _secureStorage.write(key: _familyIdKey, value: familyId);
  }

  Future<String?> getSavedFamilyId() async {
    return await _secureStorage.read(key: _familyIdKey);
  }

  Stream<auth.User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}