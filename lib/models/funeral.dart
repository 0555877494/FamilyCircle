enum FuneralType {
  funeral,
  memorial,
  celebrationOfLife,
  vigil,
  graveside,
  other,
}

class Funeral {
  final String id;
  final String familyId;
  final String deceasedName;
  final FuneralType type;
  final DateTime serviceDate;
  final String? serviceLocation;
  final String? officiant;
  final List<String> pallbearers;
  final List<String> eulogists;
  final String? obituary;
  final List<String> musicPlaylist;
  final String? burialPlot;
  final List<String> photoUrls;
  final List<String> videoUrls;
  final String? notes;
  final String? createdById;
  final DateTime createdAt;

  Funeral({
    required this.id,
    required this.familyId,
    required this.deceasedName,
    required this.type,
    required this.serviceDate,
    this.serviceLocation,
    this.officiant,
    this.pallbearers = const [],
    this.eulogists = const [],
    this.obituary,
    this.musicPlaylist = const [],
    this.burialPlot,
    this.photoUrls = const [],
    this.videoUrls = const [],
    this.notes,
    this.createdById,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'deceasedName': deceasedName,
      'type': type.name,
      'serviceDate': serviceDate.toIso8601String(),
      'serviceLocation': serviceLocation,
      'officiant': officiant,
      'pallbearers': pallbearers,
      'eulogists': eulogists,
      'obituary': obituary,
      'musicPlaylist': musicPlaylist,
      'burialPlot': burialPlot,
      'photoUrls': photoUrls,
      'videoUrls': videoUrls,
      'notes': notes,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Funeral.fromMap(Map<String, dynamic> map) {
    return Funeral(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      deceasedName: map['deceasedName'] as String,
      type: FuneralType.values.firstWhere((e) => e.name == map['type']),
      serviceDate: DateTime.parse(map['serviceDate'] as String),
      serviceLocation: map['serviceLocation'] as String?,
      officiant: map['officiant'] as String?,
      pallbearers: map['pallbearers'] != null ? List<String>.from(map['pallbearers'] as List) : [],
      eulogists: map['eulogists'] != null ? List<String>.from(map['eulogists'] as List) : [],
      obituary: map['obituary'] as String?,
      musicPlaylist: map['musicPlaylist'] != null ? List<String>.from(map['musicPlaylist'] as List) : [],
      burialPlot: map['burialPlot'] as String?,
      photoUrls: map['photoUrls'] != null ? List<String>.from(map['photoUrls'] as List) : [],
      videoUrls: map['videoUrls'] != null ? List<String>.from(map['videoUrls'] as List) : [],
      notes: map['notes'] as String?,
      createdById: map['createdById'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}