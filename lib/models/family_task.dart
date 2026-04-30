enum TaskStatus { pending, inProgress, completed, overdue }

enum TaskPriority { low, medium, high, urgent }

enum TaskCategory { chore, homework, work, personal, family, health, other }

class FamilyTask {
  final String id;
  final String familyId;
  final String title;
  final String? description;
  final String assignedToId;
  final String createdById;
  final TaskStatus status;
  final TaskPriority priority;
  final TaskCategory category;
  final DateTime dueDate;
  final DateTime? completedDate;
  final int points;
  final bool isRecurring;
  final String? recurrenceRule;
  final DateTime createdAt;

  FamilyTask({
    required this.id,
    required this.familyId,
    required this.title,
    this.description,
    required this.assignedToId,
    required this.createdById,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.chore,
    required this.dueDate,
    this.completedDate,
    this.points = 0,
    this.isRecurring = false,
    this.recurrenceRule,
    required this.createdAt,
  });

  FamilyTask copyWith({
    TaskStatus? status,
    DateTime? completedDate,
    String? description,
    TaskPriority? priority,
    TaskCategory? category,
    int? points,
  }) {
    return FamilyTask(
      id: id,
      familyId: familyId,
      title: title,
      description: description ?? this.description,
      assignedToId: assignedToId,
      createdById: createdById,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate,
      completedDate: completedDate ?? this.completedDate,
      points: points ?? this.points,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'title': title,
      'description': description,
      'assignedToId': assignedToId,
      'createdById': createdById,
      'status': status.name,
      'priority': priority.name,
      'category': category.name,
      'dueDate': dueDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'points': points,
      'isRecurring': isRecurring,
      'recurrenceRule': recurrenceRule,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyTask.fromMap(Map<String, dynamic> map) {
    return FamilyTask(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      assignedToId: map['assignedToId'] as String,
      createdById: map['createdById'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.chore,
      ),
      dueDate: DateTime.parse(map['dueDate'] as String),
      completedDate: map['completedDate'] != null
          ? DateTime.parse(map['completedDate'] as String)
          : null,
      points: map['points'] as int? ?? 0,
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurrenceRule: map['recurrenceRule'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
