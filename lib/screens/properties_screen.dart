import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../models/family_user.dart';
import '../models/family_property.dart';
import '../services/family_service.dart';
import '../services/location_service.dart';
import '../services/file_service.dart';
import '../widgets/connection_status.dart';

class PropertiesScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const PropertiesScreen({super.key, required this.currentUser});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  List<FamilyProperty> _properties = [];
  final _uuid = const Uuid();
  int _selectedFilter = 0;
  bool _showAllValues = false;

  @override
  void initState() {
    super.initState();
    _loadSampleProperties();
  }

  void _loadSampleProperties() {
    try {
      final service = context.read<FamilyService>();
      service.getFamilyStream(widget.currentUser.familyId).listen((family) {
        if (family != null && mounted) {
          setState(() => _properties = family.properties);
        }
      });
    } catch (e) {
      _loadFromMemory();
    }
  }

  void _loadFromMemory() {
    final now = DateTime.now();
    _properties = [
      FamilyProperty(id: '1', familyId: widget.currentUser.familyId, name: 'Family Home', description: 'Our forever home', type: PropertyType.realEstate, location: '123 Maple Street, Springfield, IL', value: '350000', notes: 'Bought in 2018', createdAt: now),
      FamilyProperty(id: '2', familyId: widget.currentUser.familyId, name: 'Cabin', description: 'Weekend getaway', type: PropertyType.realEstate, location: '45 Lake Road, Big Bear, CA', value: '275000', notes: 'Family favorite!', createdAt: now),
      FamilyProperty(id: '3', familyId: widget.currentUser.familyId, name: 'Honda Accord 2020', description: 'Primary family car', type: PropertyType.vehicle, location: '123 Maple Street', value: '25000', notes: 'Well maintained', createdAt: now),
      FamilyProperty(id: '4', familyId: widget.currentUser.familyId, name: 'Investment Account', description: '401k and IRA', type: PropertyType.investment, value: '150000', notes: 'Retirement savings', createdAt: now),
      FamilyProperty(id: '5', familyId: widget.currentUser.familyId, name: 'Wedding Rings', description: '20th anniversary bands', type: PropertyType.valuable, value: '5000', createdAt: now),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Properties'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildPropertyList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPropertyDialog,
        child: const Icon(Icons.add_business),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Real Estate', 'Vehicles', 'Accounts', 'Valuables', 'Documents'];
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: List.generate(filters.length, (i) => 
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filters[i]),
                  selected: _selectedFilter == i,
                  onSelected: (s) => setState(() => _selectedFilter = i),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('${_properties.length} properties', style: TextStyle(color: Colors.grey[600])),
              const Spacer(),
              Row(
                children: [
                  const Text('Show values'),
                  Switch(value: _showAllValues, onChanged: (v) => setState(() => _showAllValues = v)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyList() {
    final filtered = _getFilteredProperties();
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => _buildPropertyCard(filtered[i]),
    );
  }

  List<FamilyProperty> _getFilteredProperties() {
    final typeFilters = [
      PropertyType.realEstate, PropertyType.vehicle, PropertyType.bankAccount,
      PropertyType.investment, PropertyType.valuable, PropertyType.document,
    ];
    if (_selectedFilter == 0) return _properties;
    if (_selectedFilter - 1 < typeFilters.length) {
      return _properties.where((p) => p.type == typeFilters[_selectedFilter - 1]).toList();
    }
    return _properties;
  }

  Widget _buildPropertyCard(FamilyProperty property) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(property.type).withValues(alpha: 0.2),
          child: Icon(_getTypeIcon(property.type), color: _getTypeColor(property.type)),
        ),
        title: Text(property.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(property.type.name.toUpperCase()),
            if (property.location != null) Row(
              children: [
                Icon(Icons.location_on, size: 12),
                Text(' ${property.location}', style: const TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
        trailing: property.lastVerified != null 
            ? Chip(
                label: Text(_formatDate(property.lastVerified!), style: const TextStyle(fontSize: 10)),
backgroundColor: _isVerifiedRecently(property.lastVerified!) 
                     ? Colors.green.withValues(alpha: 0.2) 
                     : Colors.orange.withValues(alpha: 0.2),
              )
            : Chip(
                label: const Text('UNVERIFIED', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.red.withValues(alpha: 0.2),
              ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (property.description != null) ...[
                  const Text('Description'),
                  Text(property.description!),
                  const SizedBox(height: 8),
                ],
                if (property.value != null && _showAllValues) ...[
                  const Text('Estimated Value'),
                  Text(property.value!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                ],
                if (property.institution != null) ...[
                  const Text('Institution/Company'),
                  Text(property.institution!),
                  const SizedBox(height: 8),
                ],
                if (property.accountNumber != null) ...[
                  const Text('Account/Reference #'),
                  Text(property.accountNumber!),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    const Text('Contact: '),
                    if (property.contactPhone != null) Text(property.contactPhone!),
                    if (property.contactEmail != null) Text(' | ${property.contactEmail}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Access: '),
                    Text(property.accessLevel.name),
                  ],
                ),
                if (property.notes != null) ...[
                  const SizedBox(height: 8),
                  const Text('Notes'),
                  Text(property.notes!),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.verified),
                      label: const Text('Mark Verified'),
                      onPressed: () => _markVerified(property),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editProperty(property),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProperty(property),
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

  bool _isVerifiedRecently(DateTime lastVerified) {
    final now = DateTime.now();
    return now.difference(lastVerified).inDays < 90;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No properties recorded'),
          const SizedBox(height: 8),
          const Text('Track home, vehicles, bank accounts, etc.'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_business),
            label: const Text('Add First Property'),
            onPressed: _showAddPropertyDialog,
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(PropertyType type) {
    switch (type) {
      case PropertyType.realEstate: return Colors.brown;
      case PropertyType.vehicle: return Colors.blue;
      case PropertyType.bankAccount: return Colors.green;
      case PropertyType.investment: return Colors.teal;
      case PropertyType.safeDepositBox: return Colors.amber;
      case PropertyType.valuable: return Colors.purple;
      case PropertyType.document: return Colors.orange;
      case PropertyType.insurance: return Colors.red;
      case PropertyType.subscription: return Colors.pink;
      case PropertyType.digitalAccount: return Colors.indigo;
      case PropertyType.other: return Colors.grey;
    }
  }

  IconData _getTypeIcon(PropertyType type) {
    switch (type) {
      case PropertyType.realEstate: return Icons.home;
      case PropertyType.vehicle: return Icons.directions_car;
      case PropertyType.bankAccount: return Icons.account_balance;
      case PropertyType.investment: return Icons.trending_up;
      case PropertyType.safeDepositBox: return Icons.lock;
      case PropertyType.valuable: return Icons.diamond;
      case PropertyType.document: return Icons.description;
      case PropertyType.insurance: return Icons.security;
      case PropertyType.subscription: return Icons.subscriptions;
      case PropertyType.digitalAccount: return Icons.cloud;
      case PropertyType.other: return Icons.category;
    }
  }

  void _markVerified(FamilyProperty property) {
    final updated = property.copyWith(lastVerified: DateTime.now());
    setState(() {
      _properties = _properties.where((p) => p.id != property.id).toList()..add(updated);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Property verified!')),
    );
  }

  void _deleteProperty(FamilyProperty property) {
    setState(() => _properties.removeWhere((p) => p.id == property.id));
  }

  void _editProperty(FamilyProperty property) {
    _showAddPropertyDialog(existing: property);
  }

  void _showAddPropertyDialog({FamilyProperty? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');
    final valueController = TextEditingController(text: existing?.value ?? '');
    final institutionController = TextEditingController(text: existing?.institution ?? '');
    final accountController = TextEditingController(text: existing?.accountNumber ?? '');
    final locationController = TextEditingController(text: existing?.location ?? '');
    final phoneController = TextEditingController(text: existing?.contactPhone ?? '');
    final emailController = TextEditingController(text: existing?.contactEmail ?? '');
    final notesController = TextEditingController(text: existing?.notes ?? '');
    PropertyType selectedType = existing?.type ?? PropertyType.other;
    PropertyAccess selectedAccess = existing?.accessLevel ?? PropertyAccess.anyone;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing != null ? 'Edit Property' : 'Add Property'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Property Name *')),
                const SizedBox(height: 8),
                DropdownButtonFormField<PropertyType>(
                  value: selectedType,
                  items: PropertyType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 8),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                const SizedBox(height: 8),
                TextField(controller: valueController, decoration: const InputDecoration(labelText: 'Estimated Value')),
                const SizedBox(height: 8),
                TextField(controller: locationController, 
                  decoration: const InputDecoration(labelText: 'Location/Address'),
                  onChanged: (v) => locationController.text = v,
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text('Get GPS Location'),
                  onPressed: () async {
                    try {
                      final locationService = LocationService();
                      final position = await locationService.getCurrentLocation();
                      if (position != null) {
                        final address = await locationService.getAddressFromCoordinates(
                          position.latitude,
                          position.longitude,
                        );
                        setDialogState(() {
                          locationController.text = address ?? 
                            '${position.latitude}, ${position.longitude}';
                        });
                      }
                    } catch (e) {}
                  },
                ),
                const SizedBox(height: 8),
                TextField(controller: institutionController, decoration: const InputDecoration(labelText: 'Bank/Institution/Company')),
                const SizedBox(height: 8),
                TextField(controller: accountController, decoration: const InputDecoration(labelText: 'Account/Reference Number')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<PropertyAccess>(
                  value: selectedAccess,
                  items: PropertyAccess.values.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedAccess = v!),
                  decoration: const InputDecoration(labelText: 'Access Level'),
                ),
                const SizedBox(height: 8),
                TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 3),
                const SizedBox(height: 16),
                const Text('Attachments (Insurance, Deeds, Documents)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Photo'),
                      onPressed: () => _pickFile(ctx, 'photo'),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: () => _pickFile(ctx, 'camera'),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.description),
                      label: const Text('Document'),
                      onPressed: () => _pickFile(ctx, 'document'),
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
                if (nameController.text.isNotEmpty) {
                  final property = FamilyProperty(
                    id: existing?.id ?? _uuid.v4(),
                    familyId: widget.currentUser.familyId,
                    name: nameController.text,
                    description: descController.text.isEmpty ? null : descController.text,
                    type: selectedType,
                    location: locationController.text.isEmpty ? null : locationController.text,
                    value: valueController.text.isEmpty ? null : valueController.text,
                    institution: institutionController.text.isEmpty ? null : institutionController.text,
                    accountNumber: accountController.text.isEmpty ? null : accountController.text,
                    contactPhone: phoneController.text.isEmpty ? null : phoneController.text,
                    contactEmail: emailController.text.isEmpty ? null : emailController.text,
                    accessLevel: selectedAccess,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                    addedById: widget.currentUser.id,
                    createdAt: existing?.createdAt ?? DateTime.now(),
                    lastVerified: existing?.lastVerified,
                  );
                  setState(() {
                    if (existing != null) {
                      _properties = _properties.where((p) => p.id != existing.id).toList();
                    }
                    _properties.add(property);
                  });
                  Navigator.pop(ctx);
                }
              },
              child: Text(existing != null ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _pickFile(BuildContext ctx, String source) async {
    final fileService = FileService();
    UploadedFile? file;
    
    if (source == 'photo') {
      file = await fileService.pickAndUploadImage(
        widget.currentUser.familyId,
        widget.currentUser.id,
        widget.currentUser.firstName,
      );
    } else if (source == 'camera') {
      file = await fileService.captureAndUploadImage(
        widget.currentUser.familyId,
        widget.currentUser.id,
        widget.currentUser.firstName,
      );
    } else if (source == 'document') {
      file = await fileService.pickAndUploadDocument(
        widget.currentUser.familyId,
        widget.currentUser.id,
        widget.currentUser.firstName,
      );
    }
    
    if (file != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Uploaded: ${file.name}')),
      );
    }
  }
}