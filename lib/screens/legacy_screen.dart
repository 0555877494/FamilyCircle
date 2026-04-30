import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../models/death_record.dart';
import '../models/extended_health_event.dart';
import '../models/family_gathering.dart';
import '../models/wedding.dart';
import '../models/funeral.dart';
import '../models/family_history.dart';
import '../models/family_legacy.dart';
import '../services/file_service.dart';
import '../widgets/connection_status.dart';
import '../theme/app_colors.dart';
import '../theme/modern_ui.dart';

class LegacyScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const LegacyScreen({super.key, required this.currentUser});

  @override
  State<LegacyScreen> createState() => _LegacyScreenState();
}

class _LegacyScreenState extends State<LegacyScreen> {
  final _uuid = const Uuid();
  int _selectedSection = 0;

  List<DeathRecord> _deathRecords = [];
  List<ExtendedHealthEvent> _healthEvents = [];
  List<FamilyGathering> _gatherings = [];
  List<Wedding> _weddings = [];
  List<Funeral> _funerals = [];
  List<FamilyHistoryEntry> _historyItems = [];
  List<FamilyHeirloom> _heirlooms = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    _deathRecords = [
      DeathRecord(id: '1', familyId: widget.currentUser.familyId, memberId: 'grandpa1', memberName: 'Robert Smith', dateOfDeath: now.subtract(const Duration(days: 365 * 3)), funeralDate: now.subtract(const Duration(days: 365 * 3 - 2)), funeralLocation: 'Oak Hill Chapel', cemeteryPlot: 'Plot 45A', estateExecutor: 'parent1', createdAt: now),
    ];
    _healthEvents = [
      ExtendedHealthEvent(id: '1', familyId: widget.currentUser.familyId, memberId: 'parent1', memberName: 'John', title: 'Heart Surgery', description: 'Triple bypass', type: HealthEventType.surgery, date: now.subtract(const Duration(days: 180)), facility: 'St. Mary\'s Hospital', notes: 'Successful procedure', createdAt: now),
      ExtendedHealthEvent(id: '2', familyId: widget.currentUser.familyId, memberId: 'grandma1', memberName: 'Mary', title: 'Diabetes Diagnosis', description: 'Type 2 Diabetes', type: HealthEventType.chronicCondition, date: now.subtract(const Duration(days: 400)), notes: 'Managing with diet and medication', createdAt: now),
    ];
    _gatherings = [
      FamilyGathering(id: '1', familyId: widget.currentUser.familyId, title: 'Thanksgiving 2024', type: GatheringType.holiday, location: '123 Maple Street', date: now.subtract(const Duration(days: 150)), hostName: 'Jane', attendeeIds: ['parent1', 'parent2', 'child1', 'child2', 'grandma1'], attendeeNames: ['John', 'Jane', 'Emma', 'Tom', 'Mary'], notes: 'Great food!', createdAt: now),
      FamilyGathering(id: '2', familyId: widget.currentUser.familyId, title: 'Emma\'s 5th Birthday', type: GatheringType.birthday, location: 'Central Park', date: now.subtract(const Duration(days: 30)), hostName: 'Jane', attendeeIds: ['parent1', 'parent2', 'child1', 'grandma1', 'grandpa1'], attendeeNames: ['John', 'Jane', 'Emma', 'Mary', 'Bob'], notes: 'Princess theme', createdAt: now),
    ];
    _weddings = [
      Wedding(id: '1', familyId: widget.currentUser.familyId, partner1Name: 'John', partner2Name: 'Jane', weddingDate: now.subtract(const Duration(days: 365 * 15)), venue: 'Rose Garden', guestList: List.generate(150, (i) => 'Guest $i'), officiant: 'Pastor Williams', notes: 'Beautiful summer wedding', createdAt: now),
    ];
    _funerals = [
      Funeral(id: '1', familyId: widget.currentUser.familyId, deceasedName: 'Robert Smith', type: FuneralType.memorial, serviceDate: now.subtract(const Duration(days: 365 * 3 - 2)), serviceLocation: 'Oak Hill Chapel', officiant: 'Pastor Williams', notes: 'Full house', createdAt: now),
    ];
    _historyItems = [
      FamilyHistoryEntry(id: '1', familyId: widget.currentUser.familyId, title: 'Family origins', description: 'Our ancestors arrived from Ireland in 1850', type: HistoricalEventType.immigration, date: now.subtract(const Duration(days: 365 * 174)), location: 'Boston, MA', originCountry: 'Ireland', destinationCountry: 'USA', createdAt: now),
    ];
    _heirlooms = [
      FamilyHeirloom(id: '1', familyId: widget.currentUser.familyId, name: 'Grandma\'s Wedding Dress', description: 'Handmade lace dress worn by generations', category: HeirloomCategory.clothing, status: HeirloomStatus.inFamily, currentHolderId: 'parent2', currentHolderName: 'Jane', generationPassed: 4, createdAt: now),
      FamilyHeirloom(id: '2', familyId: widget.currentUser.familyId, name: 'Antique Piano', description: 'Steinway from 1920', category: HeirloomCategory.instrument, status: HeirloomStatus.inFamily, currentHolderId: 'parent1', currentHolderName: 'John', generationPassed: 3, createdAt: now),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Legacy'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: Column(
        children: [
          _buildSectionTabs(),
          Expanded(child: _buildCurrentSection()),
        ],
      ),
    );
  }

  Widget _buildSectionTabs() {
    final sections = ['Deaths', 'Health', 'Gatherings', 'Weddings', 'Funerals', 'History', 'Heirlooms'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: List.generate(sections.length, (i) => 
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(sections[i]),
              selected: _selectedSection == i,
              onSelected: (s) => setState(() => _selectedSection = i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_selectedSection) {
      case 0: return _buildDeathsSection();
      case 1: return _buildHealthSection();
      case 2: return _buildGatheringsSection();
      case 3: return _buildWeddingsSection();
      case 4: return _buildFuneralsSection();
      case 5: return _buildHistorySection();
      case 6: return _buildHeirloomsSection();
      default: return _buildDeathsSection();
    }
  }

  Widget _buildDeathsSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeatureCard(
          'Death Records',
          'Track deceased family members, estate info, funeral details',
          Icons.airline_seat_flat,
          () => _showAddDialog('Add Death Record'),
        ),
        _buildFeatureCard(
          'Memorials',
          'Funeral, memorial service information',
          Icons.church,
          () => _showAddDialog('Add Memorial'),
        ),
      ],
    );
  }

  Widget _buildHealthSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeatureCard(
          'Extended Health Events',
          'Hospitalizations, surgeries, diagnoses, allergies',
          Icons.local_hospital,
          () => _showAddDialog('Add Health Event'),
        ),
        _buildFeatureCard(
          'Medications',
          'Current medications and dosages',
          Icons.medication,
          () => _showAddDialog('Add Medication'),
        ),
        _buildFeatureCard(
          'Allergies',
          'Family allergies and sensitivities',
          Icons.warning_amber,
          () => _showAddDialog('Add Allergy'),
        ),
      ],
    );
  }

  Widget _buildGatheringsSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeatureCard(
          'Family Gatherings',
          'Reunions, holidays, BBQs, parties',
          Icons.groups,
          () => _showAddDialog('Add Gathering'),
        ),
        _buildFeatureCard(
          'Photos & Videos',
          'Event photos and videos',
          Icons.photo_library,
          () => _showAddDialog('Add Photos'),
        ),
        _buildFeatureCard(
          'Recipes',
          'Traditional family recipes',
          Icons.restaurant_menu,
          () => _showAddDialog('Add Recipe'),
        ),
      ],
    );
  }

  Widget _buildWeddingsSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeatureCard(
          'Wedding Records',
          'Wedding details, venues, vendors',
          Icons.favorite,
          () => _showAddDialog('Add Wedding'),
        ),
        _buildFeatureCard(
          'Photo Gallery',
          'Wedding photos and videos',
          Icons.photo_camera,
          () => _showAddDialog('Add Photos'),
        ),
        _buildFeatureCard(
          'Guest Lists',
          'Wedding guest lists',
          Icons.people,
          () => _showAddDialog('Add Guest List'),
        ),
      ],
    );
  }

  Widget _buildFuneralsSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeatureCard(
          'Funeral Records',
          'Funeral and memorial service info',
          Icons.church,
          () => _showAddDialog('Add Funeral'),
        ),
        _buildFeatureCard(
          'Obituaries',
          'Written obituaries and tributes',
          Icons.article,
          () => _showAddDialog('Add Obituary'),
        ),
        _buildFeatureCard(
          'Photos & Videos',
          'Funeral photos and videos',
          Icons.photo_library,
          () => _showAddDialog('Add Photos'),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeatureCard(
          'Family History',
          'Major family events through time',
          Icons.history_edu,
          () => _showAddDialog('Add History Entry'),
        ),
        _buildFeatureCard(
          'Immigration',
          'Origin stories, arrival info',
          Icons.flight,
          () => _showAddDialog('Add Immigration'),
        ),
        _buildFeatureCard(
          'Military Records',
          'Family veterans, service history',
          Icons.military_tech,
          () => _showAddDialog('Add Military'),
        ),
        _buildFeatureCard(
          'Education',
          'Schools, degrees, alumni',
          Icons.school,
          () => _showAddDialog('Add Education'),
        ),
        _buildFeatureCard(
          'Lineage',
          'Origin country, traditions, languages',
          Icons.account_tree,
          () => _showAddDialog('Add Lineage'),
        ),
      ],
    );
  }

  Widget _buildHeirloomsSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeatureCard(
          'Family Heirlooms',
          'Inherited items, value, history',
          Icons.diamond,
          () => _showAddDialog('Add Heirloom'),
        ),
        _buildFeatureCard(
          'Recipes',
          'Secret family recipes',
          Icons.menu_book,
          () => _showAddDialog('Add Recipe'),
        ),
        _buildFeatureCard(
          'Award & Achievements',
          'Family accomplishments',
          Icons.emoji_events,
          () => _showAddDialog('Add Award'),
        ),
        _buildFeatureCard(
          'Business History',
          'Family businesses through generations',
          Icons.business,
          () => _showAddDialog('Add Business'),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return HoverCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(String title) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add $title'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name/Title',
                  hintText: 'Enter a title for this record',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Add details about this record',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text('Add Media', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Gallery'),
                    onPressed: () => _pickFile(ctx, 'photo'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Camera'),
                    onPressed: () => _pickFile(ctx, 'camera'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.videocam, size: 18),
                    label: const Text('Video'),
                    onPressed: () => _pickFile(ctx, 'video'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.description, size: 18),
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
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title added successfully')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
    } else if (source == 'video') {
      file = await fileService.pickAndUploadVideo(
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