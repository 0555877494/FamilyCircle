import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';
import '../theme/responsive.dart';
import '../models/family_user.dart';
import '../services/user_service.dart';
import '../widgets/skeleton_loader.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  final _picker = ImagePicker();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthplaceController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _culturalHeritageController = TextEditingController();

  FamilyUser? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      _user = await _userService.getUser(widget.userId);
      if (_user != null) {
        _populateFields();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _populateFields() {
    _firstNameController.text = _user!.firstName;
    _lastNameController.text = _user!.lastName ?? '';
    _birthplaceController.text = _user!.birthplace ?? '';
    _nationalityController.text = _user!.nationality ?? '';
    _culturalHeritageController.text =
        _user!.culturalHeritage?.toString() ?? '';
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    setState(() => _isSaving = true);
    try {
      final updated = _user!.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        birthplace: _birthplaceController.text.trim().isEmpty
            ? null
            : _birthplaceController.text.trim(),
        nationality: _nationalityController.text.trim().isEmpty
            ? null
            : _nationalityController.text.trim(),
        culturalHeritage: _culturalHeritageController.text.trim().isEmpty
            ? null
            : {'background': _culturalHeritageController.text.trim()},
      );
      await _userService.updateUser(updated);
      setState(() {
        _user = updated;
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _uploadAvatar() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar upload not yet implemented')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Profile' : 'Profile',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveProfile,
            ),
        ],
      ),
      body: ResponsiveWrapper(
        child: _isLoading
            ? const ProfileSkeleton()
            : _user == null
                ? _buildErrorState()
                : _buildProfileContent(),
      ),
    );
  }

  Widget _buildProfileContent() {
    final fullName = '${_user!.firstName} ${_user!.lastName ?? ''}'.trim();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ModernCard(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Stack(
                children: [
                  GestureDetector(
                    onTap: _isEditing ? _uploadAvatar : null,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: _user!.avatarUrl != null
                          ? ClipOval(
                              child: Image.network(_user!.avatarUrl!,
                                  width: 100, height: 100, fit: BoxFit.cover),
                            )
                          : Text(
                              _user!.firstName.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _uploadAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                fullName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _user!.role.name,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildPersonalInfoCard(),
        const SizedBox(height: 24),
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Account Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const Divider(height: 1),
              _buildInfoRow('User ID', _user!.id, Icons.badge_outlined),
              const Divider(height: 1, indent: 54),
              _buildInfoRow(
                  'Family ID', _user!.familyId, Icons.family_restroom),
              const Divider(height: 1, indent: 54),
              _buildInfoRow(
                'Kid Mode',
                _user!.isKidMode == true ? 'Enabled' : 'Disabled',
                Icons.child_care,
              ),
              const Divider(height: 1, indent: 54),
              _buildInfoRow(
                'Member Since',
                '${_user!.createdAt.month}/${_user!.createdAt.day}/${_user!.createdAt.year}',
                Icons.calendar_today_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Personal Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(height: 1),
          _buildTextField(
            controller: _firstNameController,
            label: 'First Name',
            icon: Icons.person_outline,
            enabled: _isEditing,
          ),
          const Divider(height: 1, indent: 54),
          _buildTextField(
            controller: _lastNameController,
            label: 'Last Name',
            icon: Icons.person_outline,
            enabled: _isEditing,
          ),
          const Divider(height: 1, indent: 54),
          _buildTextField(
            controller: _birthplaceController,
            label: 'Birthplace',
            icon: Icons.location_on_outlined,
            enabled: _isEditing,
          ),
          const Divider(height: 1, indent: 54),
          _buildTextField(
            controller: _nationalityController,
            label: 'Nationality',
            icon: Icons.flag_outlined,
            enabled: _isEditing,
          ),
          const Divider(height: 1, indent: 54),
          _buildTextField(
            controller: _culturalHeritageController,
            label: 'Cultural Heritage',
            icon: Icons.public,
            enabled: _isEditing,
            maxLines: 3,
          ),
          if (_isEditing) ...[
            const Divider(height: 1, indent: 54),
            SwitchListTile(
              contentPadding: const EdgeInsets.all(16),
              secondary: Icon(Icons.child_care, color: Colors.grey.shade600),
              title: const Text('Kid Mode'),
              subtitle: const Text('Enable simplified interface'),
              value: _user?.isKidMode ?? false,
              onChanged: (v) {
                setState(() {
                  _user = _user!.copyWith(isKidMode: v);
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('Failed to load profile',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadUser,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthplaceController.dispose();
    _nationalityController.dispose();
    _culturalHeritageController.dispose();
    super.dispose();
  }
}
