enum GatheringType {
  reunion,
  birthday,
  holiday,
  bbq,
  party,
  graduation,
  welcome,
  farewell,
  celebration,
  other,
}

class FamilyGathering {
  final String id;
  final String familyId;
  final String title;
  final GatheringType type;
  final DateTime date;
  final DateTime? endDate;
  final String? location;
  final String? hostId;
  final String hostName;
  final List<String> attendeeIds;
  final List<String> attendeeNames;
  final List<String> recipes;
  final List<String> photoUrls;
  final List<String> videoUrls;
  final String? budget;
  final String? notes;
  final String? createdById;
  final DateTime createdAt;

  FamilyGathering({
    required this.id,
    required this.familyId,
    required this.title,
    required this.type,
    required this.date,
    this.endDate,
    this.location,
    this.hostId,
    required this.hostName,
    this.attendeeIds = const [],
    this.attendeeNames = const [],
    this.recipes = const [],
    this.photoUrls = const [],
    this.videoUrls = const [],
    this.budget,
    this.notes,
    this.createdById,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'title': title,
      'type': type.name,
      'date': date.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'location': location,
      'hostId': hostId,
      'hostName': hostName,
      'attendeeIds': attendeeIds,
      'attendeeNames': attendeeNames,
      'recipes': recipes,
      'photoUrls': photoUrls,
      'videoUrls': videoUrls,
      'budget': budget,
      'notes': notes,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyGathering.fromMap(Map<String, dynamic> map) {
    return FamilyGathering(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      title: map['title'] as String,
      type: GatheringType.values.firstWhere((e) => e.name == map['type']),
      date: DateTime.parse(map['date'] as String),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      location: map['location'] as String?,
      hostId: map['hostId'] as String?,
      hostName: map['hostName'] as String,
      attendeeIds: map['attendeeIds'] != null ? List<String>.from(map['attendeeIds'] as List) : [],
      attendeeNames: map['attendeeNames'] != null ? List<String>.from(map['attendeeNames'] as List) : [],
      recipes: map['recipes'] != null ? List<String>.from(map['recipes'] as List) : [],
      photoUrls: map['photoUrls'] != null ? List<String>.from(map['photoUrls'] as List) : [],
      videoUrls: map['videoUrls'] != null ? List<String>.from(map['videoUrls'] as List) : [],
      budget: map['budget'] as String?,
      notes: map['notes'] as String?,
      createdById: map['createdById'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}