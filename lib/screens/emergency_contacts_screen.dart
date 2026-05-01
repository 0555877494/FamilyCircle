import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../services/file_service.dart';
import '../widgets/connection_status.dart';

enum ContactType { emergency, medical, school, doctor, relative, neighbor, work }

class EmergencyContact {
  final String id;
  final String familyId;
  final String name;
  final String relationship;
  final String phone;
  final String? email;
  final ContactType type;
  final String? address;
  final bool isPrimary;
  final DateTime createdAt;

  EmergencyContact({
    required this.id,
    required this.familyId,
    required this.name,
    required this.relationship,
    required this.phone,
    this.email,
    required this.type,
    this.address,
    this.isPrimary = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'email': email,
      'type': type.name,
      'address': address,
      'isPrimary': isPrimary,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      name: map['name'] as String,
      relationship: map['relationship'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      type: ContactType.values.firstWhere((e) => e.name == map['type']),
      address: map['address'] as String?,
      isPrimary: map['isPrimary'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class EmergencyContactsScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const EmergencyContactsScreen({super.key, required this.currentUser});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<EmergencyContact> _contacts = [];
  final _uuid = const Uuid();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadSampleContacts();
  }

  void _loadSampleContacts() {
    _contacts = [
      EmergencyContact(id: 'emg_001', familyId: widget.currentUser.familyId, name: '🚑 Emergency Services', phone: '911', relationship: 'Emergency', type: ContactType.emergency, createdAt: DateTime.now()),
      EmergencyContact(id: 'emg_002', familyId: widget.currentUser.familyId, name: '🏥 Dr. Sarah Smith', phone: '555-1000', email: 'dr.smith@clinic.com', relationship: 'Doctor', type: ContactType.medical, createdAt: DateTime.now()),
      EmergencyContact(id: 'emg_003', familyId: widget.currentUser.familyId, name: '👨‍🔧 Neighbor - Bob Wilson', phone: '555-2000', relationship: 'Neighbor', type: ContactType.neighbor, address: '125 Maple St', createdAt: DateTime.now()),
      EmergencyContact(id: 'emg_004', familyId: widget.currentUser.familyId, name: '🧑‍⚕️ Urgent Care', phone: '555-3000', relationship: 'Medical', type: ContactType.medical, createdAt: DateTime.now()),
      EmergencyContact(id: 'emg_005', familyId: widget.currentUser.familyId, name: '🚒 Fire Station #5', phone: '555-4000', relationship: 'Fire', type: ContactType.emergency, createdAt: DateTime.now()),
      EmergencyContact(id: 'emg_006', familyId: widget.currentUser.familyId, name: '🏫 Emma\'s School', phone: '555-5000', relationship: 'School', type: ContactType.school, address: '456 School Lane', createdAt: DateTime.now()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildContactList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['All', 'Medical', 'School', 'Family'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: List.generate(tabs.length, (i) => 
          Padding(
            padding: const EdgeInsets.only(right: 8),
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

  Widget _buildContactList() {
    if (_contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contact_phone, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No emergency contacts'),
            const SizedBox(height: 8),
            Text('Add contacts for emergencies'),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (ctx, i) => _buildContactCard(_contacts[i]),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
backgroundColor: contact.isPrimary 
             ? Colors.red.withValues(alpha: 0.2)
             : _getTypeColor(contact.type).withValues(alpha: 0.2),
          child: Icon(
            _getTypeIcon(contact.type), 
            color: contact.isPrimary ? Colors.red : _getTypeColor(contact.type),
          ),
        ),
        title: Row(
          children: [
            Text(contact.name),
            if (contact.isPrimary) ...[
              const SizedBox(width: 8),
              const Chip(label: Text('PRIMARY', style: TextStyle(fontSize: 10)), backgroundColor: Colors.red),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${contact.relationship} | ${contact.type.name}'),
            Row(
              children: [
                Icon(Icons.phone, size: 14),
                Text(' ${contact.phone}'),
              ],
            ),
            if (contact.email != null) Row(
              children: [
                Icon(Icons.email, size: 14),
                Text(' ${contact.email}'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: () {},
        ),
        onLongPress: () => _deleteContact(contact),
      ),
    );
  }

  Color _getTypeColor(ContactType type) {
    switch (type) {
      case ContactType.emergency: return Colors.red;
      case ContactType.medical: return Colors.blue;
      case ContactType.school: return Colors.purple;
      case ContactType.doctor: return Colors.teal;
      case ContactType.relative: return Colors.orange;
      case ContactType.neighbor: return Colors.green;
      case ContactType.work: return Colors.indigo;
    }
  }

  IconData _getTypeIcon(ContactType type) {
    switch (type) {
      case ContactType.emergency: return Icons.emergency;
      case ContactType.medical: return Icons.medical_services;
      case ContactType.school: return Icons.school;
      case ContactType.doctor: return Icons.local_hospital;
      case ContactType.relative: return Icons.family_restroom;
      case ContactType.neighbor: return Icons.house;
      case ContactType.work: return Icons.work;
    }
  }

  void _deleteContact(EmergencyContact contact) {
    setState(() => _contacts.removeWhere((c) => c.id == contact.id));
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final relController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    ContactType selectedType = ContactType.emergency;
    bool isPrimary = false;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 8),
                TextField(controller: relController, decoration: const InputDecoration(labelText: 'Relationship')),
                const SizedBox(height: 8),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
                const SizedBox(height: 8),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 8),
                DropdownButtonFormField<ContactType>(
                  value: selectedType,
                  items: ContactType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Primary Contact'),
                  value: isPrimary,
                  onChanged: (v) => setDialogState(() => isPrimary = v),
                ),
                const SizedBox(height: 16),
                const Text('ID/Document Upload', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.badge),
                      label: const Text('ID Photo'),
                      onPressed: () => _pickFile(ctx),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.description),
                      label: const Text('Document'),
                      onPressed: () => _pickFile(ctx),
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
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  final contact = EmergencyContact(
                    id: _uuid.v4(),
                    familyId: widget.currentUser.familyId,
                    name: nameController.text,
                    relationship: relController.text,
                    phone: phoneController.text,
                    email: emailController.text.isEmpty ? null : emailController.text,
                    type: selectedType,
                    isPrimary: isPrimary,
                    createdAt: DateTime.now(),
                  );
                  setState(() => _contacts.add(contact));
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

  Future<void> _pickFile(BuildContext ctx) async {
    final fileService = FileService();
    final file = await fileService.pickAndUploadImage(
      widget.currentUser.familyId,
      widget.currentUser.id,
      widget.currentUser.firstName,
    );
    
    if (file != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Uploaded: ${file.name}')),
      );
    }
  }
}