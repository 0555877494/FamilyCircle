import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';
import '../theme/app_colors.dart';
import '../widgets/connection_status.dart';
import '../widgets/skeleton_loader.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'privacy_security_screen.dart';
import 'chat_settings_screen.dart';
import 'video_call_settings_screen.dart';
import 'family_members_screen.dart';
import 'data_usage_screen.dart';
import 'accessibility_screen.dart';
import 'safe_zones_screen.dart';
import 'family_rules_screen.dart';
import 'check_ins_screen.dart';
import 'parental_controls_screen.dart';
import 'group_messaging_screen.dart';
import 'backup_screen.dart';
import 'export_data_screen.dart';
import 'help_center_screen.dart';
import 'feedback_screen.dart';
import 'report_problem_screen.dart';
import 'terms_of_service_screen.dart';
import 'licenses_screen.dart';

class AppSettingsScreen extends StatefulWidget {
  final AppSettings? initialSettings;
  final ValueChanged<AppSettings>? onSettingsChanged;
  
  const AppSettingsScreen({super.key, this.initialSettings, this.onSettingsChanged});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  AppSettings? _settings;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _settingsService = SettingsService();
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.loadSettings();
    setState(() => _settings = settings);
  }

  Future<void> _updateSettings(AppSettings newSettings) async {
    setState(() => _settings = newSettings);
    widget.onSettingsChanged?.call(newSettings);
    await _settingsService.saveSettings(newSettings);
    await Vibration.vibrate(duration: 10);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings updated'), duration: Duration(seconds: 1)),
      );
    }
  }

  String _getThemeLabel(ThemeMode? mode) {
    if (mode == null) return 'System';
    switch (mode) {
      case ThemeMode.light: return 'Light';
      case ThemeMode.dark: return 'Dark';
      default: return 'System';
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
            trailing: _settings!.themeMode == ThemeMode.system ? const Icon(Icons.check) : null,
            onTap: () {
              _updateSettings(_settings!.copyWith(themeMode: ThemeMode.system));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('Light'),
            leading: const Icon(Icons.light_mode),
            trailing: _settings!.themeMode == ThemeMode.light ? const Icon(Icons.check) : null,
            onTap: () {
              _updateSettings(_settings!.copyWith(themeMode: ThemeMode.light));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('Dark'),
            leading: const Icon(Icons.dark_mode),
            trailing: _settings!.themeMode == ThemeMode.dark ? const Icon(Icons.check) : null,
            onTap: () {
              _updateSettings(_settings!.copyWith(themeMode: ThemeMode.dark));
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
            trailing: _settings!.fontScale == scale ? const Icon(Icons.check) : null,
            onTap: () {
              _updateSettings(_settings!.copyWith(fontScale: scale));
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
            trailing: _settings!.displayScale == scale ? const Icon(Icons.check) : null,
            onTap: () {
              _updateSettings(_settings!.copyWith(displayScale: scale));
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
            value: _settings!.screenTimeLimitEnabled,
            onChanged: (v) => _updateSettings(_settings!.copyWith(screenTimeLimitEnabled: v)),
          ),
          if (_settings!.screenTimeLimitEnabled) ...[
            const Divider(),
            ...[30, 60, 90, 120, 180, 240].map((minutes) {
              return ListTile(
                title: Text('${minutes ~/ 60}h${minutes % 60 > 0 ? ' ${minutes % 60}m' : ''}'),
                trailing: _settings!.screenTimeLimitMinutes == minutes ? const Icon(Icons.check) : null,
                onTap: () {
                  _updateSettings(_settings!.copyWith(screenTimeLimitMinutes: minutes));
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
        SettingsItem(title: 'Profile', subtitle: 'Edit your profile info', icon: Icons.badge_outlined, onTap: () async {
          final userId = await _authService.getCurrentUserId();
          if (userId != null && mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId)));
          }
        }),
        SettingsItem(title: 'Family Members', subtitle: 'Manage family', icon: Icons.people_outline, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FamilyMembersScreen()));
        }),
        SettingsItem(title: 'Privacy', subtitle: 'Control your privacy', icon: Icons.shield_outlined, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()));
        }),
        SettingsItem(title: 'Security', subtitle: 'Password & security', icon: Icons.lock_outline, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()));
        }),
      ],
    ),
    SettingsCategory(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      items: [
        SettingsItem(
          title: 'Push Notifications', 
          subtitle: _settings!.notificationsEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.notifications_active_outlined, 
          trailing: Switch(
            value: _settings!.notificationsEnabled,
            onChanged: (v) => _updateSettings(_settings!.copyWith(notificationsEnabled: v)),
          ),
          onTap: () {},
        ),
        SettingsItem(
          title: 'Email Notifications', 
          subtitle: _settings!.emailNotificationsEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.email_outlined, 
          trailing: Switch(
            value: _settings!.emailNotificationsEnabled,
            onChanged: (v) => _updateSettings(_settings!.copyWith(emailNotificationsEnabled: v)),
          ),
          onTap: () {},
        ),
        SettingsItem(
          title: 'SMS Alerts', 
          subtitle: _settings!.smsAlertsEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.sms_outlined, 
          trailing: Switch(
            value: _settings!.smsAlertsEnabled,
            onChanged: (v) => _updateSettings(_settings!.copyWith(smsAlertsEnabled: v)),
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
        SettingsItem(title: 'Theme', subtitle: _getThemeLabel(_settings!.themeMode), icon: Icons.dark_mode_outlined, onTap: _showThemePicker),
        SettingsItem(title: 'Font Size', subtitle: '${(_settings!.fontScale * 100).toInt()}%', icon: Icons.text_fields, onTap: _showFontScalePicker),
        SettingsItem(title: 'Display Size', subtitle: '${(_settings!.displayScale * 100).toInt()}%', icon: Icons.aspect_ratio, onTap: _showDisplayScalePicker),
        SettingsItem(
          title: 'Data Saver',
          subtitle: _settings!.dataSaverMode ? 'Enabled' : 'Disabled',
          icon: Icons.data_usage,
          trailing: Switch(
            value: _settings!.dataSaverMode,
            onChanged: (v) => _updateSettings(_settings!.copyWith(dataSaverMode: v)),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Data Saver'),
                content: const Text('Reduces data usage by loading lower quality images and disabling auto-play videos. Useful when on metered connections.'),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it'))],
              ),
            );
          },
        ),
        SettingsItem(
          title: 'Notifications', 
          subtitle: _settings!.notificationsEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.notifications_outlined, 
          trailing: Switch(
            value: _settings!.notificationsEnabled,
            onChanged: (v) => _updateSettings(_settings!.copyWith(notificationsEnabled: v)),
          ),
          onTap: () {},
        ),
        SettingsItem(title: 'Accessibility', subtitle: 'Accessibility options', icon: Icons.accessibility_outlined, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessibilityScreen()));
        }),
      ],
    ),
    SettingsCategory(
      title: 'Family',
      icon: Icons.family_restroom,
      items: [
        SettingsItem(title: 'Family Rules', subtitle: 'Manage family rules', icon: Icons.rule_folder, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FamilyRulesScreen()));
        }),
        SettingsItem(
          title: 'Safe Zones', 
          subtitle: _settings!.safeZonesEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.location_on_outlined, 
          trailing: Switch(
            value: _settings!.safeZonesEnabled,
            onChanged: (v) => _updateSettings(_settings!.copyWith(safeZonesEnabled: v)),
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SafeZonesScreen()));
          },
        ),
        SettingsItem(
          title: 'Screen Time', 
          subtitle: _settings!.screenTimeLimitEnabled ? _settings!.formattedScreenTime : 'Disabled', 
          icon: Icons.timer_outlined, 
          onTap: _showScreenTimePicker,
        ),
        SettingsItem(
          title: 'Content Filters', 
          subtitle: _settings!.contentFilterEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.filter_alt_outlined, 
          trailing: Switch(
            value: _settings!.contentFilterEnabled,
            onChanged: (v) => _updateSettings(_settings!.copyWith(contentFilterEnabled: v)),
          ),
          onTap: () {},
        ),
        SettingsItem(title: 'Check-ins', subtitle: 'Location check-in settings', icon: Icons.check_circle_outline, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckInsScreen()));
        }),
      ],
    ),
    SettingsCategory(
      title: 'Parental Controls',
      icon: Icons.admin_panel_settings,
      items: [
        SettingsItem(
          title: 'Screen Time & Bedtime',
          subtitle: _settings!.screenTimeLimitEnabled ? _settings!.formattedScreenTime : 'Disabled',
          icon: Icons.bedtime_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ParentalControlsScreen(
                  familyId: 'current_family_id',
                  memberId: 'current_user_id',
                ),
              ),
            );
          },
        ),
        SettingsItem(
          title: 'Content Filtering',
          subtitle: _settings!.contentFilterEnabled ? 'Enabled' : 'Disabled',
          icon: Icons.filter_alt_outlined,
          trailing: Switch(
            value: _settings!.contentFilterEnabled,
            onChanged: (v) => _updateSettings(_settings!.copyWith(contentFilterEnabled: v)),
          ),
          onTap: () {},
        ),
        SettingsItem(
          title: 'Safe Zones',
          subtitle: _settings!.safeZonesEnabled ? 'Enabled' : 'Disabled',
          icon: Icons.location_on_outlined,
          trailing: Switch(
            value: _settings!.safeZonesEnabled,
            onChanged: (v) => _updateSettings(_settings!.copyWith(safeZonesEnabled: v)),
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SafeZonesScreen()));
          },
        ),
      ],
    ),
    SettingsCategory(
      title: 'Communication',
      icon: Icons.chat_bubble_outline,
      items: [
        SettingsItem(title: 'Chat Settings', subtitle: 'Message preferences', icon: Icons.chat_outlined, onTap: () {
          if (_settings != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatSettingsScreen(settings: _settings!)));
          }
        }),
        SettingsItem(title: 'Video Calls', subtitle: 'Call preferences', icon: Icons.videocam_outlined, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoCallSettingsScreen()));
        }),
        SettingsItem(title: 'Group Messaging', subtitle: 'Group settings', icon: Icons.groups_outlined, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupMessagingScreen()));
        }),
        SettingsItem(
          title: 'Location Sharing', 
          subtitle: _settings!.locationSharingEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.share_location, 
          trailing: Switch(
            value: _settings!.locationSharingEnabled,
            onChanged: (v) => _updateSettings(_settings!.copyWith(locationSharingEnabled: v)),
          ),
          onTap: () {},
        ),
        SettingsItem(
          title: 'Emergency Broadcast', 
          subtitle: _settings!.emergencyBroadcastEnabled ? 'Enabled' : 'Disabled', 
          icon: Icons.warning_amber, 
          trailing: Switch(
            value: _settings!.emergencyBroadcastEnabled,
            onChanged: (v) => _updateSettings(_settings!.copyWith(emergencyBroadcastEnabled: v)),
          ),
          onTap: () {},
        ),
      ],
    ),
    SettingsCategory(
      title: 'Storage & Data',
      icon: Icons.storage_outlined,
      items: [
        SettingsItem(title: 'Data Usage', subtitle: 'View data usage', icon: Icons.data_usage, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DataUsageScreen()));
        }),
        SettingsItem(title: 'Clear Cache', subtitle: 'Free up space', icon: Icons.cleaning_services_outlined, onTap: _clearCache),
        SettingsItem(title: 'Backup', subtitle: 'Backup your data', icon: Icons.backup_outlined, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
        }),
        SettingsItem(title: 'Export Data', subtitle: 'Export your data', icon: Icons.download_outlined, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportDataScreen()));
        }),
      ],
    ),
    SettingsCategory(
      title: 'Help & Support',
      icon: Icons.help_outline,
      items: [
        SettingsItem(title: 'Help Center', subtitle: 'Get help', icon: Icons.help_center, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
        }),
        SettingsItem(title: 'Send Feedback', subtitle: 'Send feedback to us', icon: Icons.feedback_outlined, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen()));
        }),
        SettingsItem(title: 'Report a Problem', subtitle: 'Report issues', icon: Icons.bug_report_outlined, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportProblemScreen()));
        }),
        SettingsItem(title: 'Privacy Policy', subtitle: 'View privacy policy', icon: Icons.privacy_tip_outlined, onTap: () {}),
      ],
    ),
    SettingsCategory(
      title: 'About',
      icon: Icons.info_outline,
      items: [
        SettingsItem(title: 'App Version', subtitle: '1.0.0', icon: Icons.new_releases_outlined, onTap: () {}),
        SettingsItem(title: 'Terms of Service', subtitle: 'View terms', icon: Icons.description_outlined, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()));
        }),
        SettingsItem(title: 'Open Source Licenses', subtitle: 'View licenses', icon: Icons.code, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LicensesScreen()));
        }),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to Defaults',
            onPressed: _showResetDialog,
          ),
          const Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _filteredCategories.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        final settings = await _settingsService.loadSettings();
                        setState(() => _settings = settings);
                      },
                      child: _settings == null
                          ? const SettingsSkeleton()
                          : AutoScrollContainer(
                              alwaysScroll: true,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredCategories.length,
                                itemBuilder: (ctx, i) => _buildCategorySection(_filteredCategories[i]),
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No settings found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Reset all settings to default values? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              setState(() => _settings = AppSettings());
              await _settingsService.resetSettings();
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset to defaults')),
                );
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
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
              color: Colors.black.withValues(alpha: 0.05),
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
