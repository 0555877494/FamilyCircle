import 'package:flutter/material.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';
import '../theme/app_colors.dart';
import '../widgets/connection_status.dart';
import '../models/app_settings.dart';

class AppSettingsScreen extends StatefulWidget {
  final AppSettings? initialSettings;
  final ValueChanged<AppSettings>? onSettingsChanged;
  
  const AppSettingsScreen({super.key, this.initialSettings, this.onSettingsChanged});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late AppSettings _settings;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings ?? AppSettings();
  }

  void _updateSettings(AppSettings newSettings) {
    setState(() => _settings = newSettings);
    widget.onSettingsChanged?.call(newSettings);
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return 'System';
      case ThemeMode.light: return 'Light';
      case ThemeMode.dark: return 'Dark';
    }
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('System'),
            leading: const Icon(Icons.settings_suggest),
            trailing: _settings.themeMode == ThemeMode.system ? const Icon(Icons.check) : null,
            onTap: () {
              _updateSettings(_settings.copyWith(themeMode: ThemeMode.system));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('Light'),
            leading: const Icon(Icons.light_mode),
            trailing: _settings.themeMode == ThemeMode.light ? const Icon(Icons.check) : null,
            onTap: () {
              _updateSettings(_settings.copyWith(themeMode: ThemeMode.light));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('Dark'),
            leading: const Icon(Icons.dark_mode),
            trailing: _settings.themeMode == ThemeMode.dark ? const Icon(Icons.check) : null,
            onTap: () {
              _updateSettings(_settings.copyWith(themeMode: ThemeMode.dark));
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showFontScalePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [0.8, 0.9, 1.0, 1.1, 1.2, 1.3].map((scale) {
          return ListTile(
            title: Text('${(scale * 100).toInt()}%'),
            trailing: _settings.fontScale == scale ? const Icon(Icons.check) : null,
            onTap: () {
              _updateSettings(_settings.copyWith(fontScale: scale));
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showDisplayScalePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [0.8, 0.9, 1.0, 1.1, 1.2].map((scale) {
          return ListTile(
            title: Text('${(scale * 100).toInt()}%'),
            trailing: _settings.displayScale == scale ? const Icon(Icons.check) : null,
            onTap: () {
              _updateSettings(_settings.copyWith(displayScale: scale));
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showScreenTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Enable Screen Time Limit'),
            value: _settings.screenTimeLimitEnabled,
            onChanged: (v) => _updateSettings(_settings.copyWith(screenTimeLimitEnabled: v)),
          ),
          if (_settings.screenTimeLimitEnabled) ...[
            const Divider(),
            ...[30, 60, 90, 120, 180, 240].map((minutes) {
              return ListTile(
                title: Text('${minutes ~/ 60}h${minutes % 60 > 0 ? ' ${minutes % 60}m' : ''}'),
                trailing: _settings.screenTimeLimitMinutes == minutes ? const Icon(Icons.check) : null,
                onTap: () {
                  _updateSettings(_settings.copyWith(screenTimeLimitMinutes: minutes));
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  void _showSoundPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text('Default'), leading: const Icon(Icons.music_note), onTap: () => Navigator.pop(ctx)),
          ListTile(title: const Text('Silent'), leading: const Icon(Icons.volume_off), onTap: () => Navigator.pop(ctx)),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will remove temporary files. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache cleared')));
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  List<SettingsCategory> get _categories => [
    SettingsCategory(
      title: 'Account',
      icon: Icons.person_outline,
      items: [
        SettingsItem(title: 'Profile', subtitle: 'Edit your profile info', icon: Icons.badge_outlined, onTap: () {}),
        SettingsItem(title: 'Family Members', subtitle: 'Manage family', icon: Icons.people_outline, onTap: () {}),
        SettingsItem(title: 'Privacy', subtitle: 'Control your privacy', icon: Icons.shield_outlined, onTap: () {}),
        SettingsItem(title: 'Security', subtitle: 'Password & security', icon: Icons.lock_outline, onTap: () {}),
      ],
    ),
    SettingsCategory(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      items: [
        SettingsItem(
          title: 'Push Notifications', 
          subtitle: _settings.notificationsEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.notifications_active_outlined, 
          trailing: Switch(
            value: _settings.notificationsEnabled,
            onChanged: (v) => _updateSettings(_settings.copyWith(notificationsEnabled: v)),
          ),
          onTap: () {},
        ),
        SettingsItem(
          title: 'Email Notifications', 
          subtitle: _settings.emailNotificationsEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.email_outlined, 
          trailing: Switch(
            value: _settings.emailNotificationsEnabled,
            onChanged: (v) => _updateSettings(_settings.copyWith(emailNotificationsEnabled: v)),
          ),
          onTap: () {},
        ),
        SettingsItem(
          title: 'SMS Alerts', 
          subtitle: _settings.smsAlertsEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.sms_outlined, 
          trailing: Switch(
            value: _settings.smsAlertsEnabled,
            onChanged: (v) => _updateSettings(_settings.copyWith(smsAlertsEnabled: v)),
          ),
          onTap: () {},
        ),
        SettingsItem(title: 'Sound', subtitle: 'Notification sounds', icon: Icons.volume_up_outlined, onTap: _showSoundPicker),
      ],
    ),
    SettingsCategory(
      title: 'Appearance',
      icon: Icons.palette_outlined,
      items: [
        SettingsItem(title: 'Theme', subtitle: _getThemeLabel(_settings.themeMode), icon: Icons.dark_mode_outlined, onTap: _showThemePicker),
        SettingsItem(title: 'Font Size', subtitle: '${(_settings.fontScale * 100).toInt()}%', icon: Icons.text_fields, onTap: _showFontScalePicker),
        SettingsItem(title: 'Display Size', subtitle: '${(_settings.displayScale * 100).toInt()}%', icon: Icons.aspect_ratio, onTap: _showDisplayScalePicker),
        SettingsItem(
          title: 'Kid Mode', 
          subtitle: _settings.kidModeEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.child_care, 
          trailing: Switch(
            value: _settings.kidModeEnabled,
            onChanged: (v) => _updateSettings(_settings.copyWith(kidModeEnabled: v)),
          ),
          onTap: () {},
        ),
      ],
    ),
    SettingsCategory(
      title: 'Family',
      icon: Icons.family_restroom,
      items: [
        SettingsItem(title: 'Family Rules', subtitle: 'Manage family rules', icon: Icons.rule_folder, onTap: () {}),
        SettingsItem(
          title: 'Safe Zones', 
          subtitle: _settings.safeZonesEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.location_on_outlined, 
          trailing: Switch(
            value: _settings.safeZonesEnabled,
            onChanged: (v) => _updateSettings(_settings.copyWith(safeZonesEnabled: v)),
          ),
          onTap: () {},
        ),
        SettingsItem(
          title: 'Screen Time', 
          subtitle: _settings.screenTimeLimitEnabled ? _settings.formattedScreenTime : 'Disabled', 
          icon: Icons.timer_outlined, 
          onTap: _showScreenTimePicker,
        ),
        SettingsItem(
          title: 'Content Filters', 
          subtitle: _settings.contentFilterEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.filter_alt_outlined, 
          trailing: Switch(
            value: _settings.contentFilterEnabled,
            onChanged: (v) => _updateSettings(_settings.copyWith(contentFilterEnabled: v)),
          ),
          onTap: () {},
        ),
      ],
    ),
    SettingsCategory(
      title: 'Communication',
      icon: Icons.chat_bubble_outline,
      items: [
        SettingsItem(title: 'Chat Settings', subtitle: 'Message preferences', icon: Icons.chat_outlined, onTap: () {}),
        SettingsItem(title: 'Video Calls', subtitle: 'Call preferences', icon: Icons.videocam_outlined, onTap: () {}),
        SettingsItem(title: 'Group Messaging', subtitle: 'Group settings', icon: Icons.groups_outlined, onTap: () {}),
        SettingsItem(title: 'Check-ins', subtitle: 'Location check-in settings', icon: Icons.check_circle_outline, onTap: () {}),
        SettingsItem(
          title: 'Location Sharing', 
          subtitle: _settings.locationSharingEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.share_location, 
          trailing: Switch(
            value: _settings.locationSharingEnabled,
            onChanged: (v) => _updateSettings(_settings.copyWith(locationSharingEnabled: v)),
          ),
          onTap: () {},
        ),
        SettingsItem(
          title: 'Emergency Broadcast', 
          subtitle: _settings.emergencyBroadcastEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.warning_amber, 
          trailing: Switch(
            value: _settings.emergencyBroadcastEnabled,
            onChanged: (v) => _updateSettings(_settings.copyWith(emergencyBroadcastEnabled: v)),
          ),
          onTap: () {},
        ),
      ],
    ),
    SettingsCategory(
      title: 'Storage & Data',
      icon: Icons.storage_outlined,
      items: [
        SettingsItem(title: 'Data Usage', subtitle: 'View data usage', icon: Icons.data_usage, onTap: () {}),
        SettingsItem(title: 'Clear Cache', subtitle: 'Free up space', icon: Icons.cleaning_services_outlined, onTap: _clearCache),
        SettingsItem(title: 'Backup', subtitle: 'Backup your data', icon: Icons.backup_outlined, onTap: () {}),
        SettingsItem(title: 'Export Data', subtitle: 'Export your data', icon: Icons.download_outlined, onTap: () {}),
      ],
    ),
    SettingsCategory(
      title: 'Help & Support',
      icon: Icons.help_outline,
      items: [
        SettingsItem(title: 'Help Center', subtitle: 'Get help', icon: Icons.help_center, onTap: () {}),
        SettingsItem(title: 'Send Feedback', subtitle: 'Send feedback to us', icon: Icons.feedback_outlined, onTap: () {}),
        SettingsItem(title: 'Report a Problem', subtitle: 'Report issues', icon: Icons.bug_report_outlined, onTap: () {}),
        SettingsItem(title: 'Privacy Policy', subtitle: 'View privacy policy', icon: Icons.privacy_tip_outlined, onTap: () {}),
      ],
    ),
    SettingsCategory(
      title: 'About',
      icon: Icons.info_outline,
      items: [
        SettingsItem(title: 'App Version', subtitle: '1.0.0', icon: Icons.new_releases_outlined, onTap: () {}),
        SettingsItem(title: 'Terms of Service', subtitle: 'View terms', icon: Icons.description_outlined, onTap: () {}),
        SettingsItem(title: 'Open Source Licenses', subtitle: 'View licenses', icon: Icons.code, onTap: () {}),
        SettingsItem(title: 'Developer Options', subtitle: 'Dev settings', icon: Icons.developer_mode, onTap: () {}),
      ],
    ),
  ];

  List<SettingsCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories.map((cat) {
      final filteredItems = cat.items.where((item) =>
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.subtitle?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false));
      if (filteredItems.isEmpty) return null;
      return SettingsCategory(
        title: cat.title,
        icon: cat.icon,
        items: filteredItems.toList(),
      );
    }).whereType<SettingsCategory>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: AutoScrollContainer(
                alwaysScroll: true,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (ctx, i) => _buildCategorySection(_filteredCategories[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity( 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search settings...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(SettingsCategory category) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(category.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  category.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...category.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                InkWell(
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(item.icon, color: Colors.grey.shade600, size: 22),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                              if (item.subtitle != null)
                                Text(item.subtitle!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            ],
                          ),
                        ),
                        if (item.trailing != null)
                          item.trailing!
                        else
                          Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
                if (index < category.items.length - 1)
                  Divider(height: 1, indent: 54),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class SettingsCategory {
  final String title;
  final IconData icon;
  final List<SettingsItem> items;

  SettingsCategory({required this.title, required this.icon, required this.items});
}

class SettingsItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  SettingsItem({required this.title, this.subtitle, required this.icon, this.trailing, this.onTap});
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSettingsScreen();
  }
}