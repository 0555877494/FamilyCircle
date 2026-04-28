enum EventRepeat { none, daily, weekly, monthly, yearly }

class CalendarEvent {
  final String id;
  final String familyId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final String createdBy;
  final List<String> memberIds;
  final String? location;
  final EventRepeat repeat;
  final bool isEmergency;
  final DateTime createdAt;

  CalendarEvent({
    required this.id,
    required this.familyId,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    required this.createdBy,
    required this.memberIds,
    this.location,
    this.repeat = EventRepeat.none,
    this.isEmergency = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'createdBy': createdBy,
      'memberIds': memberIds,
      'location': location,
      'repeat': repeat.name,
      'isEmergency': isEmergency,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null 
          ? DateTime.parse(map['endTime'] as String) 
          : null,
      createdBy: map['createdBy'] as String,
      memberIds: List<String>.from(map['memberIds'] as List),
      location: map['location'] as String?,
      repeat: EventRepeat.values.firstWhere((e) => e.name == map['repeat']),
      isEmergency: map['isEmergency'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}