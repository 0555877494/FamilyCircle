import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  final List<ExportItem> _items = [
    ExportItem(name: 'Messages', isSelected: true, count: '1,234'),
    ExportItem(name: 'Photos', isSelected: true, count: '567'),
    ExportItem(name: 'Videos', isSelected: true, count: '23'),
    ExportItem(name: 'Location History', isSelected: false, count: '89'),
    ExportItem(name: 'Settings', isSelected: true, count: '1'),
    ExportItem(name: 'Profile Info', isSelected: true, count: '1'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Export Data', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: Text('Select Data to Export', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  ..._items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        CheckboxListTile(
                          contentPadding: const EdgeInsets.all(16),
                          secondary: _getIcon(item.name),
                          title: Text(item.name),
                          subtitle: Text('${item.count} items'),
                          value: item.isSelected,
                          onChanged: (v) {
                            setState(() {
                              _items[index] = ExportItem(
                                name: item.name,
                                isSelected: v ?? false,
                                count: item.count,
                              );
                            });
                          },
                        ),
                        if (index < _items.length - 1) const Divider(height: 1, indent: 54),
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
                    child: Text('Export Format', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildFormatOption('JSON', 'Machine readable format', true),
                  const Divider(height: 1, indent: 54),
                  _buildFormatOption('CSV', 'Spreadsheet compatible', false),
                  const Divider(height: 1, indent: 54),
                  _buildFormatOption('PDF', 'Human readable report', false),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _exportData,
                icon: const Icon(Icons.download),
                label: const Text('Export Data'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIcon(String name) {
    final icons = {
      'Messages': Icons.chat_bubble_outline,
      'Photos': Icons.photo_outlined,
      'Videos': Icons.videocam_outlined,
      'Location History': Icons.location_on_outlined,
      'Settings': Icons.settings,
      'Profile Info': Icons.person_outline,
    };
    return Icon(icons[name] ?? Icons.insert_drive_file, color: Colors.grey);
  }

  Widget _buildFormatOption(String format, String description, bool isSelected) {
    return RadioListTile<String>(
      contentPadding: const EdgeInsets.all(16),
      title: Text(format),
      subtitle: Text(description),
      value: format,
      groupValue: 'JSON',
      onChanged: (v) {},
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Your data export is being prepared. You will receive a notification when it\'s ready to download.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export started. You\'ll be notified when ready.')),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ExportItem {
  final String name;
  final bool isSelected;
  final String count;

  ExportItem({required this.name, required this.isSelected, required this.count});
}
