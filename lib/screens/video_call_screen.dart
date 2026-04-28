import 'package:flutter/material.dart';
import '../models/family_user.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_status.dart';

class CallLog {
  final String id;
  final String callerId;
  final String receiverId;
  final bool isVideo;
  final int durationSeconds;
  final DateTime timestamp;
  final bool missed;

  CallLog({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.isVideo,
    required this.durationSeconds,
    required this.timestamp,
    required this.missed,
  });
}

class VideoCallScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const VideoCallScreen({super.key, required this.currentUser});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  List<FamilyUser> _familyMembers = [];
  bool _isInCall = false;
  String? _currentCallWith;
  List<CallLog> _callLogs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Calls'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: _isInCall ? _buildCallScreen() : _buildCallList(),
    );
  }

  Widget _buildCallList() {
    return ListView(
      children: [
        _buildHeader('Family Members'),
        if (_familyMembers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.video_call, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No family members to call'),
                  Text('Invite family to connect'),
                ],
              ),
            ),
          )
        else
          ..._familyMembers.map((m) => ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(m.firstName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
            ),
            title: Text(m.firstName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () => _startCall(m, false),
                  color: Colors.green,
                ),
                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: () => _startCall(m, true),
                  color: Colors.blue,
                ),
              ],
            ),
          )),
        const Divider(),
        _buildHeader('Recent Calls'),
        if (_callLogs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No recent calls'),
          )
        else
          ..._callLogs.take(10).map((log) => ListTile(
            leading: Icon(log.missed ? Icons.call_missed : Icons.call, 
              color: log.missed ? Colors.red : Colors.green),
            title: Text(log.missed ? 'Missed call' : 'Call'),
            subtitle: Text(_formatTime(log.timestamp)),
            trailing: Text('${_formatDuration(log.durationSeconds)}'),
          )),
      ],
    );
  }

  Widget _buildCallScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              _currentCallWith ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 8),
            const Text('00:00', style: TextStyle(color: Colors.white70, fontSize: 18)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallButton(Icons.mic_off, Colors.red, () {}),
                _buildCallButton(Icons.call_end, Colors.red, () => _endCall()),
                _buildCallButton(Icons.cameraswitch, Colors.blue, () {}),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton(IconData icon, Color color, VoidCallback onPressed) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: color,
      child: Icon(icon),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _startCall(FamilyUser user, bool isVideo) {
    setState(() {
      _isInCall = true;
      _currentCallWith = user.firstName;
    });
  }

  void _endCall() {
    setState(() {
      _isInCall = false;
      _currentCallWith = null;
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}