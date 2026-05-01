enum HealthEventType {
  checkup,
  hospitalization,
  surgery,
  diagnosis,
  allergy,
  chronicCondition,
  therapy,
  specialistVisit,
  emergency,
  vaccination,
  dental,
  vision,
  mentalHealth,
  other,
}

class ExtendedHealthEvent {
  final String id;
  final String familyId;
  final String memberId;
  final String memberName;
  final String title;
  final String? description;
  final HealthEventType type;
  final DateTime date;
  final DateTime? endDate;
  final String? provider;
  final String? facility;
  final String? location;
  final String? diagnosis;
  final String? treatment;
  final List<String> medications;
  final List<String> attachments;
  final double? cost;
  final bool isOngoing;
  final String? notes;
  final String? createdById;
  final DateTime createdAt;

  ExtendedHealthEvent({
    required this.id,
    required this.familyId,
    required this.memberId,
    required this.memberName,
    required this.title,
    this.description,
    required this.type,
    required this.date,
    this.endDate,
    this.provider,
    this.facility,
    this.location,
    this.diagnosis,
    this.treatment,
    this.medications = const [],
    this.attachments = const [],
    this.cost,
    this.isOngoing = false,
    this.notes,
    this.createdById,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'memberId': memberId,
      'memberName': memberName,
      'title': title,
      'description': description,
      'type': type.name,
      'date': date.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'provider': provider,
      'facility': facility,
      'location': location,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'medications': medications,
      'attachments': attachments,
      'cost': cost,
      'isOngoing': isOngoing,
      'notes': notes,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ExtendedHealthEvent.fromMap(Map<String, dynamic> map) {
    return ExtendedHealthEvent(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      memberId: map['memberId'] as String,
      memberName: map['memberName'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: HealthEventType.values.firstWhere((e) => e.name == map['type']),
      date: DateTime.parse(map['date'] as String),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      provider: map['provider'] as String?,
      facility: map['facility'] as String?,
      location: map['location'] as String?,
      diagnosis: map['diagnosis'] as String?,
      treatment: map['treatment'] as String?,
      medications: map['medications'] != null ? List<String>.from(map['medications'] as List) : [],
      attachments: map['attachments'] != null ? List<String>.from(map['attachments'] as List) : [],
      cost: (map['cost'] as num?)?.toDouble(),
      isOngoing: map['isOngoing'] as bool? ?? false,
      notes: map['notes'] as String?,
      createdById: map['createdById'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}