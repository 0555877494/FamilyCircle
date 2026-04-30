import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<HelpArticle> _articles = [
    HelpArticle(title: 'Getting Started', subtitle: 'Learn the basics', icon: Icons.rocket_launch, category: 'Basics'),
    HelpArticle(title: 'Creating a Family', subtitle: 'Set up your family group', icon: Icons.group_add, category: 'Basics'),
    HelpArticle(title: 'Adding Family Members', subtitle: 'Invite and manage members', icon: Icons.person_add, category: 'Basics'),
    HelpArticle(title: 'Messaging Features', subtitle: 'Chat, media, and more', icon: Icons.chat, category: 'Communication'),
    HelpArticle(title: 'Video Calls', subtitle: 'Make family video calls', icon: Icons.videocam, category: 'Communication'),
    HelpArticle(title: 'Location Sharing', subtitle: 'Share your location', icon: Icons.location_on, category: 'Privacy'),
    HelpArticle(title: 'Safe Zones', subtitle: 'Set up safe areas', icon: Icons.security, category: 'Privacy'),
    HelpArticle(title: 'Parental Controls', subtitle: 'Manage screen time', icon: Icons.child_care, category: 'Parenting'),
    HelpArticle(title: 'Bedtime Settings', subtitle: 'Set bedtime schedules', icon: Icons.bed, category: 'Parenting'),
    HelpArticle(title: 'Backup & Restore', subtitle: 'Keep your data safe', icon: Icons.backup, category: 'Data'),
    HelpArticle(title: 'Troubleshooting', subtitle: 'Common issues and fixes', icon: Icons.build, category: 'Support'),
  ];

  String _searchQuery = '';

  List<HelpArticle> get _filteredArticles {
    if (_searchQuery.isEmpty) return _articles;
    return _articles.where((a) =>
        a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        a.subtitle.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Help Center', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search help articles...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredArticles.length,
                itemBuilder: (ctx, i) => _buildArticleCard(_filteredArticles[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(HelpArticle article) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ModernCard(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(article.icon, color: AppColors.primary),
          ),
          title: Text(article.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(article.subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(article.title),
                content: Text('This is a sample help article about ${article.title}. In production, this would show the full help content.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class HelpArticle {
  final String title;
  final String subtitle;
  final IconData icon;
  final String category;

  HelpArticle({required this.title, required this.subtitle, required this.icon, required this.category});
}
