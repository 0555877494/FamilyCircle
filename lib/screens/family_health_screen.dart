import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../services/file_service.dart';
import '../widgets/connection_status.dart';

enum HealthRecordType { checkup, illness, injury, medication, vaccination, dental, vision, mental, other }

class HealthRecord {
  final String id;
  final String familyId;
  final String memberId;
  final String title;
  final String? description;
  final HealthRecordType type;
  final String? provider;
  final String? location;
  final DateTime date;
  final double? temperature;
  final double? weight;
  final double? height;
  final List<String>? medicationIds;
  final List<String>? notes;
  final DateTime createdAt;

  HealthRecord({
    required this.id,
    required this.familyId,
    required this.memberId,
    required this.title,
    this.description,
    required this.type,
    this.provider,
    this.location,
    required this.date,
    this.temperature,
    this.weight,
    this.height,
    this.medicationIds,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'memberId': memberId,
      'title': title,
      'description': description,
      'type': type.name,
      'provider': provider,
      'location': location,
      'date': date.toIso8601String(),
      'temperature': temperature,
      'weight': weight,
      'height': height,
      'medicationIds': medicationIds,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      memberId: map['memberId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: HealthRecordType.values.firstWhere((e) => e.name == map['type']),
      provider: map['provider'] as String?,
      location: map['location'] as String?,
      date: DateTime.parse(map['date'] as String),
      temperature: (map['temperature'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
      medicationIds: map['medicationIds'] != null ? List<String>.from(map['medicationIds'] as List) : null,
      notes: map['notes'] != null ? List<String>.from(map['notes'] as List) : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class Medication {
  final String id;
  final String name;
  final String? dosage;
  final String? frequency;
  final List<TimeOfDay> times;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;

  Medication({
    required this.id,
    required this.name,
    this.dosage,
    this.frequency,
    this.times = const [],
    this.startDate,
    this.endDate,
    this.notes,
  });
}

class FamilyHealthScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const FamilyHealthScreen({super.key, required this.currentUser});

  @override
  State<FamilyHealthScreen> createState() => _FamilyHealthScreenState();
}

class _FamilyHealthScreenState extends State<FamilyHealthScreen> {
  List<HealthRecord> _records = [];
  final _uuid = const Uuid();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadSampleHealthRecords();
  }

  void _loadSampleHealthRecords() {
    final now = DateTime.now();
    _records = [
      HealthRecord(id: '1', familyId: widget.currentUser.familyId, memberId: widget.currentUser.id, title: 'Annual Physical', description: 'Routine yearly checkup', type: HealthRecordType.checkup, provider: 'Dr. Smith', location: 'City Medical Center', date: now.subtract(const Duration(days: 30)), temperature: 98.6, weight: 165, height: 70, createdAt: now),
      HealthRecord(id: '2', familyId: widget.currentUser.familyId, memberId: widget.currentUser.id, title: 'Flu', description: 'Seasonal flu symptoms', type: HealthRecordType.illness, provider: 'Dr. Johnson', location: 'Urgent Care', date: now.subtract(const Duration(days: 14)), temperature: 101.2, notes: ['Rest', 'Fluids', ' Tylenol'], createdAt: now),
      HealthRecord(id: '3', familyId: widget.currentUser.familyId, memberId: widget.currentUser.id, title: 'Tetanus shot', description: 'Booster update', type: HealthRecordType.vaccination, provider: 'CVS Pharmacy', date: now.subtract(const Duration(days: 60)), createdAt: now),
      HealthRecord(id: '4', familyId: widget.currentUser.familyId, memberId: 'child1', title: 'Broken arm', description: 'Fracture from playground fall', type: HealthRecordType.injury, provider: 'St. Mary\'s ER', location: 'Emergency Room', date: now.subtract(const Duration(days: 45)), notes: ['Cast for 6 weeks', 'Follow-up scheduled'], createdAt: now),
      HealthRecord(id: '5', familyId: widget.currentUser.familyId, memberId: widget.currentUser.id, title: 'Dental cleaning', description: 'Regular cleaning', type: HealthRecordType.dental, provider: 'Dr. Williams', location: 'Smile Dental', date: now.subtract(const Duration(days: 20)), createdAt: now),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Health'),
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
        onPressed: _showAddRecordDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Records', 'Medications', 'Vitals', 'Appointments'];
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

  Widget _buildCurrentTab() {
    switch (_selectedTab) {
      case 0: return _buildRecordsTab();
      case 1: return _buildMedicationsTab();
      case 2: return _buildVitalsTab();
      case 3: return _buildAppointmentsTab();
      default: return _buildRecordsTab();
    }
  }

  Widget _buildRecordsTab() {
    if (_records.isEmpty) return _buildEmptyState('No health records', Icons.medical_services);
    return ListView.builder(
      itemCount: _records.length,
      itemBuilder: (ctx, i) => _buildRecordCard(_records[i]),
    );
  }

  Widget _buildRecordCard(HealthRecord record) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(record.type).withOpacity(0.2),
          child: Icon(_getTypeIcon(record.type), color: _getTypeColor(record.type)),
        ),
        title: Text(record.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${record.type.name} | ${_formatDate(record.date)}'),
            if (record.provider != null) Text('Provider: ${record.provider}'),
          ],
        ),
        isThreeLine: record.provider != null,
      ),
    );
  }

  Widget _buildMedicationsTab() {
    return _buildEmptyState('No medications tracked', Icons.medication);
  }

  Widget _buildVitalsTab() {
    return _buildEmptyState('No vitals recorded', Icons.monitor_heart);
  }

  Widget _buildAppointmentsTab() {
    return _buildEmptyState('No appointments', Icons.calendar_month);
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Color _getTypeColor(HealthRecordType type) {
    switch (type) {
      case HealthRecordType.checkup: return Colors.blue;
      case HealthRecordType.illness: return Colors.orange;
      case HealthRecordType.injury: return Colors.red;
      case HealthRecordType.medication: return Colors.purple;
      case HealthRecordType.vaccination: return Colors.green;
      case HealthRecordType.dental: return Colors.teal;
      case HealthRecordType.vision: return Colors.indigo;
      case HealthRecordType.mental: return Colors.pink;
      case HealthRecordType.other: return Colors.grey;
    }
  }

  IconData _getTypeIcon(HealthRecordType type) {
    switch (type) {
      case HealthRecordType.checkup: return Icons.health_and_safety;
      case HealthRecordType.illness: return Icons.sick;
      case HealthRecordType.injury: return Icons.healing;
      case HealthRecordType.medication: return Icons.medication;
      case HealthRecordType.vaccination: return Icons.vaccines;
      case HealthRecordType.dental: return Icons.face;
      case HealthRecordType.vision: return Icons.visibility;
      case HealthRecordType.mental: return Icons.psychology;
      case HealthRecordType.other: return Icons.medical_services;
    }
  }

  void _showAddRecordDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final providerController = TextEditingController();
    HealthRecordType selectedType = HealthRecordType.checkup;
    DateTime selectedDate = DateTime.now();
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Health Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 8),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                const SizedBox(height: 8),
                DropdownButtonFormField<HealthRecordType>(
                  value: selectedType,
                  items: HealthRecordType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 8),
                TextField(controller: providerController, decoration: const InputDecoration(labelText: 'Healthcare Provider')),
                const SizedBox(height: 8),
                ListTile(
                  title: Text('Date: ${_formatDate(selectedDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setDialogState(() => selectedDate = date);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Attachments (Reports, Prescriptions)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Photo'),
                      onPressed: () => _pickFile(ctx),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
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
                if (titleController.text.isNotEmpty) {
                  final record = HealthRecord(
                    id: _uuid.v4(),
                    familyId: widget.currentUser.familyId,
                    memberId: widget.currentUser.id,
                    title: titleController.text,
                    description: descController.text.isEmpty ? null : descController.text,
                    type: selectedType,
                    provider: providerController.text.isEmpty ? null : providerController.text,
                    date: selectedDate,
                    createdAt: DateTime.now(),
                  );
                  setState(() => _records.add(record));
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