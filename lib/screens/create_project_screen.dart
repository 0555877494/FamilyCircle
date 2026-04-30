import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';
import '../models/family_project.dart';
import '../models/family_user.dart';
import '../services/project_service.dart';
import '../services/user_service.dart';

class CreateProjectScreen extends StatefulWidget {
  final FamilyUser currentUser;
  final FamilyProject? project;

  const CreateProjectScreen({
    super.key,
    required this.currentUser,
    this.project,
  });

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _projectService = ProjectService();
  final _userService = UserService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();

  ProjectPriority _priority = ProjectPriority.medium;
  DateTime? _dueDate;
  List<String> _selectedMemberIds = [];
  List<FamilyUser> _familyMembers = [];
  List<String> _tags = [];
  bool _isSaving = false;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _loadMembers();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final p = widget.project!;
    _titleController.text = p.title;
    _descriptionController.text = p.description;
    _priority = p.priority;
    _dueDate = p.dueDate;
    _selectedMemberIds = List.from(p.memberIds);
    _tags = List.from(p.tags);
  }

  Future<void> _loadMembers() async {
    final members = await _userService.getUsersByFamily(widget.currentUser.familyId);
    if (mounted) {
      setState(() => _familyMembers = members);
    }
  }

  Future<void> _saveProject() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project title')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final project = FamilyProject(
        id: _isEditing ? widget.project!.id : '',
        familyId: widget.currentUser.familyId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdBy: widget.currentUser.id,
        creatorName: '${widget.currentUser.firstName} ${widget.currentUser.lastName ?? ''}'.trim(),
        createdAt: _isEditing ? widget.project!.createdAt : DateTime.now(),
        dueDate: _dueDate,
        priority: _priority,
        memberIds: _selectedMemberIds,
        tasks: _isEditing ? widget.project!.tasks : [],
        tags: _tags,
      );

      if (_isEditing) {
        await _projectService.updateProject(project);
      } else {
        await _projectService.createProject(project);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving project: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Project' : 'New Project',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProject,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Project Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  ...ProjectPriority.values.map((p) => RadioListTile<ProjectPriority>(
                        title: Text(p.name.toUpperCase()),
                        value: p,
                        groupValue: _priority,
                        onChanged: (v) => setState(() => _priority = v!),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ModernCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Due Date'),
                    trailing: _dueDate != null
                        ? TextButton(
                            onPressed: () => setState(() => _dueDate = null),
                            child: const Text('Clear'),
                          )
                        : null,
                    subtitle: _dueDate != null
                        ? Text('${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}')
                        : const Text('No due date'),
                    onTap: _pickDueDate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Team Members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  ..._familyMembers.map((member) {
                    final id = member.id;
                    final name = '${member.firstName} ${member.lastName ?? ''}'.trim();
                    return CheckboxListTile(
                      value: _selectedMemberIds.contains(id),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selectedMemberIds.add(id);
                          } else {
                            _selectedMemberIds.remove(id);
                          }
                        });
                      },
                      title: Text(name),
                      secondary: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          member.firstName.substring(0, 1).toUpperCase(),
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tags', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              labelText: 'Add tag',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addTag,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  if (_tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        children: _tags
                            .map((tag) => Chip(
                                  label: Text('#$tag'),
                                  onDeleted: () => setState(() => _tags.remove(tag)),
                                ))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
