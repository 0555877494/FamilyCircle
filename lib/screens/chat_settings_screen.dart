import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';
import '../models/app_settings.dart';

class ChatSettingsScreen extends StatefulWidget {
  final AppSettings settings;

  const ChatSettingsScreen({super.key, required this.settings});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  late AppSettings _settings;
  final _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await _prefs;
    setState(() {
      _settings = AppSettings(
        readReceiptsEnabled: prefs.getBool('chat_read_receipts') ?? true,
        typingIndicatorsEnabled: prefs.getBool('chat_typing_indicators') ?? true,
        onlineStatusEnabled: prefs.getBool('chat_online_status') ?? true,
        autoDownloadMedia: prefs.getBool('chat_auto_download') ?? true,
        highQualityImages: prefs.getBool('chat_high_quality') ?? false,
        autoPlayVideos: prefs.getBool('chat_auto_play') ?? false,
        notificationsEnabled: prefs.getBool('chat_notifications') ?? true,
        soundEnabled: prefs.getBool('chat_sound') ?? true,
        vibrateEnabled: prefs.getBool('chat_vibrate') ?? true,
        voiceMessagesEnabled: prefs.getBool('chat_voice_messages') ?? true,
        locationSharingEnabled: prefs.getBool('chat_location') ?? false,
      );
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Chat Settings', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: Text('Message Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Read Receipts',
                    'Let others know when you\'ve read messages',
                    Icons.done_all,
                    _settings.readReceiptsEnabled,
                    (v) => _updateSetting('chat_read_receipts', v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Typing Indicators',
                    'Show when you\'re typing a message',
                    Icons.edit_note,
                    _settings.typingIndicatorsEnabled,
                    (v) => _updateSetting('chat_typing_indicators', v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Online Status',
                    'Show when you\'re online',
                    Icons.circle,
                    _settings.onlineStatusEnabled,
                    (v) => _updateSetting('chat_online_status', v),
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
                    child: Text('Media & Files', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Auto-Download Media',
                    'Automatically download photos and videos',
                    Icons.download_outlined,
                    _settings.autoDownloadMedia,
                    (v) => _updateSetting('chat_auto_download', v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'High Quality Images',
                    'Send images in original quality',
                    Icons.high_quality,
                    _settings.highQualityImages,
                    (v) => _updateSetting('chat_high_quality', v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Auto-Play Videos',
                    'Play videos automatically',
                    Icons.play_circle_outlined,
                    _settings.autoPlayVideos,
                    (v) => _updateSetting('chat_auto_play', v),
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
                    child: Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Message Notifications',
                    'Notify me about new messages',
                    Icons.notifications_outlined,
                    _settings.notificationsEnabled,
                    (v) => _updateSetting('chat_notifications', v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Sound',
                    'Play sound for new messages',
                    Icons.volume_up_outlined,
                    _settings.soundEnabled,
                    (v) => _updateSetting('chat_sound', v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Vibrate',
                    'Vibrate on new messages',
                    Icons.vibration,
                    _settings.vibrateEnabled,
                    (v) => _updateSetting('chat_vibrate', v),
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
                    child: Text('Chat Features', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Voice Messages',
                    'Enable voice message recordings',
                    Icons.mic_outlined,
                    _settings.voiceMessagesEnabled,
                    (v) => _updateSetting('chat_voice_messages', v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Location Sharing',
                    'Share location in chats',
                    Icons.location_on_outlined,
                    _settings.locationSharingEnabled,
                    (v) => _updateSetting('chat_location', v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildListTile(
                    'Chat Backup',
                    'Backup chat history',
                    Icons.backup_outlined,
                    () {},
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildListTile(
                    'Clear Chat History',
                    'Delete all messages',
                    Icons.delete_outline,
                    () => _showClearChatDialog(),
                    iconColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildListTile(String title, String subtitle, IconData icon, VoidCallback onTap, {Color? iconColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Icon(icon, color: iconColor ?? Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text('This will delete all messages. This action cannot be undone. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat history cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
