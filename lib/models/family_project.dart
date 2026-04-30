enum ProjectStatus { active, completed, archived }

enum ProjectPriority { low, medium, high }

class ProjectTask {
  final String id;
  final String title;
  final bool isCompleted;
  final String? assignedTo;
  final String? assignedToName;
  final DateTime? dueDate;

  ProjectTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.assignedTo,
    this.assignedToName,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory ProjectTask.fromMap(Map<String, dynamic> map) {
    return ProjectTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      assignedTo: map['assignedTo'],
      assignedToName: map['assignedToName'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }

  ProjectTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? assignedTo,
    String? assignedToName,
    DateTime? dueDate,
  }) {
    return ProjectTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

class FamilyProject {
  final String id;
  final String familyId;
  final String title;
  final String description;
  final String createdBy;
  final String creatorName;
  final DateTime createdAt;
  final DateTime? dueDate;
  final ProjectStatus status;
  final ProjectPriority priority;
  final List<String> memberIds;
  final List<ProjectTask> tasks;
  final List<String> tags;
  final String? coverImageUrl;

  FamilyProject({
    required this.id,
    required this.familyId,
    required this.title,
    this.description = '',
    required this.createdBy,
    required this.creatorName,
    required this.createdAt,
    this.dueDate,
    this.status = ProjectStatus.active,
    this.priority = ProjectPriority.medium,
    this.memberIds = const [],
    this.tasks = const [],
    this.tags = const [],
    this.coverImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'familyId': familyId,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status.name,
      'priority': priority.name,
      'memberIds': memberIds,
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'tags': tags,
      'coverImageUrl': coverImageUrl,
    };
  }

  factory FamilyProject.fromMap(Map<String, dynamic> map, String docId) {
    return FamilyProject(
      id: docId,
      familyId: map['familyId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      creatorName: map['creatorName'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      status: _parseStatus(map['status']),
      priority: _parsePriority(map['priority']),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      tasks: (map['tasks'] as List?)
              ?.map((t) => ProjectTask.fromMap(t))
              .toList() ??
          [],
      tags: List<String>.from(map['tags'] ?? []),
      coverImageUrl: map['coverImageUrl'],
    );
  }

  static ProjectStatus _parseStatus(String? value) {
    switch (value) {
      case 'completed':
        return ProjectStatus.completed;
      case 'archived':
        return ProjectStatus.archived;
      default:
        return ProjectStatus.active;
    }
  }

  static ProjectPriority _parsePriority(String? value) {
    switch (value) {
      case 'low':
        return ProjectPriority.low;
      case 'high':
        return ProjectPriority.high;
      default:
        return ProjectPriority.medium;
    }
  }

  FamilyProject copyWith({
    String? id,
    String? familyId,
    String? title,
    String? description,
    String? createdBy,
    String? creatorName,
    DateTime? createdAt,
    DateTime? dueDate,
    ProjectStatus? status,
    ProjectPriority? priority,
    List<String>? memberIds,
    List<ProjectTask>? tasks,
    List<String>? tags,
    String? coverImageUrl,
  }) {
    return FamilyProject(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      memberIds: memberIds ?? this.memberIds,
      tasks: tasks ?? this.tasks,
      tags: tags ?? this.tags,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }

  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;
  double get progressPercentage => tasks.isEmpty ? 0 : completedTasksCount / tasks.length;
}
