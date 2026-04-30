import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';
import '../models/family_project.dart';
import '../models/family_user.dart';
import '../services/project_service.dart';
import '../widgets/skeleton_loader.dart';
import 'create_project_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final FamilyProject project;
  final FamilyUser currentUser;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.currentUser,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _projectService = ProjectService();
  late FamilyProject _project;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _loadProject();
  }

  void _loadProject() {
    _projectService.getProjectsStream(widget.currentUser.familyId).listen((projects) {
      if (mounted) {
        final updated = projects.where((p) => p.id == _project.id).toList();
        if (updated.isNotEmpty) {
          setState(() => _project = updated.first);
        }
      }
    });
  }

  Future<void> _toggleTask(String taskId) async {
    setState(() => _isLoading = true);
    try {
      await _projectService.toggleTask(_project.id, taskId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(ProjectStatus status) async {
    setState(() => _isLoading = true);
    try {
      await _projectService.updateStatus(_project.id, status);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(_project.priority);

    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_project.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateProjectScreen(
                    currentUser: widget.currentUser,
                    project: _project,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'complete':
                  _updateStatus(ProjectStatus.completed);
                  break;
                case 'archive':
                  _updateStatus(ProjectStatus.archived);
                  break;
                case 'activate':
                  _updateStatus(ProjectStatus.active);
                  break;
              }
            },
            itemBuilder: (context) => [
              if (_project.status != ProjectStatus.active)
                const PopupMenuItem(value: 'activate', child: Text('Mark Active')),
              if (_project.status != ProjectStatus.completed)
                const PopupMenuItem(value: 'complete', child: Text('Mark Complete')),
              if (_project.status != ProjectStatus.archived)
                const PopupMenuItem(value: 'archive', child: Text('Archive')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const ProjectDetailSkeleton()
          : ResponsiveWrapper(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ModernCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: priorityColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _project.priority.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: priorityColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_project.status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _project.status.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(_project.status),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'By ${_project.creatorName}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          if (_project.description.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              _project.description,
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_project.memberIds.isNotEmpty) ...[
                    ModernCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Team Members',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _project.memberIds.map((id) {
                                return Chip(
                                  avatar: CircleAvatar(
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    child: Text(
                                      id.substring(0, 1).toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  label: Text(id),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_project.tasks.isNotEmpty) ...[
                    ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Text('Tasks',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const Spacer(),
                                Text(
                                  '${_project.completedTasksCount}/${_project.tasks.length}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          LinearProgressIndicator(
                            value: _project.progressPercentage,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            minHeight: 4,
                          ),
                          const Divider(height: 1),
                          ..._project.tasks.map((task) => CheckboxListTile(
                                value: task.isCompleted,
                                onChanged: (_) => _toggleTask(task.id),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: task.isCompleted ? Colors.grey : null,
                                  ),
                                ),
                                secondary: task.assignedToName != null
                                    ? Text(task.assignedToName!,
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600))
                                    : null,
                                controlAffinity: ListTileControlAffinity.leading,
                              )),
                        ],
                      ),
                    ),
                  ] else ...[
                    ModernCard(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.task_alt, size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text('No tasks yet',
                                  style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_project.dueDate != null)
                    ModernCard(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today, color: Colors.grey),
                        title: const Text('Due Date'),
                        trailing: Text(
                          '${_project.dueDate!.month}/${_project.dueDate!.day}/${_project.dueDate!.year}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  if (_project.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ModernCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: _project.tags
                                  .map((tag) => Chip(
                                        label: Text('#$tag'),
                                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Color _getPriorityColor(ProjectPriority priority) {
    switch (priority) {
      case ProjectPriority.high:
        return Colors.red;
      case ProjectPriority.medium:
        return Colors.orange;
      case ProjectPriority.low:
        return Colors.green;
    }
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return Colors.blue;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.archived:
        return Colors.grey;
    }
  }
}
