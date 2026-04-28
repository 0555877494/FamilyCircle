import 'package:flutter/material.dart';
import '../services/connection_service.dart';
import '../services/bluetooth_service.dart';
import '../services/local_database.dart';
import 'package:provider/provider.dart';

class ConnectionStatusIndicator extends StatefulWidget {
  final bool showDetails;
  final Widget? child;

  const ConnectionStatusIndicator({
    super.key,
    this.showDetails = true,
    this.child,
  });

  @override
  State<ConnectionStatusIndicator> createState() => _ConnectionStatusIndicatorState();
}

class _ConnectionStatusIndicatorState extends State<ConnectionStatusIndicator> {
  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      final connectionService = context.read<ConnectionService>();
      await connectionService.initialize();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionInfo>(
      stream: context.read<ConnectionService>().connectionStream,
      builder: (context, snapshot) {
        final info = snapshot.data;
        final type = info?.type ?? ConnectionType.offline;

        return GestureDetector(
          onTap: widget.showDetails ? () => _showConnectionDetails(context) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(type).withOpacity( 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor(type)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(type),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(type),
                  style: TextStyle(
                    color: _getStatusColor(type),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                if (widget.child != null) ...[
                  const SizedBox(width: 8),
                  widget.child!,
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(ConnectionType type) {
    switch (type) {
      case ConnectionType.wifi:
        return Colors.green;
      case ConnectionType.bluetooth:
        return Colors.purple;
      case ConnectionType.wifiDirect:
        return Colors.blue;
      case ConnectionType.offline:
        return Colors.grey;
    }
  }

  String _getStatusText(ConnectionType type) {
    switch (type) {
      case ConnectionType.wifi:
        return 'Firebase';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.wifiDirect:
        return 'WiFi';
      case ConnectionType.offline:
        return 'Offline';
    }
  }

  void _showConnectionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ConnectionDetailsSheet(),
    );
  }
}

class ConnectionDetailsSheet extends StatefulWidget {
  const ConnectionDetailsSheet({super.key});

  @override
  State<ConnectionDetailsSheet> createState() => _ConnectionDetailsSheetState();
}

class _ConnectionDetailsSheetState extends State<ConnectionDetailsSheet> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi, color: Colors.green),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Connection Status', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              StreamBuilder<ConnectionInfo>(
                stream: context.read<ConnectionService>().connectionStream,
                builder: (context, snapshot) {
                  final info = snapshot.data;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: info?.isConnected == true 
                        ? Colors.green.withOpacity( 0.2) 
                        : Colors.grey.withOpacity( 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      info?.isConnected == true ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        color: info?.isConnected == true ? Colors.green : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Available Methods', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildMethodTile(
            icon: Icons.cloud,
            title: 'Firebase Cloud',
            subtitle: 'Internet sync (primary)',
            color: Colors.green,
            status: 'Ready',
          ),
          _buildMethodTile(
            icon: Icons.wifi,
            title: 'WiFi Local',
            subtitle: 'Same router, no internet needed',
            color: Colors.blue,
            status: 'Tap to start',
            onTap: _startLocalServer,
          ),
          _buildMethodTile(
            icon: Icons.bluetooth,
            title: 'Bluetooth',
            subtitle: 'Close range (~10m)',
            color: Colors.purple,
            status: _isScanning ? 'Scanning...' : 'Tap to scan',
            onTap: _isScanning ? null : _scanBluetooth,
          ),
          _buildMethodTile(
            icon: Icons.share,
            title: 'WiFi Direct',
            subtitle: 'Direct peer (~60m)',
            color: Colors.orange,
            status: 'Tap to connect',
            onTap: _scanWifiDirect,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Sync Status', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildSyncStatus(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _syncNow,
              icon: const Icon(Icons.sync),
              label: const Text('Sync Now'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String status,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity( 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: TextButton(
          onPressed: onTap,
          child: Text(status, style: const TextStyle(fontSize: 12)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
      ),
    );
  }

  Widget _buildSyncStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('All messages synced'),
          ),
          StreamBuilder<ConnectionInfo>(
            stream: context.read<ConnectionService>().connectionStream,
            builder: (context, snapshot) {
              final info = snapshot.data;
              if (info?.isConnected == true) {
                return const Icon(Icons.cloud_done, color: Colors.green, size: 20);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _startLocalServer() async {
    try {
      final localNetwork = context.read<LocalNetworkService>();
      await localNetwork.startServer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Local server started - family can now connect')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start: $e')),
      );
    }
  }

  Future<void> _scanBluetooth() async {
    setState(() => _isScanning = true);
    
    try {
      final btService = context.read<BluetoothService>();
      final devices = await btService.scanForDevices(timeout: 10).first;
      
      if (devices.isNotEmpty && mounted) {
        _showBluetoothDevices(devices);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No nearby devices found')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bluetooth error: $e')),
        );
      }
    }
    
    if (mounted) setState(() => _isScanning = false);
  }

  void _showBluetoothDevices(List<BluetoothDeviceInfo> devices) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nearby Family'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: devices.length,
            itemBuilder: (ctx, i) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.phone_android)),
              title: Text(devices[i].name),
              subtitle: Text('Signal: ${devices[i].rssi} dBm'),
              onTap: () async {
                Navigator.pop(ctx);
                final success = await context.read<BluetoothService>()
                    .connectToDevice(devices[i].id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(
                      success ? 'Connected!' : 'Connection failed',
                    )),
                  );
                }
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanWifiDirect() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WiFi Direct - search for "FamilyCircle" in settings')),
    );
  }

  Future<void> _syncNow() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing...')),
    );
  }
}