import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_status.dart';

class SafeZone {
  final String id;
  final String familyId;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool isActive;
  final List<String> memberIds;
  final List<String> notifyIds;
  final DateTime createdAt;

  SafeZone({
    required this.id,
    required this.familyId,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 100,
    this.isActive = true,
    required this.memberIds,
    required this.notifyIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'isActive': isActive,
      'memberIds': memberIds,
      'notifyIds': notifyIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SafeZone.fromMap(Map<String, dynamic> map) {
    return SafeZone(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      name: map['name'] as String,
      address: map['address'] as String?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      radiusMeters: (map['radiusMeters'] as num?)?.toDouble() ?? 100,
      isActive: map['isActive'] as bool? ?? true,
      memberIds: List<String>.from(map['memberIds'] as List),
      notifyIds: List<String>.from(map['notifyIds'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class LocationAlert {
  final String id;
  final String familyId;
  final String memberId;
  final String? safeZoneId;
  final double latitude;
  final double longitude;
  final bool isEntering;
  final DateTime timestamp;

  LocationAlert({
    required this.id,
    required this.familyId,
    required this.memberId,
    this.safeZoneId,
    required this.latitude,
    required this.longitude,
    required this.isEntering,
    required this.timestamp,
  });
}

class SafeZonesScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const SafeZonesScreen({super.key, required this.currentUser});

  @override
  State<SafeZonesScreen> createState() => _SafeZonesScreenState();
}

class _SafeZonesScreenState extends State<SafeZonesScreen> {
  List<SafeZone> _zones = [];
  List<LocationAlert> _alerts = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadSampleZones();
  }

  void _loadSampleZones() {
    final now = DateTime.now();
    _zones = [
      SafeZone(id: 'zone_001', familyId: widget.currentUser.familyId, name: '🏠 Home', address: '123 Maple Street', latitude: 39.7817, longitude: -89.6501, radiusMeters: 100, memberIds: ['user_001', 'user_002', 'user_003', 'user_004'], notifyIds: ['user_001', 'user_002'], createdAt: now),
      SafeZone(id: 'zone_002', familyId: widget.currentUser.familyId, name: '🏫 Emma\'s School', address: '456 School Lane', latitude: 39.7830, longitude: -89.6450, radiusMeters: 50, memberIds: ['user_003'], notifyIds: ['user_001', 'user_002'], createdAt: now),
      SafeZone(id: 'zone_003', familyId: widget.currentUser.familyId, name: '👵 Grandma\'s House', address: '789 Oak Avenue', latitude: 39.7900, longitude: -89.6600, radiusMeters: 75, memberIds: ['user_001', 'user_002', 'user_003', 'user_004'], notifyIds: ['user_005'], createdAt: now),
      SafeZone(id: 'zone_004', familyId: widget.currentUser.familyId, name: '⚽ Soccer Field', address: 'Park District', latitude: 39.7850, longitude: -89.6400, radiusMeters: 30, memberIds: ['user_003'], notifyIds: ['user_001', 'user_002'], createdAt: now),
    ];
    _alerts = [
      LocationAlert(id: 'alert_001', familyId: widget.currentUser.familyId, memberId: 'user_003', latitude: 39.7817, longitude: -89.6501, isEntering: true, timestamp: now.subtract(const Duration(minutes: 30))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Zones'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: Column(
        children: [
          if (_alerts.isNotEmpty) _buildAlertsSection(),
          Expanded(
            child: _zones.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _zones.length,
                  itemBuilder: (ctx, i) => _buildZoneCard(_zones[i]),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddZoneDialog,
        child: const Icon(Icons.add_location),
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.red.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Alerts', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 4),
          ..._alerts.take(3).map((a) => ListTile(
            dense: true,
            leading: Icon(a.isEntering ? Icons.login : Icons.logout, color: Colors.red),
            title: Text(a.isEntering ? 'Entered zone' : 'Left zone'),
            subtitle: Text(_formatTime(a.timestamp)),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No safe zones set', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Add locations for location alerts', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildZoneCard(SafeZone zone) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.location_on, color: zone.isActive ? Colors.green : Colors.grey),
        title: Text(zone.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (zone.address != null) Text(zone.address!),
            Text('Radius: ${zone.radiusMeters.toInt()}m'),
          ],
        ),
        trailing: Switch(
          value: zone.isActive,
          onChanged: (v) => _toggleZone(zone),
        ),
        onLongPress: () => _deleteZone(zone),
      ),
    );
  }

  void _toggleZone(SafeZone zone) {
    setState(() {
      _zones = _zones.where((z) => z.id != zone.id).toList()
        ..add(SafeZone(
          id: zone.id,
          familyId: zone.familyId,
          name: zone.name,
          address: zone.address,
          latitude: zone.latitude,
          longitude: zone.longitude,
          radiusMeters: zone.radiusMeters,
          isActive: !zone.isActive,
          memberIds: zone.memberIds,
          notifyIds: zone.notifyIds,
          createdAt: zone.createdAt,
        ));
    });
  }

  void _deleteZone(SafeZone zone) {
    setState(() => _zones.removeWhere((z) => z.id == zone.id));
  }

  void _showAddZoneDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    double radius = 100;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Safe Zone'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Zone Name')),
                const SizedBox(height: 8),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Radius: '),
                    Expanded(child: Slider(value: radius, min: 50, max: 500, divisions: 9, onChanged: (v) => setDialogState(() => radius = v))),
                    Text('${radius.toInt()}m'),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Set location on map for precise coordinates', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final zone = SafeZone(
                    id: _uuid.v4(),
                    familyId: widget.currentUser.familyId,
                    name: nameController.text,
                    address: addressController.text.isEmpty ? null : addressController.text,
                    latitude: 37.7749,
                    longitude: -122.4194,
                    radiusMeters: radius,
                    memberIds: [widget.currentUser.id],
                    notifyIds: [widget.currentUser.id],
                    createdAt: DateTime.now(),
                  );
                  setState(() => _zones.add(zone));
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

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}