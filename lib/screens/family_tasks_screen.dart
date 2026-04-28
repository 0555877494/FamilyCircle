import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../services/file_service.dart';
import '../widgets/connection_status.dart';

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
  }) {
    return FamilyTask(
      id: id,
      familyId: familyId,
      title: title,
      description: description,
      assignedToId: assignedToId,
      createdById: createdById,
      status: status ?? this.status,
      priority: priority,
      category: category,
      dueDate: dueDate,
      completedDate: completedDate ?? this.completedDate,
      points: points,
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
      status: TaskStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => TaskStatus.pending),
      priority: TaskPriority.values.firstWhere((e) => e.name == map['priority'], orElse: () => TaskPriority.medium),
      category: TaskCategory.values.firstWhere((e) => e.name == map['category'], orElse: () => TaskCategory.chore),
      dueDate: DateTime.parse(map['dueDate'] as String),
      completedDate: map['completedDate'] != null ? DateTime.parse(map['completedDate'] as String) : null,
      points: map['points'] as int? ?? 0,
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurrenceRule: map['recurrenceRule'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class FamilyTasksScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const FamilyTasksScreen({super.key, required this.currentUser});

  @override
  State<FamilyTasksScreen> createState() => _FamilyTasksScreenState();
}

class _FamilyTasksScreenState extends State<FamilyTasksScreen> {
  int _selectedFilter = 0;
  List<FamilyTask> _tasks = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadSampleTasks();
  }

  void _loadSampleTasks() {
    final now = DateTime.now();
    _tasks = [
      FamilyTask(id: '1', familyId: widget.currentUser.familyId, title: 'Take out trash', description: 'Weekly trash collection', assignedToId: widget.currentUser.id, createdById: 'parent1', status: TaskStatus.pending, priority: TaskPriority.medium, category: TaskCategory.chore, dueDate: now.add(const Duration(days: 1)), points: 10, createdAt: now),
      FamilyTask(id: '2', familyId: widget.currentUser.familyId, title: 'Finish homework', description: 'Math assignment pages 40-45', assignedToId: widget.currentUser.id, createdById: 'parent1', status: TaskStatus.inProgress, priority: TaskPriority.high, category: TaskCategory.homework, dueDate: now.add(const Duration(days: 2)), points: 20, createdAt: now),
      FamilyTask(id: '3', familyId: widget.currentUser.familyId, title: 'Walk the dog', description: 'Morning and evening walks', assignedToId: widget.currentUser.id, createdById: 'parent1', status: TaskStatus.completed, priority: TaskPriority.medium, category: TaskCategory.chore, dueDate: now, completedDate: now, points: 15, isRecurring: true, recurrenceRule: 'daily', createdAt: now),
      FamilyTask(id: '4', familyId: widget.currentUser.familyId, title: 'Doctor appointment', description: 'Annual checkup at 2pm', assignedToId: widget.currentUser.id, createdById: 'parent1', status: TaskStatus.pending, priority: TaskPriority.urgent, category: TaskCategory.health, dueDate: now.add(const Duration(days: 5)), points: 0, createdAt: now),
      FamilyTask(id: '5', familyId: widget.currentUser.familyId, title: 'Family dinner prep', description: 'Prepare ingredients for Sunday dinner', assignedToId: widget.currentUser.id, createdById: 'parent1', status: TaskStatus.overdue, priority: TaskPriority.low, category: TaskCategory.family, dueDate: now.subtract(const Duration(days: 1)), points: 25, createdAt: now),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Tasks'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildTaskList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'My Tasks', 'Pending', 'Completed', 'Overdue'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: List.generate(filters.length, (i) => 
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[i]),
              selected: _selectedFilter == i,
              onSelected: (s) => setState(() => _selectedFilter = i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final filtered = _getFilteredTasks();
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No tasks yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => _buildTaskCard(filtered[i]),
    );
  }

  List<FamilyTask> _getFilteredTasks() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 1: return _tasks.where((t) => t.assignedToId == widget.currentUser.id).toList();
      case 2: return _tasks.where((t) => t.status == TaskStatus.pending).toList();
      case 3: return _tasks.where((t) => t.status == TaskStatus.completed).toList();
      case 4: return _tasks.where((t) => t.dueDate.isBefore(now) && t.status != TaskStatus.completed).toList();
      default: return _tasks;
    }
  }

  Widget _buildTaskCard(FamilyTask task) {
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && task.status != TaskStatus.completed;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.status == TaskStatus.completed,
          onChanged: (v) => _toggleTaskStatus(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
            color: task.status == TaskStatus.completed ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) Text(task.description!),
            Row(
              children: [
                _buildPriorityChip(task.priority),
                const SizedBox(width: 8),
                Text('Due: ${_formatDate(task.dueDate)}'),
                if (task.points > 0) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  Text('${task.points}'),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (v) {
            if (v == 'delete') _deleteTask(task);
          },
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    String label;
    switch (priority) {
      case TaskPriority.urgent: color = Colors.red; label = 'Urgent'; break;
      case TaskPriority.high: color = Colors.orange; label = 'High'; break;
      case TaskPriority.medium: color = Colors.blue; label = 'Med'; break;
      case TaskPriority.low: color = Colors.grey; label = 'Low'; break;
    }
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 10)),
      backgroundColor: color.withOpacity(0.2),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  void _toggleTaskStatus(FamilyTask task) {
    final newStatus = task.status == TaskStatus.completed ? TaskStatus.pending : TaskStatus.completed;
    final newTask = task.copyWith(
      status: newStatus,
      completedDate: newStatus == TaskStatus.completed ? DateTime.now() : null,
    );
    setState(() {
      _tasks = _tasks.where((t) => t.id != task.id).toList()..add(newTask);
    });
  }

  void _deleteTask(FamilyTask task) {
    setState(() => _tasks.removeWhere((t) => t.id == task.id));
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskCategory selectedCategory = TaskCategory.chore;
    TaskPriority selectedPriority = TaskPriority.medium;
    int points = 0;
    DateTime dueDate = DateTime.now().add(const Duration(days: 1));
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Task Title')),
                const SizedBox(height: 8),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskCategory>(
                  value: selectedCategory,
                  items: TaskCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedCategory = v!),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskPriority>(
                  value: selectedPriority,
                  items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedPriority = v!),
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Points: '),
                    Expanded(
                      child: Slider(value: points.toDouble(), min: 0, max: 100, divisions: 10, 
                        onChanged: (v) => setDialogState(() => points = v.toInt())),
                    ),
                    Text('$points'),
                  ],
                ),
                ListTile(
                  title: Text('Due: ${_formatDate(dueDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setDialogState(() => dueDate = date);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Proof of Completion', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Photo'),
                      onPressed: () => _pickFile(ctx),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark Done'),
                      onPressed: () {
                        setState(() {
                          _tasks.add(FamilyTask(
                            id: _uuid.v4(),
                            familyId: widget.currentUser.familyId,
                            title: titleController.text,
                            description: descController.text.isEmpty ? null : descController.text,
                            assignedToId: widget.currentUser.id,
                            createdById: widget.currentUser.id,
                            category: selectedCategory,
                            priority: selectedPriority,
                            dueDate: dueDate,
                            points: points,
                            status: TaskStatus.completed,
                            createdAt: DateTime.now(),
                          ));
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final task = FamilyTask(
                    id: _uuid.v4(),
                    familyId: widget.currentUser.familyId,
                    title: titleController.text,
                    description: descController.text.isEmpty ? null : descController.text,
                    assignedToId: widget.currentUser.id,
                    createdById: widget.currentUser.id,
                    category: selectedCategory,
                    priority: selectedPriority,
                    dueDate: dueDate,
                    points: points,
                    createdAt: DateTime.now(),
                  );
                  setState(() => _tasks.add(task));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  Future<void> _pickFile(BuildContext ctx) async {
    final fileService = FileService();
    final file = await fileService.pickAndUploadImage(
      widget.currentUser.familyId,
      widget.currentUser.id,
      widget.currentUser.firstName,
    );
    
    if (file != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Added: ${file.name}')),
      );
    }
  }
}