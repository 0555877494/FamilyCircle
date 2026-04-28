import 'package:flutter/material.dart';
import '../models/family_user.dart';
import '../models/family_kinship.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_status.dart';

class FamilyTreeScreen extends StatefulWidget {
  final FamilyUser currentUser;
  final List<FamilyUser> members;
  final List<FamilyKinshipTie> kinshipTies;
  
  const FamilyTreeScreen({
    super.key, 
    required this.currentUser,
    required this.members,
    this.kinshipTies = const [],
  });

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Tree'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: _buildTreeContent(),
    );
  }

  Widget _buildTreeContent() {
    if (widget.members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No family members'),
            const SizedBox(height: 8),
            const Text('Add members in Family tab'),
          ],
        ),
      );
    }

    final admins = widget.members.where((m) => m.role == UserRole.admin).toList();
    final parents = widget.members.where((m) => m.role == UserRole.parent).toList();
    final children = widget.members.where((m) => m.role == UserRole.child).toList();
    final grandparents = widget.members.where((m) => m.role == UserRole.grandparent).toList();
    final others = widget.members.where((m) => m.role == UserRole.extended).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (admins.isNotEmpty) _buildRoleSection('Administrators', admins, Colors.purple),
        if (grandparents.isNotEmpty) _buildRoleSection('Grandparents', grandparents, Colors.teal),
        if (parents.isNotEmpty) _buildRoleSection('Parents', parents, Colors.blue),
        if (others.isNotEmpty) _buildRoleSection('Extended Family', others, Colors.grey),
        if (children.isNotEmpty) _buildRoleSection('Children', children, Colors.orange),
        const SizedBox(height: 16),
        _buildLegend(),
        const SizedBox(height: 16),
        _buildKinshipList(),
      ],
    );
  }

  Widget _buildRoleSection(String title, List<FamilyUser> members, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: members.map((m) => _buildMemberChip(m, color)).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMemberChip(FamilyUser member, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: Text(
              member.firstName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${member.firstName}${member.lastName != null ? ' ${member.lastName}' : ''}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (member.dateOfBirth != null)
                Text(
                  'Born: ${member.dateOfBirth!.year}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Legend', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _legendItem(Colors.purple, 'Admin'),
                _legendItem(Colors.teal, 'Grandparent'),
                _legendItem(Colors.blue, 'Parent'),
                _legendItem(Colors.orange, 'Child'),
                _legendItem(Colors.grey, 'Extended'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildKinshipList() {
    if (widget.kinshipTies.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Family Relationships', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...widget.kinshipTies.take(10).map((tie) => ListTile(
              dense: true,
              leading: const Icon(Icons.connecting_airports),
              title: Text(tie.kinshipType.name),
              subtitle: Text('Generation gap: ${tie.generationGap}'),
            )),
          ],
        ),
      ),
    );
  }
}

class FamilyTreeScreenWrapper extends StatelessWidget {
  final FamilyUser currentUser;
  final List<FamilyUser> members;
  final List<FamilyKinshipTie> kinshipTies;
  
  const FamilyTreeScreenWrapper({
    super.key,
    required this.currentUser,
    required this.members,
    this.kinshipTies = const [],
  });

  @override
  Widget build(BuildContext context) {
    return FamilyTreeScreen(
      currentUser: currentUser,
      members: members,
      kinshipTies: kinshipTies,
    );
  }
}