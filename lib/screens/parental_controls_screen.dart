import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';
import '../models/parental_settings.dart';
import '../services/parental_service.dart';
import '../widgets/skeleton_loader.dart';

class ParentalControlsScreen extends StatefulWidget {
  final String familyId;
  final String memberId;

  const ParentalControlsScreen({super.key, required this.familyId, required this.memberId});

  @override
  State<ParentalControlsScreen> createState() => _ParentalControlsScreenState();
}

class _ParentalControlsScreenState extends State<ParentalControlsScreen> {
  final _parentalService = ParentalService();
  ParentalSettings _settings = ParentalSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _parentalService.getSettings(widget.familyId, widget.memberId);
      if (settings != null) {
        setState(() => _settings = settings);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _parentalService.saveSettings(widget.familyId, widget.memberId, _settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parental settings saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  String get _formattedBedtime {
    final hour = _settings.bedtimeHour % 12 == 0 ? 12 : _settings.bedtimeHour % 12;
    final period = _settings.bedtimeHour >= 12 ? 'PM' : 'AM';
    return '$hour:${_settings.bedtimeMinute.toString().padLeft(2, '0')} $period';
  }

  String get _formattedScreenTime {
    final hours = _settings.screenTimeLimitMinutes ~/ 60;
    final minutes = _settings.screenTimeLimitMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.lightColorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Parental Controls', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: const SettingsSkeleton(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Parental Controls', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
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
                    child: Text('Screen Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.all(16),
                    secondary: const Icon(Icons.timer_outlined, color: Colors.grey),
                    title: const Text('Enable Screen Time Limit'),
                    subtitle: Text(_settings.screenTimeEnabled ? _formattedScreenTime : 'Disabled'),
                    value: _settings.screenTimeEnabled,
                    onChanged: (v) => setState(() => _settings = _settings.copyWith(screenTimeEnabled: v)),
                  ),
                  if (_settings.screenTimeEnabled) ...[
                    const Divider(height: 1, indent: 54),
                    _buildScreenTimeOptions(),
                  ],
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
                    child: Text('Bedtime', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.bedtime_outlined, color: Colors.grey),
                    title: const Text('Bedtime'),
                    subtitle: Text(_formattedBedtime),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    onTap: _showBedtimePicker,
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
                    child: Text('Content & Safety', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.all(16),
                    secondary: const Icon(Icons.filter_alt_outlined, color: Colors.grey),
                    title: const Text('Content Filter'),
                    subtitle: const Text('Filter inappropriate content'),
                    value: _settings.contentFilterEnabled,
                    onChanged: (v) => setState(() => _settings = _settings.copyWith(contentFilterEnabled: v)),
                  ),
                  const Divider(height: 1, indent: 54),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.all(16),
                    secondary: const Icon(Icons.location_on_outlined, color: Colors.grey),
                    title: const Text('Location Sharing'),
                    subtitle: const Text('Track location'),
                    value: _settings.locationSharingEnabled,
                    onChanged: (v) => setState(() => _settings = _settings.copyWith(locationSharingEnabled: v)),
                  ),
                  const Divider(height: 1, indent: 54),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.all(16),
                    secondary: const Icon(Icons.warning_amber, color: Colors.grey),
                    title: const Text('Emergency Broadcast'),
                    subtitle: const Text('Allow emergency alerts'),
                    value: _settings.emergencyBroadcastEnabled,
                    onChanged: (v) => setState(() => _settings = _settings.copyWith(emergencyBroadcastEnabled: v)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenTimeOptions() {
    return Column(
      children: [30, 60, 90, 120, 180, 240].map((minutes) {
        final hours = minutes ~/ 60;
        final mins = minutes % 60;
        final label = hours == 0 ? '${mins}m' : mins == 0 ? '${hours}h' : '${hours}h ${mins}m';
        
        return RadioListTile<int>(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(label),
          value: minutes,
          groupValue: _settings.screenTimeLimitMinutes,
          onChanged: (v) => setState(() => _settings = _settings.copyWith(screenTimeLimitMinutes: v!)),
        );
      }).toList(),
    );
  }

  void _showBedtimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _settings.bedtimeHour, minute: _settings.bedtimeMinute),
    );
    if (time != null) {
      setState(() => _settings = _settings.copyWith(
        bedtimeHour: time.hour,
        bedtimeMinute: time.minute,
      ));
    }
  }
}
