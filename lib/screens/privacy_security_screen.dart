import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = false;
  bool _locationHistoryEnabled = false;
  bool _activityStatusEnabled = true;
  String _profileVisibility = 'Family Only';
  String _lastPasswordChange = '3 months ago';
  final _localAuth = LocalAuthentication();
  final _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await _prefs;
    setState(() {
      _twoFactorEnabled = prefs.getBool('sec_2fa') ?? false;
      _biometricEnabled = prefs.getBool('sec_biometric') ?? false;
      _locationHistoryEnabled = prefs.getBool('sec_location_history') ?? false;
      _activityStatusEnabled = prefs.getBool('sec_activity_status') ?? true;
      _profileVisibility = prefs.getString('sec_profile_visibility') ?? 'Family Only';
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final prefs = await _prefs;
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
    await _loadSettings();
  }

  Future<void> _toggle2FA() async {
    final canCheckBiometrics = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    
    if (!canCheckBiometrics && !isDeviceSupported) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device does not support 2FA')),
        );
      }
      return;
    }

    final authenticated = await _localAuth.authenticate(
      localizedReason: 'Enable two-factor authentication',
      options: const AuthenticationOptions(biometricOnly: false),
    );

    if (authenticated) {
      await _updateSetting('sec_2fa', !_twoFactorEnabled);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_twoFactorEnabled ? '2FA enabled' : '2FA disabled')),
        );
      }
    }
  }

  Future<void> _toggleBiometric() async {
    final canCheckBiometrics = await _localAuth.canCheckBiometrics;
    
    if (!canCheckBiometrics) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No biometrics available on this device')),
        );
      }
      return;
    }

    final authenticated = await _localAuth.authenticate(
      localizedReason: 'Enable biometric authentication',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (authenticated) {
      await _updateSetting('sec_biometric', !_biometricEnabled);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_biometricEnabled ? 'Biometric enabled' : 'Biometric disabled')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: Text('Security', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Two-Factor Authentication',
                    'Add extra security to your account',
                    Icons.security_outlined,
                    _twoFactorEnabled,
                    (v) => _toggle2FA(),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Biometric Authentication',
                    'Use fingerprint or face recognition',
                    Icons.fingerprint,
                    _biometricEnabled,
                    (v) => _toggleBiometric(),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildListTile(
                    'Change Password',
                    _lastPasswordChange,
                    Icons.lock_outline,
                    () {},
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildListTile(
                    'Active Sessions',
                    'Manage logged in devices',
                    Icons.devices_outlined,
                    () {},
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
                    child: Text('Privacy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Activity Status',
                    'Show when you\'re active',
                    Icons.access_time_outlined,
                    _activityStatusEnabled,
                    (v) => _updateSetting('sec_activity_status', v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Location History',
                    'Save location history',
                    Icons.history_outlined,
                    _locationHistoryEnabled,
                    (v) => _updateSetting('sec_location_history', v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildListTile(
                    'Profile Visibility',
                    _profileVisibility,
                    Icons.visibility_outlined,
                    () => _showVisibilityPicker(),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildListTile(
                    'Blocked Users',
                    '0 users blocked',
                    Icons.block_outlined,
                    () {},
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildListTile(
                    'Data & Storage',
                    'Manage your data',
                    Icons.storage_outlined,
                    () {},
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
                    child: Text('Danger Zone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    'Delete Account',
                    'Permanently delete your account',
                    Icons.delete_forever_outlined,
                    () => _showDeleteAccountDialog(),
                    iconColor: Colors.red,
                    textColor: Colors.red,
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildListTile(
                    'Request Data Export',
                    'Download your data',
                    Icons.download_outlined,
                    () {},
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

  Widget _buildListTile(String title, String subtitle, IconData icon, VoidCallback onTap, {Color? iconColor, Color? textColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Icon(icon, color: iconColor ?? Colors.grey.shade600),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  void _showVisibilityPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Family Only', 'Family + Extended', 'Private'].map((option) {
          return ListTile(
            title: Text(option),
            trailing: _profileVisibility == option ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() => _profileVisibility = option);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This will permanently delete your account and all associated data. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requested')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
