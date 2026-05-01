import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../widgets/connection_status.dart';

enum ActivityType { homework, chore, play, exercise, social, screenTime, creative, learning, outdoor, other }
enum ActivityStatus { planned, inProgress, completed, cancelled }

class FamilyActivity {
  final String id;
  final String familyId;
  final String memberId;
  final String title;
  final String? description;
  final ActivityType type;
  final ActivityStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final List<String> participantIds;
  final bool isOutdoor;
  final String? photoUrl;
  final DateTime createdAt;

  FamilyActivity({
    required this.id,
    required this.familyId,
    required this.memberId,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    this.location,
    required this.participantIds,
    this.isOutdoor = false,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'memberId': memberId,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'location': location,
      'participantIds': participantIds,
      'isOutdoor': isOutdoor,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyActivity.fromMap(Map<String, dynamic> map) {
    return FamilyActivity(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      memberId: map['memberId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: ActivityType.values.firstWhere((e) => e.name == map['type']),
      status: ActivityStatus.values.firstWhere((e) => e.name == map['status']),
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      location: map['location'] as String?,
      participantIds: List<String>.from(map['participantIds'] as List),
      isOutdoor: map['isOutdoor'] as bool? ?? false,
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class ActivityLogScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const ActivityLogScreen({super.key, required this.currentUser});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  List<FamilyActivity> _activities = [];
  final _uuid = const Uuid();
  int _selectedFilter = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSampleActivities();
  }

  void _loadSampleActivities() {
    final now = DateTime.now();
    _activities = [
      FamilyActivity(id: 'act_001', familyId: widget.currentUser.familyId, memberId: 'user_001', title: '🚗 Drive to work', type: ActivityType.other, status: ActivityStatus.completed, startTime: now.subtract(const Duration(hours: 6)), location: '123 Maple St → Office', participantIds: ['user_001'], createdAt: now),
      FamilyActivity(id: 'act_002', familyId: widget.currentUser.familyId, memberId: 'user_003', title: '🏫 School day', type: ActivityType.homework, status: ActivityStatus.completed, startTime: now.subtract(const Duration(hours: 5)), endTime: now.subtract(const Duration(hours: 2)), location: 'Elementary School', participantIds: ['user_003'], createdAt: now),
      FamilyActivity(id: 'act_003', familyId: widget.currentUser.familyId, memberId: 'user_002', title: '🛒 Grocery shopping', type: ActivityType.chore, status: ActivityStatus.completed, startTime: now.subtract(const Duration(hours: 4)), location: 'Whole Foods', participantIds: ['user_002'], createdAt: now),
      FamilyActivity(id: 'act_004', familyId: widget.currentUser.familyId, memberId: 'user_004', title: '⚽ Soccer practice', type: ActivityType.exercise, status: ActivityStatus.completed, startTime: now.subtract(const Duration(hours: 3)), location: 'Park Field', participantIds: ['user_004'], isOutdoor: true, createdAt: now),
      FamilyActivity(id: 'act_005', familyId: widget.currentUser.familyId, memberId: 'user_001', title: '💼 Work meeting', type: ActivityType.learning, status: ActivityStatus.completed, startTime: now.subtract(const Duration(hours: 2)), location: 'Conference Room B', participantIds: ['user_001'], createdAt: now),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          _buildFilterChips(),
          Expanded(child: _buildActivityList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddActivityDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
          ),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            child: Text(
              _formatDate(_selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() {
              if (_selectedDate.isBefore(DateTime.now())) {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Homework', 'Chores', 'Play', 'Exercise', 'Learning', 'Outdoor'];
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

  Widget _buildActivityList() {
    final filtered = _getFilteredActivities();
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No activities', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => _buildActivityCard(filtered[i]),
    );
  }

  List<FamilyActivity> _getFilteredActivities() {
    return _activities.where((a) {
      if (_selectedFilter == 0) return true;
      final filterTypes = [
        ActivityType.homework, ActivityType.chore, ActivityType.play, 
        ActivityType.exercise, ActivityType.learning, ActivityType.outdoor
      ];
      return _selectedFilter - 1 < filterTypes.length && a.type == filterTypes[_selectedFilter - 1];
    }).toList();
  }

  Widget _buildActivityCard(FamilyActivity activity) {
    final duration = activity.endTime?.difference(activity.startTime);
    final hours = duration?.inHours ?? 0;
    final minutes = duration?.inMinutes ?? 0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(activity.type).withValues(alpha: 0.2),
          child: Icon(_getTypeIcon(activity.type), color: _getTypeColor(activity.type)),
        ),
        title: Text(activity.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.type.name),
            Row(
              children: [
                Icon(Icons.access_time, size: 14),
                Text(' ${activity.startTime.hour}:${activity.startTime.minute.toString().padLeft(2, '0')}'),
                if (hours > 0 || minutes > 0) ...[
                  Text(' (${hours}h ${minutes}m)'),
                ],
                if (activity.isOutdoor) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.park, size: 14, color: Colors.green),
                ],
              ],
            ),
          ],
        ),
        trailing: _getStatusChip(activity.status),
      ),
    );
  }

  Widget _getStatusChip(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed: return const Chip(label: Text('Done'), backgroundColor: Colors.green);
      case ActivityStatus.inProgress: return const Chip(label: Text('Active'), backgroundColor: Colors.blue);
      case ActivityStatus.planned: return const Chip(label: Text('Planned'), backgroundColor: Colors.orange);
      case ActivityStatus.cancelled: return const Chip(label: Text('Cancelled'), backgroundColor: Colors.grey);
    }
  }

  Color _getTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.homework: return Colors.orange;
      case ActivityType.chore: return Colors.green;
      case ActivityType.play: return Colors.pink;
      case ActivityType.exercise: return Colors.blue;
      case ActivityType.social: return Colors.purple;
      case ActivityType.screenTime: return Colors.indigo;
      case ActivityType.creative: return Colors.teal;
      case ActivityType.learning: return Colors.amber;
      case ActivityType.outdoor: return Colors.green;
      case ActivityType.other: return Colors.grey;
    }
  }

  IconData _getTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.homework: return Icons.school;
      case ActivityType.chore: return Icons.cleaning_services;
      case ActivityType.play: return Icons.sports_esports;
      case ActivityType.exercise: return Icons.fitness_center;
      case ActivityType.social: return Icons.groups;
      case ActivityType.screenTime: return Icons.phone_android;
      case ActivityType.creative: return Icons.palette;
      case ActivityType.learning: return Icons.menu_book;
      case ActivityType.outdoor: return Icons.park;
      case ActivityType.other: return Icons.more_horiz;
    }
  }

  void _showAddActivityDialog() {
    final titleController = TextEditingController();
    ActivityType selectedType = ActivityType.play;
    DateTime startTime = DateTime.now();
    DateTime? endTime = DateTime.now().add(const Duration(hours: 1));
    bool isOutdoor = false;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Log Activity'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Activity Title')),
                const SizedBox(height: 8),
                DropdownButtonFormField<ActivityType>(
                  value: selectedType,
                  items: ActivityType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Outdoor Activity'),
                  value: isOutdoor,
                  onChanged: (v) => setDialogState(() => isOutdoor = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Start'),
                        subtitle: Text('${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}'),
                        onTap: () async {
                          final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(startTime));
                          if (time != null) setDialogState(() => startTime = DateTime(
                            startTime.year, startTime.month, startTime.day, time.hour, time.minute,
                          ));
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('End'),
                        subtitle: Text('${endTime?.hour ?? 0}:${(endTime?.minute ?? 0).toString().padLeft(2, '0')}'),
                        onTap: () async {
                          final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(endTime!));
                          if (time != null) setDialogState(() => endTime = DateTime(
                            endTime!.year, endTime!.month, endTime!.day, time.hour, time.minute,
                          ));
                        },
                      ),
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
                  final activity = FamilyActivity(
                    id: _uuid.v4(),
                    familyId: widget.currentUser.familyId,
                    memberId: widget.currentUser.id,
                    title: titleController.text,
                    type: selectedType,
                    status: ActivityStatus.completed,
                    startTime: startTime,
                    endTime: endTime,
                    participantIds: [widget.currentUser.id],
                    isOutdoor: isOutdoor,
                    createdAt: DateTime.now(),
                  );
                  setState(() => _activities.add(activity));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}