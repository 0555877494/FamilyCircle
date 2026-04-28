import 'family_user.dart';

enum HeirloomCategory {
  jewelry,
  furniture,
  artwork,
  clothing,
  document,
  weapon,
  instrument,
  book,
  photograph,
  trophy,
  recipe,
  other,
}

enum HeirloomStatus {
  inFamily,
  lost,
  damaged,
  donated,
  sold,
  unknown,
}

class FamilyHeirloom {
  final String id;
  final String familyId;
  final String name;
  final String? description;
  final HeirloomCategory category;
  final HeirloomStatus status;
  final String? estimatedValue;
  final String? currentHolderId;
  final String? currentHolderName;
  final List<String> previousOwners;
  final int generationPassed;
  final String? originStory;
  final String? significance;
  final List<String> photos;
  final String? location;
  final String? notes;
  final DateTime createdAt;

  FamilyHeirloom({
    required this.id,
    required this.familyId,
    required this.name,
    this.description,
    required this.category,
    this.status = HeirloomStatus.inFamily,
    this.estimatedValue,
    this.currentHolderId,
    this.currentHolderName,
    this.previousOwners = const [],
    this.generationPassed = 1,
    this.originStory,
    this.significance,
    this.photos = const [],
    this.location,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'name': name,
      'description': description,
      'category': category.name,
      'status': status.name,
      'estimatedValue': estimatedValue,
      'currentHolderId': currentHolderId,
      'currentHolderName': currentHolderName,
      'previousOwners': previousOwners,
      'generationPassed': generationPassed,
      'originStory': originStory,
      'significance': significance,
      'photos': photos,
      'location': location,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyHeirloom.fromMap(Map<String, dynamic> map) {
    return FamilyHeirloom(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      category: HeirloomCategory.values.firstWhere((e) => e.name == map['category']),
      status: HeirloomStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => HeirloomStatus.inFamily),
      estimatedValue: map['estimatedValue'] as String?,
      currentHolderId: map['currentHolderId'] as String?,
      currentHolderName: map['currentHolderName'] as String?,
      previousOwners: map['previousOwners'] != null ? List<String>.from(map['previousOwners'] as List) : [],
      generationPassed: map['generationPassed'] as int? ?? 1,
      originStory: map['originStory'] as String?,
      significance: map['significance'] as String?,
      photos: map['photos'] != null ? List<String>.from(map['photos'] as List) : [],
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class FamilyRecipe {
  final String id;
  final String familyId;
  final String name;
  final String? description;
  final List<String> ingredients;
  final List<String> steps;
  final String? cuisine;
  final String? originStory;
  final int generationOrigin;
  final List<String> photos;
  final String? notes;
  final DateTime createdAt;

  FamilyRecipe({
    required this.id,
    required this.familyId,
    required this.name,
    this.description,
    this.ingredients = const [],
    this.steps = const [],
    this.cuisine,
    this.originStory,
    this.generationOrigin = 1,
    this.photos = const [],
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'cuisine': cuisine,
      'originStory': originStory,
      'generationOrigin': generationOrigin,
      'photos': photos,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyRecipe.fromMap(Map<String, dynamic> map) {
    return FamilyRecipe(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      ingredients: map['ingredients'] != null ? List<String>.from(map['ingredients'] as List) : [],
      steps: map['steps'] != null ? List<String>.from(map['steps'] as List) : [],
      cuisine: map['cuisine'] as String?,
      originStory: map['originStory'] as String?,
      generationOrigin: map['generationOrigin'] as int? ?? 1,
      photos: map['photos'] != null ? List<String>.from(map['photos'] as List) : [],
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}