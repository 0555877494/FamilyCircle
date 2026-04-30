import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _feedbackController = TextEditingController();
  String _feedbackType = 'General';
  int _rating = 0;
  bool _includeEmail = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Send Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _submitFeedback,
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
                    child: Text('Feedback Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildTypeOption('General', 'General feedback'),
                  const Divider(height: 1, indent: 54),
                  _buildTypeOption('Bug Report', 'Report a bug'),
                  const Divider(height: 1, indent: 54),
                  _buildTypeOption('Feature Request', 'Suggest a feature'),
                  const Divider(height: 1, indent: 54),
                  _buildTypeOption('Compliment', 'Share positive feedback'),
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
                    child: Text('Rate Your Experience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return IconButton(
                          icon: Icon(
                            i < _rating ? Icons.star : Icons.star_border,
                            color: i < _rating ? Colors.amber : Colors.grey,
                            size: 36,
                          ),
                          onPressed: () => setState(() => _rating = i + 1),
                        );
                      }),
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
                    child: Text('Your Feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _feedbackController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Tell us what you think...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: const Text('Include Email'),
                    subtitle: const Text('Allow us to respond'),
                    value: _includeEmail,
                    onChanged: (v) => setState(() => _includeEmail = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String type, String description) {
    return RadioListTile<String>(
      contentPadding: const EdgeInsets.all(16),
      title: Text(type),
      subtitle: Text(description),
      value: type,
      groupValue: _feedbackType,
      onChanged: (v) => setState(() => _feedbackType = v!),
    );
  }

  void _submitFeedback() {
    if (_feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thank You!'),
        content: const Text('Your feedback has been submitted. We appreciate your input!'),
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
    _feedbackController.dispose();
    super.dispose();
  }
}
