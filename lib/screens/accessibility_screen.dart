import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  bool _boldTextEnabled = false;
  bool _reduceMotion = false;
  bool _highContrast = false;
  double _textScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Accessibility', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: Text('Display', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Bold Text',
                    'Increase text weight',
                    Icons.format_bold,
                    _boldTextEnabled,
                    (v) => setState(() => _boldTextEnabled = v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'High Contrast',
                    'Increase contrast for readability',
                    Icons.contrast,
                    _highContrast,
                    (v) => setState(() => _highContrast = v),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Reduce Motion',
                    'Minimize animations',
                    Icons.animation_outlined,
                    _reduceMotion,
                    (v) => setState(() => _reduceMotion = v),
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
                    child: Text('Text Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('A', style: TextStyle(fontSize: 14)),
                            Text('${(_textScale * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Text('A', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _textScale,
                          min: 0.8,
                          max: 2.0,
                          divisions: 12,
                          onChanged: (v) => setState(() => _textScale = v),
                        ),
                      ],
                    ),
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
                    child: Text('Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sample Text',
                          style: TextStyle(
                            fontSize: 24 * _textScale,
                            fontWeight: _boldTextEnabled ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This is how text will appear with your current accessibility settings.',
                          style: TextStyle(
                            fontSize: 14 * _textScale,
                            fontWeight: _boldTextEnabled ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _highContrast ? Colors.black : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'High contrast mode preview',
                            style: TextStyle(
                              color: _highContrast ? Colors.white : Colors.black,
                              fontSize: 14 * _textScale,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    child: Text('Screen Reader', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    'TalkBack / VoiceOver',
                    'Configure screen reader settings',
                    Icons.record_voice_over_outlined,
                    () {},
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildSwitchTile(
                    'Enable Captions',
                    'Show captions for videos',
                    Icons.closed_caption_outlined,
                    false,
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
}
