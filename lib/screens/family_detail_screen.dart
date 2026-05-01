import 'package:flutter/material.dart';
import '../models/family.dart';
import '../models/family_user.dart';
import '../models/family_caregiving.dart';
import '../models/family_function.dart';
import '../models/family_kinship.dart';
import '../models/family_partnership.dart';
import '../models/relationship.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_status.dart';

class FamilyDetailScreen extends StatefulWidget {
  final Family family;
  final FamilyUser currentUser;
  
  const FamilyDetailScreen({
    super.key,
    required this.family,
    required this.currentUser,
  });

  @override
  State<FamilyDetailScreen> createState() => _FamilyDetailScreenState();
}

class _FamilyDetailScreenState extends State<FamilyDetailScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.family.name),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildCurrentTab()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Overview', 'Members', 'Relationships', 'Kinship', 'Partnership', 'Household', 'Caregiving', 'Functions'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (i) =>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ChoiceChip(
              label: Text(tabs[i]),
              selected: _selectedTab == i,
              onSelected: (s) => setState(() => _selectedTab = i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedTab) {
      case 0: return _buildOverviewTab();
      case 1: return _buildMembersTab();
      case 2: return _buildRelationshipsTab();
      case 3: return _buildKinshipTab();
      case 4: return _buildPartnershipTab();
      case 5: return _buildHouseholdTab();
      case 6: return _buildCaregivingTab();
      case 7: return _buildFunctionsTab();
      default: return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    final headOfHousehold = widget.family.headOfHouseholdId != null
        ? widget.family.members.where((m) => m.id == widget.family.headOfHouseholdId).firstOrNull
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard('Family Structure', widget.family.structureType.name.toUpperCase(), Icons.account_tree),
        if (widget.family.householdName != null)
          _buildInfoCard('Household Name', widget.family.householdName!, Icons.home),
        if (headOfHousehold != null)
          _buildInfoCard('Head of Household', '${headOfHousehold.firstName} ${headOfHousehold.lastName ?? ''}', Icons.star),
        _buildInfoCard('Members', '${widget.family.members.length}', Icons.people),
        _buildInfoCard('Created', _formatDate(widget.family.createdAt), Icons.calendar_today),
        const SizedBox(height: 16),
        _buildInfoCard('Relationships', '${widget.family.relationships.length}', Icons.people_outline),
        _buildInfoCard('Kinship Ties', '${widget.family.kinshipTies.length}', Icons.favorite),
        _buildInfoCard('Partnerships', '${widget.family.partnerships.length}', Icons.favorite_border),
        _buildInfoCard('Households', '${widget.family.households.length}', Icons.house),
        _buildInfoCard('Caregiving', '${widget.family.caregiving.length}', Icons.child_care),
        _buildInfoCard('Functions', '${widget.family.functions.length}', Icons.functions),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildMembersTab() {
    return ListView.builder(
      itemCount: widget.family.members.length,
      itemBuilder: (ctx, i) {
        final member = widget.family.members[i];
        final isHead = member.id == widget.family.headOfHouseholdId;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isHead ? Colors.amber : AppTheme.primaryColor,
            child: Text(member.firstName[0].toUpperCase()),
          ),
          title: Row(
            children: [
              Text('${member.firstName} ${member.lastName ?? ''}'),
              if (isHead) ...[
                const SizedBox(width: 8),
                const Chip(label: Text('Head', style: TextStyle(fontSize: 12)), padding: EdgeInsets.zero),
              ],
            ],
          ),
          subtitle: Text('${member.role.name.toUpperCase()} | ${member.nationality ?? 'No nationality'}'),
          trailing: member.dateOfBirth != null ? Text(_formatDate(member.dateOfBirth!)) : null,
        );
      },
    );
  }

  Widget _buildRelationshipsTab() {
    if (widget.family.relationships.isEmpty) {
      return _buildEmptyState('No relationships defined', Icons.people_outline);
    }
    return ListView.builder(
      itemCount: widget.family.relationships.length,
      itemBuilder: (ctx, i) {
        final rel = widget.family.relationships[i];
        final memberA = widget.family.members.where((m) => m.id == rel.memberAId).firstOrNull;
        final memberB = widget.family.members.where((m) => m.id == rel.memberBId).firstOrNull;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: const Icon(Icons.people_outline, color: Colors.blue),
          ),
          title: Text('${memberA?.firstName ?? 'Unknown'} → ${memberB?.firstName ?? 'Unknown'}'),
          subtitle: Text(rel.type.name.toUpperCase()),
          trailing: Text('#${rel.id.substring(0, 4)}'),
        );
      },
    );
  }

  Widget _buildKinshipTab() {
    if (widget.family.kinshipTies.isEmpty) {
      return _buildEmptyState('No kinship ties defined', Icons.favorite);
    }
    return ListView.builder(
      itemCount: widget.family.kinshipTies.length,
      itemBuilder: (ctx, i) {
        final tie = widget.family.kinshipTies[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: tie.isBloodRelation ? Colors.red[100] : Colors.orange[100],
            child: Icon(Icons.favorite, color: tie.isBloodRelation ? Colors.red : Colors.orange),
          ),
          title: Text(tie.kinshipType.name.toUpperCase()),
          subtitle: Text('Generation gap: ${tie.generationGap}'),
        );
      },
    );
  }

  Widget _buildPartnershipTab() {
    if (widget.family.partnerships.isEmpty) {
      return _buildEmptyState('No partnerships defined', Icons.favorite_border);
    }
    return ListView.builder(
      itemCount: widget.family.partnerships.length,
      itemBuilder: (ctx, i) {
        final p = widget.family.partnerships[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: p.isLegal ? Colors.purple[100] : Colors.blue[100],
            child: Icon(Icons.favorite_border, color: Colors.purple),
          ),
          title: Text(p.partnershipType.name.toUpperCase()),
          subtitle: Text('${p.status.name.toUpperCase()} | ${p.isLegal ? "Legal" : "Non-legal"}'),
          trailing: p.startDate != null ? Text(_formatDate(p.startDate!)) : null,
        );
      },
    );
  }

  Widget _buildHouseholdTab() {
    if (widget.family.households.isEmpty) {
      return _buildEmptyState('No households defined', Icons.house);
    }
    return ListView.builder(
      itemCount: widget.family.households.length,
      itemBuilder: (ctx, i) {
        final h = widget.family.households[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green[100],
            child: const Icon(Icons.house, color: Colors.green),
          ),
          title: Text(h.name ?? 'Household'),
          subtitle: Text('${h.householdType.name.toUpperCase()} | ${h.residentMemberIds.length} residents'),
          trailing: h.isPrimaryResidence ? const Chip(label: Text('Primary')) : null,
        );
      },
    );
  }

  Widget _buildCaregivingTab() {
    if (widget.family.caregiving.isEmpty) {
      return _buildEmptyState('No caregiving arrangements defined', Icons.child_care);
    }
    return ListView.builder(
      itemCount: widget.family.caregiving.length,
      itemBuilder: (ctx, i) {
        final c = widget.family.caregiving[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: c.isPrimary ? Colors.amber[100] : Colors.grey[200],
            child: Icon(Icons.child_care, color: c.isPrimary ? Colors.amber : Colors.grey),
          ),
          title: Text(c.caregivingType.name.toUpperCase()),
          subtitle: Text('${c.arrangement.name.toUpperCase()} | ${c.responsibilityPercentage.toInt()}%'),
          trailing: c.isLegalCustody ? const Chip(label: Text('Legal')) : null,
        );
      },
    );
  }

  Widget _buildFunctionsTab() {
    if (widget.family.functions.isEmpty) {
      return _buildEmptyState('No family functions defined', Icons.functions);
    }
    return ListView.builder(
      itemCount: widget.family.functions.length,
      itemBuilder: (ctx, i) {
        final f = widget.family.functions[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getFunctionColor(f.functionType),
            child: Icon(_getFunctionIcon(f.functionType), color: Colors.white),
          ),
          title: Text(f.displayName),
          subtitle: Text('${f.status.name.toUpperCase()} | ${f.responsibleMemberIds.length} responsible'),
        );
      },
    );
  }

  Color _getFunctionColor(FamilyFunctionType type) {
    switch (type) {
      case FamilyFunctionType.procreation: return Colors.pink;
      case FamilyFunctionType.childRearing: return Colors.orange;
      case FamilyFunctionType.economicCooperation: return Colors.green;
      case FamilyFunctionType.socialization: return Colors.blue;
      case FamilyFunctionType.emotionalSupport: return Colors.purple;
      case FamilyFunctionType.identityTransmission: return Colors.teal;
      case FamilyFunctionType.culturalHeritage: return Colors.brown;
      case FamilyFunctionType.education: return Colors.indigo;
      case FamilyFunctionType.healthcare: return Colors.red;
      case FamilyFunctionType.protection: return Colors.grey;
    }
  }

  IconData _getFunctionIcon(FamilyFunctionType type) {
    switch (type) {
      case FamilyFunctionType.procreation: return Icons.child_friendly;
      case FamilyFunctionType.childRearing: return Icons.family_restroom;
      case FamilyFunctionType.economicCooperation: return Icons.attach_money;
      case FamilyFunctionType.socialization: return Icons.groups;
      case FamilyFunctionType.emotionalSupport: return Icons.favorite;
      case FamilyFunctionType.identityTransmission: return Icons.badge;
      case FamilyFunctionType.culturalHeritage: return Icons.museum;
      case FamilyFunctionType.education: return Icons.school;
      case FamilyFunctionType.healthcare: return Icons.local_hospital;
      case FamilyFunctionType.protection: return Icons.shield;
    }
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Add Relationship'),
            onTap: () { Navigator.pop(ctx); _showAddRelationshipDialog(); },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Add Kinship'),
            onTap: () { Navigator.pop(ctx); _showAddKinshipDialog(); },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Add Partnership'),
            onTap: () { Navigator.pop(ctx); _showAddPartnershipDialog(); },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Add Household'),
            onTap: () { Navigator.pop(ctx); _showAddHouseholdDialog(); },
          ),
          ListTile(
            leading: const Icon(Icons.child_care),
            title: const Text('Add Caregiving'),
            onTap: () { Navigator.pop(ctx); _showAddCaregivingDialog(); },
          ),
          ListTile(
            leading: const Icon(Icons.functions),
            title: const Text('Add Function'),
            onTap: () { Navigator.pop(ctx); _showAddFunctionDialog(); },
          ),
        ],
      ),
    );
  }

  void _showAddKinshipDialog() {
    final memberAController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Kinship Tie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: memberAController, decoration: const InputDecoration(labelText: 'Member A ID')),
            const SizedBox(height: 8),
            DropdownButton<String>(
              hint: const Text('Kinship Type'),
              items: KinshipType.values.map((t) => DropdownMenuItem(value: t.name, child: Text(t.name))).toList(),
              onChanged: (v) {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Add')),
        ],
      ),
    );
  }

  void _showAddPartnershipDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Partnership'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              hint: const Text('Partnership Type'),
              items: PartnershipType.values.map((t) => DropdownMenuItem(value: t.name, child: Text(t.name))).toList(),
              onChanged: (v) {},
            ),
            SwitchListTile(title: const Text('Legal'), value: false, onChanged: (v) {}),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Add')),
        ],
      ),
    );
  }

  void _showAddHouseholdDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Household'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Household Name')),
            const SizedBox(height: 8),
            TextField(decoration: const InputDecoration(labelText: 'Address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Add')),
        ],
      ),
    );
  }

  void _showAddCaregivingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Caregiving'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              hint: const Text('Caregiving Type'),
              items: CaregivingType.values.map((t) => DropdownMenuItem(value: t.name, child: Text(t.name))).toList(),
              onChanged: (v) {},
            ),
            SwitchListTile(title: const Text('Primary'), value: false, onChanged: (v) {}),
            SwitchListTile(title: const Text('Legal Custody'), value: false, onChanged: (v) {}),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Add')),
        ],
      ),
    );
  }

  void _showAddFunctionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Family Function'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: FamilyFunctionType.values
              .map((t) => ListTile(title: Text(t.name), onTap: () {}))
              .toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _showAddRelationshipDialog() {
    String? selectedMemberA;
    String? selectedMemberB;
    RelationshipType? selectedType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Relationship'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: const Text('Member A'),
                value: selectedMemberA,
                isExpanded: true,
                items: widget.family.members.map((m) => DropdownMenuItem(
                  value: m.id,
                  child: Text('${m.firstName} ${m.lastName ?? ''}'),
                )).toList(),
                onChanged: (v) => setState(() => selectedMemberA = v),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                hint: const Text('Member B'),
                value: selectedMemberB,
                isExpanded: true,
                items: widget.family.members.map((m) => DropdownMenuItem(
                  value: m.id,
                  child: Text('${m.firstName} ${m.lastName ?? ''}'),
                )).toList(),
                onChanged: (v) => setState(() => selectedMemberB = v),
              ),
              const SizedBox(height: 8),
              DropdownButton<RelationshipType>(
                hint: const Text('Relationship Type'),
                value: selectedType,
                isExpanded: true,
                items: RelationshipType.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.name.toUpperCase()),
                )).toList(),
                onChanged: (v) => setState(() => selectedType = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (selectedMemberA != null && selectedMemberB != null && selectedType != null) {
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}