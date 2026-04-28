import 'family_user.dart';

enum HistoricalEventType {
  immigration,
  birth,
  wedding,
  death,
  militaryService,
  education,
  career,
  award,
  relocation,
  other,
}

class FamilyHistoryEntry {
  final String id;
  final String familyId;
  final String title;
  final String? description;
  final HistoricalEventType type;
  final String? relatedMemberId;
  final String? relatedMemberName;
  final DateTime date;
  final String? location;
  final String? originCountry;
  final String? destinationCountry;
  final List<String> photoUrls;
  final String? source;
  final String? notes;
  final DateTime createdAt;

  FamilyHistoryEntry({
    required this.id,
    required this.familyId,
    required this.title,
    this.description,
    required this.type,
    this.relatedMemberId,
    this.relatedMemberName,
    required this.date,
    this.location,
    this.originCountry,
    this.destinationCountry,
    this.photoUrls = const [],
    this.source,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'title': title,
      'description': description,
      'type': type.name,
      'relatedMemberId': relatedMemberId,
      'relatedMemberName': relatedMemberName,
      'date': date.toIso8601String(),
      'location': location,
      'originCountry': originCountry,
      'destinationCountry': destinationCountry,
      'photoUrls': photoUrls,
      'source': source,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyHistoryEntry.fromMap(Map<String, dynamic> map) {
    return FamilyHistoryEntry(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: HistoricalEventType.values.firstWhere((e) => e.name == map['type']),
      relatedMemberId: map['relatedMemberId'] as String?,
      relatedMemberName: map['relatedMemberName'] as String?,
      date: DateTime.parse(map['date'] as String),
      location: map['location'] as String?,
      originCountry: map['originCountry'] as String?,
      destinationCountry: map['destinationCountry'] as String?,
      photoUrls: map['photoUrls'] != null ? List<String>.from(map['photoUrls'] as List) : [],
      source: map['source'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class FamilyLineage {
  final String id;
  final String familyId;
  final String? originCountry;
  final String? originCity;
  final DateTime? immigrationDate;
  final String? immigrationPort;
  final List<String> familySurnames;
  final List<String> coatOfArms;
  final String? familyMotto;
  final String? culturalTraditions;
  final List<String> languagesSpoken;
  final List<String> recipes;
  final String? notes;
  final DateTime createdAt;

  FamilyLineage({
    required this.id,
    required this.familyId,
    this.originCountry,
    this.originCity,
    this.immigrationDate,
    this.immigrationPort,
    this.familySurnames = const [],
    this.coatOfArms = const [],
    this.familyMotto,
    this.culturalTraditions,
    this.languagesSpoken = const [],
    this.recipes = const [],
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'originCountry': originCountry,
      'originCity': originCity,
      'immigrationDate': immigrationDate?.toIso8601String(),
      'immigrationPort': immigrationPort,
      'familySurnames': familySurnames,
      'coatOfArms': coatOfArms,
      'familyMotto': familyMotto,
      'culturalTraditions': culturalTraditions,
      'languagesSpoken': languagesSpoken,
      'recipes': recipes,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyLineage.fromMap(Map<String, dynamic> map) {
    return FamilyLineage(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      originCountry: map['originCountry'] as String?,
      originCity: map['originCity'] as String?,
      immigrationDate: map['immigrationDate'] != null ? DateTime.parse(map['immigrationDate'] as String) : null,
      immigrationPort: map['immigrationPort'] as String?,
      familySurnames: map['familySurnames'] != null ? List<String>.from(map['familySurnames'] as List) : [],
      coatOfArms: map['coatOfArms'] != null ? List<String>.from(map['coatOfArms'] as List) : [],
      familyMotto: map['familyMotto'] as String?,
      culturalTraditions: map['culturalTraditions'] as String?,
      languagesSpoken: map['languagesSpoken'] != null ? List<String>.from(map['languagesSpoken'] as List) : [],
      recipes: map['recipes'] != null ? List<String>.from(map['recipes'] as List) : [],
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}