import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../theme/app_colors.dart';
import '../widgets/connection_status.dart';

enum RuleCategory { behavior, screenTime, chores, homework, social, safety, bedtime, eating, other }
enum RuleEnforcement { strict, flexible, rewardBased, noEnforcement }

class FamilyRule {
  final String id;
  final String familyId;
  final String title;
  final String? description;
  final RuleCategory category;
  final RuleEnforcement enforcement;
  final int? limitValue;
  final String? limitUnit;
  final List<String> appliesToIds;
  final bool isActive;
  final DateTime createdAt;

  FamilyRule({
    required this.id,
    required this.familyId,
    required this.title,
    this.description,
    required this.category,
    this.enforcement = RuleEnforcement.strict,
    this.limitValue,
    this.limitUnit,
    required this.appliesToIds,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'title': title,
      'description': description,
      'category': category.name,
      'enforcement': enforcement.name,
      'limitValue': limitValue,
      'limitUnit': limitUnit,
      'appliesToIds': appliesToIds,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyRule.fromMap(Map<String, dynamic> map) {
    return FamilyRule(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: RuleCategory.values.firstWhere((e) => e.name == map['category']),
      enforcement: RuleEnforcement.values.firstWhere((e) => e.name == map['enforcement'], orElse: () => RuleEnforcement.strict),
      limitValue: map['limitValue'] as int?,
      limitUnit: map['limitUnit'] as String?,
      appliesToIds: List<String>.from(map['appliesToIds'] as List),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class FamilyRulesScreen extends StatefulWidget {
  final FamilyUser? currentUser;
  
  const FamilyRulesScreen({super.key, this.currentUser});

  @override
  State<FamilyRulesScreen> createState() => _FamilyRulesScreenState();
}

class _FamilyRulesScreenState extends State<FamilyRulesScreen> {
  List<FamilyRule> _rules = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadSampleRules();
  }

  void _loadSampleRules() {
    _rules = [
      FamilyRule(id: 'rule_001', familyId: widget.currentUser?.familyId ?? 'default_family', title: '📵 No screens during dinner', description: 'Family dinner time is device-free', category: RuleCategory.screenTime, enforcement: RuleEnforcement.strict, appliesToIds: ['user_003', 'user_004'], createdAt: DateTime.now()),
      FamilyRule(id: 'rule_002', familyId: widget.currentUser?.familyId ?? 'default_family', title: '🛏️ Make beds daily', description: 'Keep rooms tidy before school', category: RuleCategory.chores, enforcement: RuleEnforcement.strict, appliesToIds: ['user_003', 'user_004'], createdAt: DateTime.now()),
      FamilyRule(id: 'rule_003', familyId: widget.currentUser?.familyId ?? 'default_family', title: '📚 Homework first', description: 'Complete homework before TV or games', category: RuleCategory.homework, enforcement: RuleEnforcement.strict, limitValue: 2, limitUnit: 'hours', appliesToIds: ['user_003'], createdAt: DateTime.now()),
      FamilyRule(id: 'rule_004', familyId: widget.currentUser?.familyId ?? 'default_family', title: '🚪 Curfew', description: 'Be home by 9pm on weekdays', category: RuleCategory.safety, enforcement: RuleEnforcement.strict, appliesToIds: ['user_003'], createdAt: DateTime.now()),
      FamilyRule(id: 'rule_005', familyId: widget.currentUser?.familyId ?? 'default_family', title: '🙏 Prayer time', description: 'Evening prayers together', category: RuleCategory.behavior, enforcement: RuleEnforcement.flexible, appliesToIds: ['user_001', 'user_002', 'user_003', 'user_004'], createdAt: DateTime.now()),
      FamilyRule(id: 'rule_006', familyId: widget.currentUser?.familyId ?? 'default_family', title: '⏰ Bedtime', description: 'Bedtime by 8pm on school nights', category: RuleCategory.bedtime, enforcement: RuleEnforcement.strict, appliesToIds: ['user_004'], createdAt: DateTime.now()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Rules'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: _rules.isEmpty 
        ? _buildEmptyState()
        : ListView.builder(
            itemCount: _rules.length,
            itemBuilder: (ctx, i) => _buildRuleCard(_rules[i]),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRuleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rule, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No family rules yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _showAddRuleDialog,
            child: const Text('Add First Rule'),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(FamilyRule rule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: Icon(_getCategoryIcon(rule.category), color: _getCategoryColor(rule.category)),
        title: Text(rule.title),
        subtitle: Text('${rule.category.name} | ${rule.enforcement.name}'),
        trailing: Switch(
          value: rule.isActive,
          onChanged: (v) => _toggleRule(rule),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rule.description != null) Text(rule.description!),
                const SizedBox(height: 8),
                if (rule.limitValue != null)
                  Text('Limit: ${rule.limitValue} ${rule.limitUnit ?? ''}'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _deleteRule(rule),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(RuleCategory category) {
    switch (category) {
      case RuleCategory.behavior: return Icons.face;
      case RuleCategory.screenTime: return Icons.phone_android;
      case RuleCategory.chores: return Icons.cleaning_services;
      case RuleCategory.homework: return Icons.school;
      case RuleCategory.social: return Icons.groups;
      case RuleCategory.safety: return Icons.shield;
      case RuleCategory.bedtime: return Icons.bedtime;
      case RuleCategory.eating: return Icons.restaurant;
      case RuleCategory.other: return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(RuleCategory category) {
    switch (category) {
      case RuleCategory.behavior: return Colors.purple;
      case RuleCategory.screenTime: return Colors.blue;
      case RuleCategory.chores: return Colors.green;
      case RuleCategory.homework: return Colors.orange;
      case RuleCategory.social: return Colors.pink;
      case RuleCategory.safety: return Colors.red;
      case RuleCategory.bedtime: return Colors.indigo;
      case RuleCategory.eating: return Colors.brown;
      case RuleCategory.other: return Colors.grey;
    }
  }

  void _toggleRule(FamilyRule rule) {
    setState(() {
      _rules = _rules.where((r) => r.id != rule.id).toList()
        ..add(FamilyRule(
          id: rule.id,
          familyId: rule.familyId,
          title: rule.title,
          description: rule.description,
          category: rule.category,
          enforcement: rule.enforcement,
          limitValue: rule.limitValue,
          limitUnit: rule.limitUnit,
          appliesToIds: rule.appliesToIds,
          isActive: !rule.isActive,
          createdAt: rule.createdAt,
        ));
    });
  }

  void _deleteRule(FamilyRule rule) {
    setState(() => _rules.removeWhere((r) => r.id == rule.id));
  }

  void _showAddRuleDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    RuleCategory selectedCategory = RuleCategory.behavior;
    RuleEnforcement selectedEnforcement = RuleEnforcement.strict;
    int? limitValue;
    String? limitUnit;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Family Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Rule Title')),
                const SizedBox(height: 8),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                const SizedBox(height: 8),
                DropdownButtonFormField<RuleCategory>(
                  value: selectedCategory,
                  items: RuleCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedCategory = v!),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<RuleEnforcement>(
                  value: selectedEnforcement,
                  items: RuleEnforcement.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedEnforcement = v!),
                  decoration: const InputDecoration(labelText: 'Enforcement'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Limit Value'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => limitValue = int.tryParse(v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Unit (e.g., hours)'),
                        onChanged: (v) => limitUnit = v,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final rule = FamilyRule(
                    id: _uuid.v4(),
                    familyId: widget.currentUser?.familyId ?? 'default_family',
                    title: titleController.text,
                    description: descController.text.isEmpty ? null : descController.text,
                    category: selectedCategory,
                    enforcement: selectedEnforcement,
                    limitValue: limitValue,
                    limitUnit: limitUnit,
                     appliesToIds: [widget.currentUser?.id ?? 'default_user'],
                    createdAt: DateTime.now(),
                  );
                  setState(() => _rules.add(rule));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}