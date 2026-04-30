import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ResponsiveWrapper(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ModernCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terms of Service',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: April 28, 2026',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      '1. Acceptance of Terms',
                      'By accessing or using the FamilyCircle application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.',
                    ),
                    _buildSection(
                      '2. Description of Service',
                      'FamilyCircle is a family communication platform that enables families to communicate, share media, track locations, manage calendars, and organize family activities in a secure environment.',
                    ),
                    _buildSection(
                      '3. User Accounts',
                      'You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use of your account.',
                    ),
                    _buildSection(
                      '4. Privacy',
                      'Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information.',
                    ),
                    _buildSection(
                      '5. User Content',
                      'You retain ownership of all content you post, upload, or share through the Service. By posting content, you grant us a license to use, store, and display such content.',
                    ),
                    _buildSection(
                      '6. Prohibited Conduct',
                      'You agree not to: (a) use the Service for any illegal purpose; (b) harass, abuse, or harm another person; (c) interfere with the proper functioning of the Service; (d) attempt to bypass any security measures.',
                    ),
                    _buildSection(
                      '7. Termination',
                      'We reserve the right to terminate or suspend your account at our sole discretion, without notice, for conduct that we believe violates these Terms or is harmful to other users.',
                    ),
                    _buildSection(
                      '8. Limitation of Liability',
                      'FamilyCircle shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the Service.',
                    ),
                    _buildSection(
                      '9. Changes to Terms',
                      'We may modify these Terms at any time. We will notify users of any material changes by posting the new Terms on this page.',
                    ),
                    _buildSection(
                      '10. Contact Us',
                      'If you have any questions about these Terms, please contact us at: legal@familycircle.app',
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'These terms are a sample and should be reviewed by legal counsel before production use.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }
}
