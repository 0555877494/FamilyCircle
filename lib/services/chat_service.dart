import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/family_group.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _messagesRef = FirebaseFirestore.instance.collection('messages');
  final CollectionReference _groupsRef = FirebaseFirestore.instance.collection('groups');

  Future<void> sendMessage(Message message) async {
    await _messagesRef.doc(message.id).set(message.toMap());
  }

  Stream<List<Message>> getMessagesStream(String groupId) {
    return _messagesRef
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<Message>> getMessages(String groupId, {int limit = 50}) async {
    final snapshot = await _messagesRef
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    await _messagesRef.doc(messageId).update({'status': status.name});
  }

  Stream<List<FamilyGroup>> getFamilyGroupsStream(String familyId) {
    return _groupsRef
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FamilyGroup.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> createGroup(FamilyGroup group) async {
    await _groupsRef.doc(group.id).set(group.toMap());
  }

  Future<void> sendEmergencyBroadcast(String familyId, String senderId, String senderName) async {
    final emergencyMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      familyId: familyId,
      senderId: senderId,
      senderName: senderName,
      groupId: 'everyone',
      type: MessageType.text,
      content: 'EMERGENCY BROADCAST',
      createdAt: DateTime.now(),
    );
    await sendMessage(emergencyMessage);
    
    final broadcastDoc = _firestore.collection('emergency_broadcasts').doc();
    await broadcastDoc.set({
      'familyId': familyId,
      'senderId': senderId,
      'senderName': senderName,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}