import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';

class VideoCallSettingsScreen extends StatefulWidget {
  const VideoCallSettingsScreen({super.key});

  @override
  State<VideoCallSettingsScreen> createState() => _VideoCallSettingsScreenState();
}

class _VideoCallSettingsScreenState extends State<VideoCallSettingsScreen> {
  bool _enableVideo = true;
  bool _enableAudio = true;
  bool _speakerByDefault = true;
  bool _lowDataMode = false;
  bool _blurBackground = false;
  String _cameraPosition = 'Front';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Video Call Settings', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: Text('Call Defaults', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Enable Video',
                    'Start calls with video on',
                    Icons.videocam_outlined,
                    _enableVideo,
                    (v) => setState(() => _enableVideo = v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Enable Audio',
                    'Start calls with microphone on',
                    Icons.mic_outlined,
                    _enableAudio,
                    (v) => setState(() => _enableAudio = v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Speaker by Default',
                    'Use speakerphone for calls',
                    Icons.volume_up_outlined,
                    _speakerByDefault,
                    (v) => setState(() => _speakerByDefault = v),
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
                    child: Text('Video Quality', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Low Data Mode',
                    'Reduce data usage during calls',
                    Icons.data_usage,
                    _lowDataMode,
                    (v) => setState(() => _lowDataMode = v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Blur Background',
                    'Blur your background during calls',
                    Icons.blur_on_outlined,
                    _blurBackground,
                    (v) => setState(() => _blurBackground = v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildListTile(
                    'Camera Position',
                    _cameraPosition,
                    Icons.camera_alt_outlined,
                    () => _showCameraPicker(),
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
                    'Call Notifications',
                    'Notify for incoming calls',
                    Icons.notifications_outlined,
                    true,
                    (v) {},
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Missed Call Alerts',
                    'Get notified about missed calls',
                    Icons.call_missed_outlined,
                    true,
                    (v) {},
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

  Widget _buildListTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  void _showCameraPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Front', 'Back'].map((option) {
          return ListTile(
            title: Text(option),
            trailing: _cameraPosition == option ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() => _cameraPosition = option);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }
}
