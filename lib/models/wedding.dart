class Wedding {
  final String id;
  final String familyId;
  final String partner1Name;
  final String partner2Name;
  final DateTime weddingDate;
  final String? venue;
  final String? officiant;
  final List<String> witnessNames;
  final List<String> weddingParty;
  final List<String> guestList;
  final String? budget;
  final List<String> vendorNames;
  final List<String> vendorContacts;
  final List<String> registryLinks;
  final List<String> photoUrls;
  final List<String> videoUrls;
  final String? honeymoonLocation;
  final String? notes;
  final String? createdById;
  final DateTime createdAt;

  Wedding({
    required this.id,
    required this.familyId,
    required this.partner1Name,
    required this.partner2Name,
    required this.weddingDate,
    this.venue,
    this.officiant,
    this.witnessNames = const [],
    this.weddingParty = const [],
    this.guestList = const [],
    this.budget,
    this.vendorNames = const [],
    this.vendorContacts = const [],
    this.registryLinks = const [],
    this.photoUrls = const [],
    this.videoUrls = const [],
    this.honeymoonLocation,
    this.notes,
    this.createdById,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'partner1Name': partner1Name,
      'partner2Name': partner2Name,
      'weddingDate': weddingDate.toIso8601String(),
      'venue': venue,
      'officiant': officiant,
      'witnessNames': witnessNames,
      'weddingParty': weddingParty,
      'guestList': guestList,
      'budget': budget,
      'vendorNames': vendorNames,
      'vendorContacts': vendorContacts,
      'registryLinks': registryLinks,
      'photoUrls': photoUrls,
      'videoUrls': videoUrls,
      'honeymoonLocation': honeymoonLocation,
      'notes': notes,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Wedding.fromMap(Map<String, dynamic> map) {
    return Wedding(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      partner1Name: map['partner1Name'] as String,
      partner2Name: map['partner2Name'] as String,
      weddingDate: DateTime.parse(map['weddingDate'] as String),
      venue: map['venue'] as String?,
      officiant: map['officiant'] as String?,
      witnessNames: map['witnessNames'] != null ? List<String>.from(map['witnessNames'] as List) : [],
      weddingParty: map['weddingParty'] != null ? List<String>.from(map['weddingParty'] as List) : [],
      guestList: map['guestList'] != null ? List<String>.from(map['guestList'] as List) : [],
      budget: map['budget'] as String?,
      vendorNames: map['vendorNames'] != null ? List<String>.from(map['vendorNames'] as List) : [],
      vendorContacts: map['vendorContacts'] != null ? List<String>.from(map['vendorContacts'] as List) : [],
      registryLinks: map['registryLinks'] != null ? List<String>.from(map['registryLinks'] as List) : [],
      photoUrls: map['photoUrls'] != null ? List<String>.from(map['photoUrls'] as List) : [],
      videoUrls: map['videoUrls'] != null ? List<String>.from(map['videoUrls'] as List) : [],
      honeymoonLocation: map['honeymoonLocation'] as String?,
      notes: map['notes'] as String?,
      createdById: map['createdById'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}