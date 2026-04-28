import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_status.dart';

enum ReminderFrequency { once, daily, weekly, monthly, yearly }

class FamilyReminder {
  final String id;
  final String familyId;
  final String title;
  final String? description;
  final DateTime reminderTime;
  final ReminderFrequency frequency;
  final List<String> notifyMemberIds;
  final bool isActive;
  final DateTime createdAt;

  FamilyReminder({
    required this.id,
    required this.familyId,
    required this.title,
    this.description,
    required this.reminderTime,
    required this.frequency,
    required this.notifyMemberIds,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'title': title,
      'description': description,
      'reminderTime': reminderTime.toIso8601String(),
      'frequency': frequency.name,
      'notifyMemberIds': notifyMemberIds,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyReminder.fromMap(Map<String, dynamic> map) {
    return FamilyReminder(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      reminderTime: DateTime.parse(map['reminderTime'] as String),
      frequency: ReminderFrequency.values.firstWhere((e) => e.name == map['frequency']),
      notifyMemberIds: List<String>.from(map['notifyMemberIds'] as List),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class RemindersScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const RemindersScreen({super.key, required this.currentUser});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<FamilyReminder> _reminders = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadSampleReminders();
  }

  void _loadSampleReminders() {
    final now = DateTime.now();
    _reminders = [
      FamilyReminder(id: 'rem_001', familyId: widget.currentUser.familyId, title: '💊 Take vitamins', description: 'Morning vitamins', reminderTime: DateTime(now.year, now.month, now.day, 8, 0), frequency: ReminderFrequency.daily, notifyMemberIds: [widget.currentUser.id], createdAt: now),
      FamilyReminder(id: 'rem_002', familyId: widget.currentUser.familyId, title: '🐕 Walk the dog', description: 'Morning walk', reminderTime: DateTime(now.year, now.month, now.day, 7, 30), frequency: ReminderFrequency.daily, notifyMemberIds: ['user_003'], createdAt: now),
      FamilyReminder(id: 'rem_003', familyId: widget.currentUser.familyId, title: '📚 Homework check', description: 'Review Emma\'s homework', reminderTime: DateTime(now.year, now.month, now.day, 17, 0), frequency: ReminderFrequency.weekly, notifyMemberIds: ['user_002'], createdAt: now),
      FamilyReminder(id: 'rem_004', familyId: widget.currentUser.familyId, title: '🧘 Family prayer', description: 'Evening prayer time', reminderTime: DateTime(now.year, now.month, now.day, 20, 0), frequency: ReminderFrequency.daily, notifyMemberIds: ['user_001', 'user_002', 'user_005'], createdAt: now),
      FamilyReminder(id: 'rem_005', familyId: widget.currentUser.familyId, title: '📅 Weekly family meeting', description: 'Sunday planning', reminderTime: DateTime(now.year, now.month, now.day, 10, 0), frequency: ReminderFrequency.weekly, notifyMemberIds: ['user_001', 'user_002'], createdAt: now),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: _reminders.isEmpty 
        ? _buildEmptyState()
        : ListView.builder(
            itemCount: _reminders.length,
            itemBuilder: (ctx, i) => _buildReminderCard(_reminders[i]),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        child: const Icon(Icons.alarm_add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No reminders set'),
          const SizedBox(height: 8),
          Text('Set reminders for medications, chores, events'),
        ],
      ),
    );
  }

  Widget _buildReminderCard(FamilyReminder reminder) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: reminder.isActive ? AppTheme.primaryColor.withOpacity(0.2) : Colors.grey[200],
          child: Icon(Icons.alarm, color: reminder.isActive ? AppTheme.primaryColor : Colors.grey),
        ),
        title: Text(reminder.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, size: 14),
                Text(' ${_formatTime(reminder.reminderTime)}'),
                const SizedBox(width: 8),
                Chip(label: Text(reminder.frequency.name, style: const TextStyle(fontSize: 10))),
              ],
            ),
            if (reminder.description != null) Text(reminder.description!),
          ],
        ),
        trailing: Switch(
          value: reminder.isActive,
          onChanged: (v) => _toggleReminder(reminder),
        ),
        onLongPress: () => _deleteReminder(reminder),
      ),
    );
  }

  void _toggleReminder(FamilyReminder reminder) {
    setState(() {
      _reminders = _reminders.where((r) => r.id != reminder.id).toList()
        ..add(FamilyReminder(
          id: reminder.id,
          familyId: reminder.familyId,
          title: reminder.title,
          description: reminder.description,
          reminderTime: reminder.reminderTime,
          frequency: reminder.frequency,
          notifyMemberIds: reminder.notifyMemberIds,
          isActive: !reminder.isActive,
          createdAt: reminder.createdAt,
        ));
    });
  }

  void _deleteReminder(FamilyReminder reminder) {
    setState(() => _reminders.removeWhere((r) => r.id == reminder.id));
  }

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    ReminderFrequency selectedFreq = ReminderFrequency.daily;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Reminder Title')),
                const SizedBox(height: 8),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Time'),
                  trailing: Text('${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                  onTap: () async {
                    final time = await showTimePicker(context: ctx, initialTime: selectedTime);
                    if (time != null) setDialogState(() => selectedTime = time);
                  },
                ),
                DropdownButtonFormField<ReminderFrequency>(
                  value: selectedFreq,
                  items: ReminderFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedFreq = v!),
                  decoration: const InputDecoration(labelText: 'Frequency'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final now = DateTime.now();
                  final reminder = FamilyReminder(
                    id: _uuid.v4(),
                    familyId: widget.currentUser.familyId,
                    title: titleController.text,
                    description: descController.text.isEmpty ? null : descController.text,
                    reminderTime: DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute),
                    frequency: selectedFreq,
                    notifyMemberIds: [widget.currentUser.id],
                    createdAt: DateTime.now(),
                  );
                  setState(() => _reminders.add(reminder));
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

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}