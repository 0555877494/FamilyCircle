import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parental_settings.dart';

class ParentalService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<ParentalSettings?> getSettings(String familyId, String memberId) async {
    final doc = await _firestore.collection('parental_settings').doc('${familyId}_$memberId').get();
    if (!doc.exists) return null;
    return ParentalSettings.fromMap(doc.data() as Map<String, dynamic>);
  }

  Stream<ParentalSettings?> getSettingsStream(String familyId, String memberId) {
    return _firestore.collection('parental_settings').doc('${familyId}_$memberId')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return ParentalSettings.fromMap(doc.data() as Map<String, dynamic>);
        });
  }

  Future<void> saveSettings(String familyId, String memberId, ParentalSettings settings) async {
    await _firestore.collection('parental_settings').doc('${familyId}_$memberId').set(settings.toMap());
  }

  bool isWithinScreenTimeLimit(ParentalSettings settings) {
    final now = DateTime.now();
    final bedtime = DateTime(now.year, now.month, now.day, settings.bedtimeHour, settings.bedtimeMinute);
    
    if (!settings.screenTimeEnabled) return true;
    if (now.isBefore(bedtime)) return true;
    
    return false;
  }

  Future<void> sendEmergencyAlert(String familyId, String senderId, String senderName, String message) async {
    final alert = {
      'familyId': familyId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    await _firestore.collection('emergency_alerts').doc().set(alert);
  }

  Stream<List<Map<String, dynamic>>> getEmergencyAlertsStream(String familyId) {
    return _firestore.collection('emergency_alerts')
        .where('familyId', isEqualTo: familyId)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }
}