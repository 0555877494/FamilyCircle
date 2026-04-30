import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _autoBackup = true;
  String _backupFrequency = 'Daily';
  String _lastBackup = '2 hours ago';
  String _backupSize = '245 MB';
  bool _isBackingUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Backup & Restore', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: Text('Backup Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.cloud_done, color: Colors.green, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Last Backup', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(_lastBackup, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text('Size: $_backupSize', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, indent: 54),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.all(16),
                    secondary: const Icon(Icons.autorenew, color: Colors.grey),
                    title: const Text('Auto Backup'),
                    subtitle: Text('Backup $_backupFrequency'),
                    value: _autoBackup,
                    onChanged: (v) => setState(() => _autoBackup = v),
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
                    child: Text('Backup Options', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.schedule, color: Colors.grey),
                    title: const Text('Backup Frequency'),
                    subtitle: Text(_backupFrequency),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    onTap: _showFrequencyPicker,
                  ),
                  const Divider(height: 1, indent: 54),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.all(16),
                    secondary: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                    title: const Text('Include Messages'),
                    value: true,
                    onChanged: (v) {},
                  ),
                  const Divider(height: 1, indent: 54),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.all(16),
                    secondary: const Icon(Icons.photo_outlined, color: Colors.grey),
                    title: const Text('Include Media'),
                    value: true,
                    onChanged: (v) {},
                  ),
                  const Divider(height: 1, indent: 54),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.all(16),
                    secondary: const Icon(Icons.settings, color: Colors.grey),
                    title: const Text('Include Settings'),
                    value: true,
                    onChanged: (v) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _isBackingUp ? null : _startBackup,
                icon: _isBackingUp
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.backup),
                label: Text(_isBackingUp ? 'Backing Up...' : 'Backup Now'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.restore),
                label: const Text('Restore from Backup'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFrequencyPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Daily', 'Weekly', 'Monthly'].map((freq) {
          return ListTile(
            title: Text(freq),
            trailing: _backupFrequency == freq ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() => _backupFrequency = freq);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _startBackup() async {
    setState(() => _isBackingUp = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isBackingUp = false;
      _lastBackup = 'Just now';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup completed successfully')),
      );
    }
  }
}
