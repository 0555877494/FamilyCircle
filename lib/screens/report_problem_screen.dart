import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();
  String _problemType = 'App Crash';
  String _severity = 'Medium';
  bool _includeScreenshots = true;

  final List<String> _problemTypes = [
    'App Crash',
    'Feature Not Working',
    'Performance Issue',
    'UI/Display Problem',
    'Login Issue',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Report a Problem', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _submitReport,
            child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: Text('Problem Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  ..._problemTypes.map((type) {
                    return Column(
                      children: [
                        RadioListTile<String>(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(type),
                          value: type,
                          groupValue: _problemType,
                          onChanged: (v) => setState(() => _problemType = v!),
                        ),
                        if (type != _problemTypes.last) const Divider(height: 1, indent: 54),
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
                    child: Text('Severity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildSeverityOption('Low', 'Minor issue, not urgent'),
                  const Divider(height: 1, indent: 54),
                  _buildSeverityOption('Medium', 'Affects functionality'),
                  const Divider(height: 1, indent: 54),
                  _buildSeverityOption('High', 'Cannot use app properly'),
                  const Divider(height: 1, indent: 54),
                  _buildSeverityOption('Critical', 'App completely unusable'),
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
                    child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Describe the problem...',
                        border: InputBorder.none,
                      ),
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
                    child: Text('Steps to Reproduce', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _stepsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: '1. Go to...\n2. Tap on...\n3. Then...',
                        border: InputBorder.none,
                      ),
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
                  SwitchListTile(
                    contentPadding: const EdgeInsets.all(16),
                    secondary: const Icon(Icons.camera, color: Colors.grey),
                    title: const Text('Include Screenshots'),
                    subtitle: const Text('Help us understand the issue'),
                    value: _includeScreenshots,
                    onChanged: (v) => setState(() => _includeScreenshots = v),
                  ),
                  const Divider(height: 1, indent: 54),
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.attach_file, color: Colors.grey),
                    title: const Text('Attach Files'),
                    trailing: Icon(Icons.add, color: Colors.grey.shade400),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityOption(String severity, String description) {
    final color = _getSeverityColor(severity);
    return RadioListTile<String>(
      contentPadding: const EdgeInsets.all(16),
      secondary: Icon(Icons.circle, color: color, size: 16),
      title: Text(severity, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      subtitle: Text(description),
      value: severity,
      groupValue: _severity,
      onChanged: (v) => setState(() => _severity = v!),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Low': return Colors.green;
      case 'Medium': return Colors.orange;
      case 'High': return Colors.deepOrange;
      case 'Critical': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _submitReport() {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the problem')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Submitted'),
        content: const Text('Thank you for your report. Our team will investigate this issue.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _stepsController.dispose();
    super.dispose();
  }
}
