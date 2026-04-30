import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';

class GroupMessagingScreen extends StatefulWidget {
  const GroupMessagingScreen({super.key});

  @override
  State<GroupMessagingScreen> createState() => _GroupMessagingScreenState();
}

class _GroupMessagingScreenState extends State<GroupMessagingScreen> {
  final List<GroupSettings> _groups = [
    GroupSettings(id: 'group_001', name: 'Parents', memberCount: 2, isMuted: false),
    GroupSettings(id: 'group_002', name: 'Kids', memberCount: 3, isMuted: true),
    GroupSettings(id: 'group_003', name: 'Everyone', memberCount: 5, isMuted: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Group Messaging', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: Text('General Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile('Allow Group Creation', 'Let members create new groups', Icons.group_add, true, (v) {}),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile('Group Invites', 'Allow invites to groups', Icons.mail_outline, true, (v) {}),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile('Join Requests', 'Require approval to join', Icons.how_to_reg, false, (v) {}),
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
                    child: Text('Your Groups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  ..._groups.asMap().entries.map((entry) {
                    final index = entry.key;
                    final group = entry.value;
                    return Column(
                      children: [
                        _buildGroupTile(group),
                        if (index < _groups.length - 1) const Divider(height: 1, indent: 54),
                      ],
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
                    child: Text('Group Defaults', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile('History', 'Save message history', Icons.history, true, (v) {}),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile('Media Visibility', 'Show media in groups', Icons.photo_library_outlined, true, (v) {}),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile('Link Previews', 'Show previews for links', Icons.link, true, (v) {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupTile(GroupSettings group) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Text(group.name.substring(0, 1), style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ),
      title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${group.memberCount} members', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(group.isMuted ? Icons.volume_off : Icons.volume_up),
            color: Colors.grey.shade600,
            onPressed: () {
              setState(() {
                final index = _groups.indexWhere((g) => g.id == group.id);
                if (index != -1) {
                  _groups[index] = GroupSettings(
                    id: group.id,
                    name: group.name,
                    memberCount: group.memberCount,
                    isMuted: !group.isMuted,
                  );
                }
              });
            },
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.all(16),
      secondary: Icon(icon, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class GroupSettings {
  final String id;
  final String name;
  final int memberCount;
  final bool isMuted;

  GroupSettings({required this.id, required this.name, required this.memberCount, required this.isMuted});
}
