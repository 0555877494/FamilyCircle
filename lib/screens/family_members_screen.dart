import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';
import '../services/family_service.dart';
import '../services/auth_service.dart';
import '../models/family_user.dart';
import '../models/family.dart';
import '../widgets/skeleton_loader.dart';

class FamilyMembersScreen extends StatefulWidget {
  final String? familyId;

  const FamilyMembersScreen({super.key, this.familyId});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  final _familyService = FamilyService();
  final _authService = AuthService();
  Family? _family;
  List<FamilyUser> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final familyId = widget.familyId ?? await _authService.getSavedFamilyId();
      if (familyId != null) {
        _family = await _familyService.getFamily(familyId);
        if (_family != null) {
          _members = _family!.members;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading members: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Family Members', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const MemberListSkeleton()
          : ResponsiveWrapper(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _members.length,
                itemBuilder: (ctx, i) => _buildMemberCard(_members[i]),
              ),
            ),
    );
  }

  Widget _buildMemberCard(FamilyUser member) {
    final fullName = '${member.firstName} ${member.lastName ?? ''}'.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ModernCard(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
            child: member.avatarUrl == null
                ? Text(
                    member.firstName.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(member.role.name, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    member.isKidMode ? 'Kid Mode' : 'Member',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'view', child: Text('View Profile')),
              const PopupMenuItem(value: 'message', child: Text('Send Message')),
              const PopupMenuItem(value: 'manage', child: Text('Manage Role')),
            ],
            onSelected: (value) {},
          ),
        ),
      ),
    );
  }
}
