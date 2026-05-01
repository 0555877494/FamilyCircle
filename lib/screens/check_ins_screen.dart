import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../widgets/connection_status.dart';

enum CheckInStatus { safe, checkingIn, notResponding, emergency }

class CheckIn {
  final String id;
  final String familyId;
  final String memberId;
  final String memberName;
  final CheckInStatus status;
  final String? message;
  final String? location;
  final DateTime timestamp;

  CheckIn({
    required this.id,
    required this.familyId,
    required this.memberId,
    required this.memberName,
    required this.status,
    this.message,
    this.location,
    required this.timestamp,
  });
}

class CheckInsScreen extends StatefulWidget {
  final FamilyUser? currentUser;
  
  const CheckInsScreen({super.key, this.currentUser});

  @override
  State<CheckInsScreen> createState() => _CheckInsScreenState();
}

class _CheckInsScreenState extends State<CheckInsScreen> {
  List<CheckIn> _checkIns = [];
  final _uuid = const Uuid();
  bool _requestPending = false;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSampleCheckIns();
  }

  void _loadSampleCheckIns() {
    final now = DateTime.now();
    final familyId = widget.currentUser?.familyId ?? 'default_family';
    _checkIns = [
      CheckIn(id: 'check_001', familyId: familyId, memberId: 'user_001', memberName: 'John', status: CheckInStatus.safe, message: '👍 I\'m safe', location: 'Home', timestamp: now.subtract(const Duration(minutes: 15))),
      CheckIn(id: 'check_002', familyId: familyId, memberId: 'user_002', memberName: 'Jane', status: CheckInStatus.safe, message: '👍 I\'m safe', location: 'Grocery Store', timestamp: now.subtract(const Duration(minutes: 30))),
      CheckIn(id: 'check_003', familyId: familyId, memberId: 'user_003', memberName: 'Emma', status: CheckInStatus.safe, message: '🏫 At school', location: 'Elementary School', timestamp: now.subtract(const Duration(hours: 1))),
      CheckIn(id: 'check_004', familyId: familyId, memberId: 'user_005', memberName: 'Mary', status: CheckInStatus.safe, message: '💕 Doing great!', location: 'Grandma\'s House', timestamp: now.subtract(const Duration(hours: 2))),
    ];
    _pendingCount = 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-ins'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: _requestPending ? _buildPendingCheckIns() : _buildCheckInHistory(),
    );
  }

  Widget _buildPendingCheckIns() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 64, color: Colors.orange),
            const SizedBox(height: 24),
            const Text('Check-in Requested', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Waiting for $_pendingCount member(s) to respond', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => setState(() => _requestPending = false),
              child: const Text('Cancel Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInHistory() {
    return ListView(
      children: [
        _buildQuickCheckIn(),
        const Divider(),
        if (_checkIns.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.shield, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No check-ins yet', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          )
        else
          ..._checkIns.map((c) => _buildCheckInTile(c)),
        const Divider(),
        _buildRequestCheckIn(),
      ],
    );
  }

  Widget _buildQuickCheckIn() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Check-in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickButton(Icons.favorite, Colors.green, 'I\'m Safe', () => _doQuickCheckIn(CheckInStatus.safe)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickButton(Icons.warning, Colors.orange, 'Checking In', () => _doQuickCheckIn(CheckInStatus.checkingIn)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickButton(Icons.emergency, Colors.red, 'Emergency!', () => _doQuickCheckIn(CheckInStatus.emergency)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(IconData icon, Color color, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.all(12)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCheckInTile(CheckIn checkIn) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(checkIn.status).withValues(alpha: 0.2),
        child: Icon(_getStatusIcon(checkIn.status), color: _getStatusColor(checkIn.status)),
      ),
      title: Text(checkIn.memberName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_getStatusText(checkIn.status)),
          if (checkIn.message != null) Text(checkIn.message!),
          Text(_formatTime(checkIn.timestamp), style: const TextStyle(fontSize: 10)),
        ],
      ),
      trailing: _buildStatusBadge(checkIn.status),
    );
  }

  Widget _buildStatusBadge(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.safe: return const Chip(label: Text('Safe'), backgroundColor: Colors.green);
      case CheckInStatus.checkingIn: return const Chip(label: Text('Pending'), backgroundColor: Colors.orange);
      case CheckInStatus.notResponding: return const Chip(label: Text('No Response'), backgroundColor: Colors.red);
      case CheckInStatus.emergency: return const Chip(label: Text('EMERGENCY'), backgroundColor: Colors.red);
    }
  }

  Widget _buildRequestCheckIn() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Request Check-in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Request all family members to check in and confirm they are safe.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _requestCheckIn,
              child: const Text('Request Check-in'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.safe: return Colors.green;
      case CheckInStatus.checkingIn: return Colors.orange;
      case CheckInStatus.notResponding: return Colors.red;
      case CheckInStatus.emergency: return Colors.red;
    }
  }

  IconData _getStatusIcon(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.safe: return Icons.check_circle;
      case CheckInStatus.checkingIn: return Icons.hourglass_empty;
      case CheckInStatus.notResponding: return Icons.warning;
      case CheckInStatus.emergency: return Icons.emergency;
    }
  }

  String _getStatusText(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.safe: return 'Safe and sound';
      case CheckInStatus.checkingIn: return 'Checking in...';
      case CheckInStatus.notResponding: return 'Not responding';
      case CheckInStatus.emergency: return 'EMERGENCY';
    }
  }

  void _doQuickCheckIn(CheckInStatus status) {
    final currentUser = widget.currentUser;
    if (currentUser == null) return;
    
    final checkIn = CheckIn(
      id: _uuid.v4(),
      familyId: currentUser.familyId,
      memberId: currentUser.id,
      memberName: currentUser.firstName,
      status: status,
      message: status == CheckInStatus.emergency ? 'NEED HELP!' : null,
      timestamp: DateTime.now(),
    );
    setState(() => _checkIns.insert(0, checkIn));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checked in: ${_getStatusText(status)}')),
    );
  }

  void _requestCheckIn() {
    setState(() {
      _requestPending = true;
      _pendingCount = 3;
    });
  }

  String _formatTime(DateTime time) {
    return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}