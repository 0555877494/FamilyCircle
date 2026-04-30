import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Open Source Licenses', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: Text('Dependencies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  _buildLicenseTile(
                    'Flutter',
                    'BSD',
                    'Google LLC',
                    'https://flutter.dev',
                    context,
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildLicenseTile(
                    'Firebase',
                    'Proprietary',
                    'Google LLC',
                    'https://firebase.google.com',
                    context,
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildLicenseTile(
                    'Dart',
                    'BSD',
                    'Google LLC',
                    'https://dart.dev',
                    context,
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildLicenseTile(
                    'Provider',
                    'MIT',
                    'Remi Rousselet',
                    'https://pub.dev/packages/provider',
                    context,
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildLicenseTile(
                    'Cloud Firestore',
                    'Proprietary',
                    'Google LLC',
                    'https://pub.dev/packages/cloud_firestore',
                    context,
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildLicenseTile(
                    'SQFlite',
                    'MIT',
                    'Tekartik',
                    'https://pub.dev/packages/sqflite',
                    context,
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildLicenseTile(
                    'Drift',
                    'Apache 2.0',
                    'Simon Binder',
                    'https://pub.dev/packages/drift',
                    context,
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildLicenseTile(
                    'UUID',
                    'MIT',
                    'Daegalus',
                    'https://pub.dev/packages/uuid',
                    context,
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
                    child: Text('App License', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FamilyCircle',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Copyright (c) 2026 FamilyCircle',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files, to deal in the Software without restriction...',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'This is a sample license page. Full license texts would be displayed here.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseTile(String name, String license, String author, String url, BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.extension, color: AppColors.primary, size: 20),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('$license • $author', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(name),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('License: $license'),
                  const SizedBox(height: 8),
                  Text('Author: $author'),
                  const SizedBox(height: 8),
                  Text('URL: $url'),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          ),
        );
      },
    );
  }
}
