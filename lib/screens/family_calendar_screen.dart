import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../models/family_user.dart';
import '../services/calendar_service.dart';
import '../theme/modern_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_status.dart';

class FamilyCalendarScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const FamilyCalendarScreen({super.key, required this.currentUser});

  @override
  State<FamilyCalendarScreen> createState() => _FamilyCalendarScreenState();
}

class _FamilyCalendarScreenState extends State<FamilyCalendarScreen> {
  final _uuid = const Uuid();
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  List<CalendarEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _loadSampleEvents();
  }

  void _loadSampleEvents() {
    final now = DateTime.now();
    _events = [
      CalendarEvent(id: 'evt_001', familyId: widget.currentUser.familyId, title: '🎂 Emma\'s Birthday', description: 'Turns 6!', startTime: DateTime(2025, 5, 10, 9, 0), createdBy: 'user_002', memberIds: ['user_003'], createdAt: now),
      CalendarEvent(id: 'evt_002', familyId: widget.currentUser.familyId, title: '🏥 Doctor Appointment', description: 'Annual checkup', startTime: DateTime(2025, 5, 15, 14, 0), endTime: DateTime(2025, 5, 15, 15, 0), createdBy: 'user_001', memberIds: ['user_001'], location: 'City Medical', createdAt: now),
      CalendarEvent(id: 'evt_003', familyId: widget.currentUser.familyId, title: '🦃 Thanksgiving', description: 'Family dinner', startTime: DateTime(2025, 11, 27, 12, 0), createdBy: 'user_001', memberIds: ['user_001', 'user_002', 'user_003', 'user_004', 'user_005'], createdAt: now),
      CalendarEvent(id: 'evt_004', familyId: widget.currentUser.familyId, title: '🎄 Christmas', description: 'Family gathering', startTime: DateTime(2025, 12, 25, 10, 0), createdBy: 'user_001', memberIds: ['user_001', 'user_002', 'user_003', 'user_004', 'user_005'], createdAt: now),
      CalendarEvent(id: 'evt_005', familyId: widget.currentUser.familyId, title: '📅 Parent-Teacher Conference', description: 'Emma\'s school', startTime: DateTime(2025, 5, 20, 10, 0), endTime: DateTime(2025, 5, 20, 12, 0), createdBy: 'user_003', memberIds: ['user_002'], createdAt: now),
      CalendarEvent(id: 'evt_006', familyId: widget.currentUser.familyId, title: '🎯 Tom\'s soccer game', description: 'Championship game', startTime: DateTime(2025, 5, 18, 9, 0), endTime: DateTime(2025, 5, 18, 11, 0), createdBy: 'user_002', memberIds: ['user_004'], location: 'Park Field', createdAt: now),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Family Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: Column(
        children: [
          _buildMonthHeader(),
          _buildWeekdayHeader(),
          Flexible(
            child: _buildCalendarGrid(),
          ),
          const Divider(),
          Expanded(child: _buildEventsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            }),
          ),
          Text(
            '${['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][_focusedMonth.month - 1]} ${_focusedMonth.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekdays
            .map((d) => Expanded(
                  child: Center(
                    child: Text(d, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42,
      itemBuilder: (ctx, i) {
        if (i < firstWeekday - 1 || i >= daysInMonth + firstWeekday - 1) {
          return const SizedBox();
        }
        final day = i - firstWeekday + 2;
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        final isSelected = _selectedDay?.day == day && _selectedDay?.month == _focusedMonth.month;
        final isToday = day == today.day && _focusedMonth.month == today.month && _focusedMonth.year == today.year;
        final hasEvents = _events.any((e) => e.startTime.day == day);

        return GestureDetector(
          onTap: () => setState(() => _selectedDay = date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : null,
              border: isToday ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isToday ? FontWeight.bold : null,
                  ),
                ),
                if (hasEvents)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsList() {
    final selectedEvents = _selectedDay == null
        ? _events
        : _events.where((e) =>
            e.startTime.day == _selectedDay!.day &&
            e.startTime.month == _selectedDay!.month &&
            e.startTime.year == _selectedDay!.year).toList();

    if (selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              _selectedDay == null ? 'No upcoming events' : 'No events on this day',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: selectedEvents.length,
      itemBuilder: (ctx, i) => _buildEventTile(selectedEvents[i]),
    );
  }

  Widget _buildEventTile(CalendarEvent event) {
    return AnimatedListItem(
      index: _events.indexOf(event),
      child: ModernCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: event.isEmergency 
                    ? AppColors.warmGradient
                    : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                event.isEmergency ? Icons.warning : Icons.event,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('h:mm a').format(event.startTime)}${event.location != null ? ' | ${event.location}' : ''}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey.shade400),
              onPressed: () => setState(() => _events.removeWhere((e) => e.id == event.id)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    DateTime eventDate = _selectedDay ?? DateTime.now();
    TimeOfDay eventTime = TimeOfDay.now();
    bool isEmergency = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Event Title')),
                const SizedBox(height: 8),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text('${eventDate.month}/${eventDate.day}/${eventDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: eventDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setDialogState(() => eventDate = date);
                  },
                ),
                ListTile(
                  title: const Text('Time'),
                  subtitle: Text('${eventTime.hour}:${eventTime.minute.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(context: ctx, initialTime: eventTime);
                    if (time != null) setDialogState(() => eventTime = time);
                  },
                ),
                SwitchListTile(
                  title: const Text('Emergency Alert'),
                  value: isEmergency,
                  onChanged: (v) => setDialogState(() => isEmergency = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final startDateTime = DateTime(
                    eventDate.year,
                    eventDate.month,
                    eventDate.day,
                    eventTime.hour,
                    eventTime.minute,
                  );
                  final event = CalendarEvent(
                    id: _uuid.v4(),
                    familyId: widget.currentUser.familyId,
                    title: titleController.text,
                    startTime: startDateTime,
                    location: locationController.text.isEmpty ? null : locationController.text,
                    isEmergency: isEmergency,
                    createdBy: widget.currentUser.id,
                    memberIds: [],
                    createdAt: DateTime.now(),
                  );
                  setState(() => _events.add(event));
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
}