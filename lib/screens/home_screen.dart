import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../models/family_group.dart';
import '../models/calendar_event.dart';
import '../models/family.dart';
import '../services/family_service.dart';
import '../services/chat_service.dart';
import '../services/calendar_service.dart';
import '../services/media_service.dart';
import '../services/parental_service.dart';
import '../models/parental_settings.dart';
import '../services/auth_service.dart';
import '../services/connection_service.dart';
import '../services/bluetooth_service.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/connection_status.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import 'family_detail_screen.dart';
import 'family_tasks_screen.dart';
import 'family_rules_screen.dart';
import 'family_budget_screen.dart';
import 'family_health_screen.dart';
import 'activity_log_screen.dart';
import 'safe_zones_screen.dart';
import 'video_call_screen.dart';
import 'check_ins_screen.dart';
import 'family_notes_screen.dart';
import 'reminders_screen.dart';
import 'emergency_contacts_screen.dart';
import 'family_tree_screen.dart';
import 'family_calendar_screen.dart';
import 'properties_screen.dart';
import 'legacy_screen.dart';
import 'family_projects_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<FamilyGroup> _groups = [];
  DateTime _selectedDay = DateTime.now();
  List<CalendarEvent> _eventsForDay = [];
  
  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    try {
      final chatService = context.read<ChatService>();
      chatService.getFamilyGroupsStream(widget.currentUser.familyId).listen((groups) {
        if (mounted) setState(() => _groups = groups);
      });
    } catch (e) {
      _groups = [
        FamilyGroup(
          id: '1', familyId: widget.currentUser.familyId, name: 'Parents',
          type: GroupType.parents, memberIds: [], createdAt: DateTime.now(),
        ),
        FamilyGroup(
          id: '2', familyId: widget.currentUser.familyId, name: 'Kids',
          type: GroupType.kids, memberIds: [], createdAt: DateTime.now(),
        ),
        FamilyGroup(
          id: '3', familyId: widget.currentUser.familyId, name: 'Everyone',
          type: GroupType.everyone, memberIds: [], createdAt: DateTime.now(),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUser.isKidMode) {
      return _buildKidMode();
    }
    return _buildNormalMode();
  }

  Widget _buildKidMode() {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  widget.currentUser.firstName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 40, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hi ${widget.currentUser.firstName}!',
                style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 48),
              _buildKidButton(Icons.chat, 'Message Family', 0),
              const SizedBox(height: 24),
              _buildKidButton(Icons.photo_library, 'See Pictures', 2),
              const SizedBox(height: 24),
              _buildKidButton(Icons.calendar_today, 'Calendar', 1),
              const SizedBox(height: 24),
              _buildKidButton(Icons.phone, 'Call Parent', _groups.isNotEmpty ? 4 : 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKidButton(IconData icon, String label, int index) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 32),
        label: Text(label, style: const TextStyle(fontSize: 20)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildNormalMode() {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildChatTab(),
          _buildCalendarTab(),
          _buildMediaTab(),
          _buildFamilyTab(),
          _buildTasksTab(),
          _buildBudgetTab(),
          _buildHealthTab(),
          _buildProjectsTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Media'),
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: 'Family'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildMediaTab() {
    return MediaHomeScreen(currentUser: widget.currentUser);
  }

  Widget _buildFamilyTab() {
    return FamilyManageScreen(currentUser: widget.currentUser);
  }

  Widget _buildTasksTab() {
    return FamilyTasksScreen(currentUser: widget.currentUser);
  }

  Widget _buildBudgetTab() {
    return FamilyBudgetScreen(currentUser: widget.currentUser);
  }

  Widget _buildHealthTab() {
    return FamilyHealthScreen(currentUser: widget.currentUser);
  }

  Widget _buildProjectsTab() {
    return FamilyProjectsScreen(currentUser: widget.currentUser);
  }

  Widget _buildSettingsTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: Text(widget.currentUser.firstName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: widget.currentUser.id),
                ),
              );
            },
          ),
          const Divider(),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode),
          title: const Text('Dark Mode'),
          value: false,
          onChanged: (v) {},
        ),
        SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          value: true,
          onChanged: (v) {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Privacy'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.logout, color: Colors.red),
          title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    ),
  );
}

Widget _buildChatTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Chat'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: ConnectionStatusIndicator(),
          ),
        ],
      ),
      body: _groups.isEmpty 
          ? const Center(child: Text('No family groups yet'))
          : ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (ctx, i) => _buildGroupTile(_groups[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmergencyBroadcast(),
        backgroundColor: Colors.red,
        child: const Icon(Icons.warning, color: Colors.white),
      ),
    );
  }

  void _showEmergencyBroadcast() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emergency Broadcast'),
        content: const Text('Send an alert to all family members?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency alert sent!')),
              );
            },
            child: const Text('Send', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTile(FamilyGroup group) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor,
        child: Text(group.name[0], style: const TextStyle(color: Colors.white)),
      ),
      title: Text(group.name),
      subtitle: Text(group.type.name.toUpperCase()),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(group: group, currentUser: widget.currentUser),
          ),
        );
      },
    );
}

Widget _buildCalendarTab() {
  return Scaffold(
    appBar: AppBar(title: const Text('Calendar')),
    body: Column(
      children: [
        _buildSimpleCalendar(),
        const Divider(),
        Expanded(
          child: _eventsForDay.isEmpty
              ? const Center(child: Text('No events for this day'))
              : ListView.builder(
                  itemCount: _eventsForDay.length,
                  itemBuilder: (ctx, i) => _buildEventTile(_eventsForDay[i]),
                ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _showAddEventDialog(),
      child: const Icon(Icons.add),
    ),
  );
}

Widget _buildSimpleCalendar() {
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final firstDayWeekday = DateTime(now.year, now.month, 1).weekday;
  
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text(
          '${['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][now.month - 1]} ${now.year}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((d) => Text(d, style: TextStyle(color: Colors.grey[600], fontSize: 12)))
              .toList(),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(daysInMonth + firstDayWeekday - 1, (i) {
            if (i < firstDayWeekday - 1) return const SizedBox(width: 40, height: 40);
            final day = i - firstDayWeekday + 2;
            final isToday = day == now.day;
            return GestureDetector(
              onTap: () {},
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday ? AppTheme.primaryColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.black,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    ),
  );
}

  Widget _buildEventTile(CalendarEvent event) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: event.isEmergency ? Colors.red : AppTheme.primaryColor,
        child: Icon(
          event.isEmergency ? Icons.warning : Icons.event,
          color: Colors.white, size: 20,
        ),
      ),
      title: Text(event.title),
      subtitle: Text('${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}'),
      trailing: event.location != null ? const Icon(Icons.location_on) : null,
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final event = CalendarEvent(
                  id: const Uuid().v4(),
                  familyId: widget.currentUser.familyId,
                  title: titleController.text,
                  startTime: _selectedDay,
                  createdBy: widget.currentUser.id,
                  memberIds: [],
                  createdAt: DateTime.now(),
                );
                try {
                  context.read<CalendarService>().createEvent(event);
                } catch (e) {}
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class MediaHomeScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const MediaHomeScreen({super.key, required this.currentUser});

  @override
  State<MediaHomeScreen> createState() => _MediaHomeScreenState();
}

class _MediaHomeScreenState extends State<MediaHomeScreen> {
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Albums'), actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ]),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4,
        ),
        itemCount: 12,
        itemBuilder: (ctx, i) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.photo, size: 40, color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadOptions,
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              try {
                context.read<MediaService>().pickAndUploadImage(
                  widget.currentUser.familyId,
                  widget.currentUser.id,
                  widget.currentUser.firstName,
                );
              } catch (e) {}
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () {
              try {
                context.read<MediaService>().captureAndUploadImage(
                  widget.currentUser.familyId,
                  widget.currentUser.id,
                  widget.currentUser.firstName,
                );
              } catch (e) {}
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Record Video'),
            onTap: () {
              try {
                context.read<MediaService>().pickAndUploadVideo(
                  widget.currentUser.familyId,
                  widget.currentUser.id,
                  widget.currentUser.firstName,
                );
              } catch (e) {}
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class FamilyManageScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const FamilyManageScreen({super.key, required this.currentUser});

  @override
  State<FamilyManageScreen> createState() => _FamilyManageScreenState();
}

class _FamilyManageScreenState extends State<FamilyManageScreen> {
  Family? _family;
  
  @override
  void initState() {
    super.initState();
    _loadFamily();
  }

  void _loadFamily() {
    try {
      final familyService = context.read<FamilyService>();
      familyService.getFamilyStream(widget.currentUser.familyId).listen((family) {
        if (mounted && family != null) {
          setState(() => _family = family);
        }
      });
    } catch (e) {
      _family = Family(
        id: widget.currentUser.familyId,
        name: 'My Family',
        createdBy: widget.currentUser.id,
        members: [widget.currentUser],
        createdAt: widget.currentUser.createdAt,
      );
    }
  }

  void _navigateToFamilyDetail(BuildContext context) {
    if (_family != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FamilyDetailScreen(family: _family!, currentUser: widget.currentUser),
        ),
      );
    }
  }
  
@override
  Widget build(BuildContext context) {
    final isParent = widget.currentUser.role == UserRole.parent || widget.currentUser.role == UserRole.admin;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Family'), actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ]),
      body: ListView(
        children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _navigateToFamilyDetail(context),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  widget.currentUser.firstName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                widget.currentUser.firstName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => _navigateToFamilyDetail(context),
                child: const Text('View Family Details'),
              ),
            ),
            Center(
              child: Text(
                widget.currentUser.role.name.toUpperCase(),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: Text('Tasks & Chores'),
              subtitle: Text('Manage family tasks'),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => FamilyTasksScreen(currentUser: widget.currentUser),
              )),
            ),
            ListTile(
              leading: const Icon(Icons.rule),
              title: Text('Family Rules'),
              subtitle: Text('House rules and boundaries'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => FamilyRulesScreen(currentUser: widget.currentUser),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Budget'),
            subtitle: const Text('Family expenses'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => FamilyBudgetScreen(currentUser: widget.currentUser),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Health'),
            subtitle: const Text('Health records & medications'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => FamilyHealthScreen(currentUser: widget.currentUser),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('Activity Log'),
            subtitle: const Text('Track activities'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ActivityLogScreen(currentUser: widget.currentUser),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Safe Zones'),
            subtitle: const Text('Location alerts'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => SafeZonesScreen(currentUser: widget.currentUser),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.video_call),
            title: const Text('Video Calls'),
            subtitle: const Text('Call family members'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => VideoCallScreen(currentUser: widget.currentUser),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Check-ins'),
            subtitle: const Text('Safety check-ins'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => CheckInsScreen(currentUser: widget.currentUser),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Journal'),
            subtitle: const Text('Family notes & memories'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => FamilyNotesScreen(currentUser: widget.currentUser),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text('Reminders'),
            subtitle: const Text('Set reminders'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => RemindersScreen(currentUser: widget.currentUser),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.contact_phone),
            title: const Text('Emergency Contacts'),
            subtitle: const Text('Emergency contacts list'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => EmergencyContactsScreen(currentUser: widget.currentUser),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.account_tree),
            title: const Text('Family Tree'),
            subtitle: const Text('Visual family tree'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => FamilyTreeScreenWrapper(
                currentUser: widget.currentUser,
                members: _family?.members ?? [],
                kinshipTies: _family?.kinshipTies ?? [],
              ),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Properties'),
            subtitle: const Text('Track assets & accounts'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => PropertiesScreen(currentUser: widget.currentUser),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.auto_stories),
            title: const Text('Family Legacy'),
            subtitle: const Text('History, deaths, weddings, heirlooms'),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => LegacyScreen(currentUser: widget.currentUser),
            )),
          ),
          if (isParent) ...[
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Invite Member'),
              subtitle: const Text('Share invite code with family'),
              onTap: () => _showInviteDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Parental Controls'),
              subtitle: const Text('Manage screen time and content'),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ParentalControlsScreen(currentUser: widget.currentUser),
              )),
            ),
            ListTile(
              leading: const Icon(Icons.group_remove),
              title: const Text('Remove Member'),
              subtitle: const Text('Remove a family member'),
              onTap: () {},
            ),
          ],
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Leave Family'),
            subtitle: const Text('Leave this family group'),
            onTap: () => _showLeaveDialog(context),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite Family Member'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share this code with your family member:'),
            SizedBox(height: 16),
            Text('ABC123', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Family'),
        content: const Text('Are you sure you want to leave this family?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ParentalControlsScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const ParentalControlsScreen({super.key, required this.currentUser});

  @override
  State<ParentalControlsScreen> createState() => _ParentalControlsScreenState();
}

class _ParentalControlsScreenState extends State<ParentalControlsScreen> {
  bool _screenTimeEnabled = true;
  int _screenTimeLimit = 120;
  int _bedtimeHour = 21;
  bool _contentFilterEnabled = true;
  bool _locationSharingEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parental Controls'), actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ]),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Child Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Screen Time Limit'),
            subtitle: Text('${_screenTimeLimit ~/ 60}h ${_screenTimeLimit % 60}m per day'),
            value: _screenTimeEnabled,
            onChanged: (v) => setState(() => _screenTimeEnabled = v),
          ),
          ListTile(
            title: const Text('Bedtime'),
            subtitle: Text('${_bedtimeHour}:00'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          SwitchListTile(
            title: const Text('Content Filter'),
            subtitle: const Text('Block inappropriate content'),
            value: _contentFilterEnabled,
            onChanged: (v) => setState(() => _contentFilterEnabled = v),
          ),
          SwitchListTile(
            title: const Text('Location Sharing'),
            subtitle: const Text('Allow location tracking'),
            value: _locationSharingEnabled,
            onChanged: (v) => setState(() => _locationSharingEnabled = v),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    try {
      final parentalService = context.read<ParentalService>();
      final settings = ParentalSettings(
        screenTimeEnabled: _screenTimeEnabled,
        screenTimeLimitMinutes: _screenTimeLimit,
        bedtimeHour: _bedtimeHour,
        bedtimeMinute: 0,
        contentFilterEnabled: _contentFilterEnabled,
        locationSharingEnabled: _locationSharingEnabled,
      );
      parentalService.saveSettings(
        widget.currentUser.familyId,
        widget.currentUser.id,
        settings,
      );
    } catch (e) {}
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved!')));
  }
}

class SettingsHomeScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const SettingsHomeScreen({super.key, required this.currentUser});

  @override
  State<SettingsHomeScreen> createState() => _SettingsHomeScreenState();
}

class _SettingsHomeScreenState extends State<SettingsHomeScreen> {
  bool _kidMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ]),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(widget.currentUser.firstName),
            subtitle: const Text('Edit profile'),
            onTap: () {},
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Kid Mode'),
            subtitle: const Text('Simplified interface'),
            value: _kidMode,
            onChanged: (v) => setState(() => _kidMode = v),
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Push notifications'),
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacy'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () => _signOut(),
          ),
        ],
      ),
    );
  }

  void _signOut() {
    try {
      context.read<AuthService>().signOut();
    } catch (e) {}
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}