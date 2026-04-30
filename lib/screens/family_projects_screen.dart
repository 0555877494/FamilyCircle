import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../models/family_project.dart';
import '../models/family_user.dart';
import '../services/project_service.dart';
import '../widgets/skeleton_loader.dart';
import 'project_detail_screen.dart';
import 'create_project_screen.dart';

class FamilyProjectsScreen extends StatefulWidget {
  final FamilyUser currentUser;

  const FamilyProjectsScreen({super.key, required this.currentUser});

  @override
  State<FamilyProjectsScreen> createState() => _FamilyProjectsScreenState();
}

class _FamilyProjectsScreenState extends State<FamilyProjectsScreen> {
  final _projectService = ProjectService();
  List<FamilyProject> _projects = [];
  bool _isLoading = true;
  String _filter = 'active';

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    _projectService
        .getProjectsStream(widget.currentUser.familyId)
        .listen((projects) {
      if (mounted) {
        setState(() {
          _projects = projects;
          _isLoading = false;
        });
      }
    });
  }

  List<FamilyProject> get _filteredProjects {
    if (_filter == 'all') return _projects;
    return _projects
        .where((p) => p.status.name == _filter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Projects', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'active', child: Text('Active')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
              const PopupMenuItem(value: 'all', child: Text('All')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const ProjectListSkeleton()
          : _filteredProjects.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredProjects.length,
                  itemBuilder: (ctx, i) => _buildProjectCard(_filteredProjects[i]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateProjectScreen(
                currentUser: widget.currentUser,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _filter == 'active' ? 'No active projects' : 'No projects found',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _filter = 'all'),
            child: const Text('View all projects'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(FamilyProject project) {
    final priorityColor = _getPriorityColor(project.priority);
    final statusColor = _getStatusColor(project.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(
                project: project,
                currentUser: widget.currentUser,
              ),
            ),
          );
        },
        child: ModernCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        project.priority.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        project.status.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  project.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                if (project.tasks.isNotEmpty) ...[
                  LinearProgressIndicator(
                    value: project.progressPercentage,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${project.completedTasksCount}/${project.tasks.length} tasks completed',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    ...project.memberIds.take(3).map((id) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: CircleAvatar(
                            radius: 14,
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
                        )),
                    if (project.memberIds.length > 3)
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          '+${project.memberIds.length - 3}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const Spacer(),
                    if (project.dueDate != null)
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${project.dueDate!.month}/${project.dueDate!.day}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
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
