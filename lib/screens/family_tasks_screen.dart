import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../models/family_task.dart';
import '../services/file_service.dart';
import '../widgets/connection_status.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';

class FamilyTasksScreen extends StatefulWidget {
  final FamilyUser currentUser;

  const FamilyTasksScreen({super.key, required this.currentUser});

  @override
  State<FamilyTasksScreen> createState() => _FamilyTasksScreenState();
}

class _FamilyTasksScreenState extends State<FamilyTasksScreen> {
  final _uuid = const Uuid();
  List<FamilyTask> _tasks = [];
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _loadSampleTasks();
  }

  void _loadSampleTasks() {
    final now = DateTime.now();
    _tasks = [
      FamilyTask(
        id: '1',
        familyId: widget.currentUser.familyId,
        title: 'Clean garage',
        description: 'Organize tools and boxes',
        assignedToId: widget.currentUser.id,
        createdById: widget.currentUser.id,
        category: TaskCategory.chore,
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 3)),
        points: 10,
        createdAt: now,
      ),
      FamilyTask(
        id: '2',
        familyId: widget.currentUser.familyId,
        title: 'Math homework',
        description: 'Chapter 5 exercises',
        assignedToId: 'child1',
        createdById: widget.currentUser.id,
        category: TaskCategory.homework,
        priority: TaskPriority.high,
        dueDate: now.add(const Duration(days: 1)),
        points: 20,
        createdAt: now,
      ),
      FamilyTask(
        id: '3',
        familyId: widget.currentUser.familyId,
        title: 'Buy groceries',
        description: 'Milk, eggs, bread, vegetables',
        assignedToId: widget.currentUser.id,
        createdById: widget.currentUser.id,
        category: TaskCategory.family,
        priority: TaskPriority.low,
        dueDate: now,
        status: TaskStatus.completed,
        completedDate: now.subtract(const Duration(days: 1)),
        points: 5,
        createdAt: now,
      ),
    ];
  }

  List<FamilyTask> get _filteredTasks {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 1:
        return _tasks.where((t) => t.assignedToId == widget.currentUser.id).toList();
      case 2:
        return _tasks.where((t) => t.status == TaskStatus.pending).toList();
      case 3:
        return _tasks.where((t) => t.status == TaskStatus.completed).toList();
      case 4:
        return _tasks
            .where((t) => t.dueDate.isBefore(now) && t.status != TaskStatus.completed)
            .toList();
      default:
        return _tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Tasks'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: ConnectionStatusIndicator(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _filteredTasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (ctx, i) => _buildTaskCard(_filteredTasks[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Mine', 'Pending', 'Done', 'Overdue'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = _selectedFilter == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filters[i]),
              selected: isSelected,
              onSelected: (v) => setState(() => _selectedFilter = i),
              backgroundColor: isSelected ? AppColors.primary : null,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTaskCard(FamilyTask task) {
    final isOverdue = task.dueDate.isBefore(DateTime.now()) &&
        task.status != TaskStatus.completed;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: HoverCard(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.status == TaskStatus.completed,
                onChanged: (v) => _toggleTaskStatus(task),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == TaskStatus.completed
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                    if (task.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildPriorityChip(task.priority),
                        Chip(
                          label: Text(
                            task.category.name,
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: isOverdue ? Colors.red : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Due: ${_formatDate(task.dueDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isOverdue ? Colors.red : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        if (task.points > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text('${task.points}',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                onSelected: (v) {
                  if (v == 'delete') _deleteTask(task);
                },
                child: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    String label;
    switch (priority) {
      case TaskPriority.urgent:
        color = Colors.red;
        label = 'Urgent';
        break;
      case TaskPriority.high:
        color = Colors.orange;
        label = 'High';
        break;
      case TaskPriority.medium:
        color = Colors.blue;
        label = 'Med';
        break;
      case TaskPriority.low:
        color = Colors.grey;
        label = 'Low';
        break;
    }
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 10)),
      backgroundColor: color.withValues(alpha: 0.2),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  void _toggleTaskStatus(FamilyTask task) {
    final newStatus =
        task.status == TaskStatus.completed ? TaskStatus.pending : TaskStatus.completed;
    final newTask = task.copyWith(
      status: newStatus,
      completedDate:
          newStatus == TaskStatus.completed ? DateTime.now() : null,
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
          title: const Text('Add New Task'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title *',
                      hintText: 'What needs to be done?',
                      border: OutlineInputBorder(),
                      helperText: 'Required field',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Add details or instructions...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TaskCategory>(
                    value: selectedCategory,
                    items: TaskCategory.values
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedCategory = v!),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TaskPriority>(
                    value: selectedPriority,
                    items: TaskPriority.values
                        .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => selectedPriority = v!),
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Points:', style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: points.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 10,
                          label: '$points',
                          onChanged: (v) => setDialogState(() => points = v.toInt()),
                        ),
                      ),
                      Text('$points', style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: ctx,
                        initialDate: dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setDialogState(() => dueDate = date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_formatDate(dueDate)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                setState(() {
                  _tasks.add(FamilyTask(
                    id: _uuid.v4(),
                    familyId: widget.currentUser.familyId,
                    title: titleController.text.trim(),
                    description: descController.text.isEmpty
                        ? null
                        : descController.text.trim(),
                    assignedToId: widget.currentUser.id,
                    createdById: widget.currentUser.id,
                    category: selectedCategory,
                    priority: selectedPriority,
                    dueDate: dueDate,
                    points: points,
                    createdAt: DateTime.now(),
                  ));
                });
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 3 ? 'No completed tasks yet' : 'No tasks found',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _showAddTaskDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
        ],
      ),
    );
  }
}
