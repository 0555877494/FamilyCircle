enum MessageType { text, image, video, voiceNote, location }
enum MessageStatus { sending, sent, delivered, read }

class Message {
  final String id;
  final String familyId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String groupId;
  final MessageType type;
  final String content;
  final String? mediaUrl;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final MessageStatus status;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.familyId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.groupId,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.latitude,
    this.longitude,
    this.locationName,
    this.status = MessageStatus.sent,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'groupId': groupId,
      'type': type.name,
      'content': content,
      'mediaUrl': mediaUrl,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      senderAvatar: map['senderAvatar'] as String?,
      groupId: map['groupId'] as String,
      type: MessageType.values.firstWhere((e) => e.name == map['type']),
      content: map['content'] as String,
      mediaUrl: map['mediaUrl'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      locationName: map['locationName'] as String?,
      status: MessageStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}