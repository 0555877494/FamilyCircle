import 'dart:async';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import 'local_database.dart';
import 'connection_service.dart';
import 'bluetooth_service.dart';

enum MessageTransport { firebase, localNetwork, bluetooth }

class OfflineMessage {
  final String id;
  final Message message;
  final List<MessageTransport> attemptedTransports;
  final DateTime createdAt;
  final int retryCount;

  OfflineMessage({
    required this.id,
    required this.message,
    this.attemptedTransports = const [],
    required this.createdAt,
    this.retryCount = 0,
  });
}

class OfflineMessageQueue {
  final LocalDatabase _localDb;
  bool _isInitialized = false;
  Timer? _retryTimer;
  
  final _queueController = StreamController<OfflineMessage>.broadcast();
  Stream<OfflineMessage> get queueStream => _queueController.stream;

  OfflineMessageQueue(this._localDb);

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _retryTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      await _retryPending();
    });
    
    _isInitialized = true;
  }

  void addToQueue(Message message, MessageTransport transport) {
    final offlineMsg = OfflineMessage(
      id: const Uuid().v4(),
      message: message,
      attemptedTransports: [transport],
      createdAt: DateTime.now(),
    );
    _queueController.add(offlineMsg);
  }

  Future<void> _retryPending() async {}

  void dispose() {
    _retryTimer?.cancel();
    _queueController.close();
  }
}

class CommunicationsManager {
  final LocalDatabase _localDb;
  final ConnectionService _connectionService;
  final LocalNetworkService _localNetwork;
  final BluetoothService _bluetoothService;
  
  StreamSubscription? _connectionSubscription;
  bool _isInitialized = false;
  OfflineMessageQueue? _offlineQueue;
  
  final _messageController = StreamController<Message>.broadcast();
  Stream<Message> get messageStream => _messageController.stream;

  CommunicationsManager(
    this._localDb,
    this._connectionService,
    this._localNetwork,
    this._bluetoothService,
  );

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _offlineQueue = OfflineMessageQueue(_localDb);
    await _offlineQueue!.initialize();
    
    await _connectionService.initialize();
    await _bluetoothService.initialize();
    
    _connectionSubscription = _connectionService.connectionStream.listen(
      _handleConnectionChange,
    );
    
    _isInitialized = true;
  }

  Future<void> _handleConnectionChange(ConnectionInfo info) async {
    if (info.isConnected && info.type == ConnectionType.wifi) {
      await _processOfflineQueue();
    }
  }

  Future<bool> sendMessage(Message message, {MessageTransport? preferred}) async {
    await _localDb.insertMessage(message);
    
    if (preferred != null) {
      return await _sendViaTransport(message, preferred);
    }
    
    final isOnline = _connectionService.isOnline;
    if (isOnline) {
      return await _sendViaFirebase(message);
    } else {
      final localResult = await _sendViaLocalNetwork(message);
      if (!localResult) {
        return await _sendViaBluetooth(message);
      }
      return localResult;
    }
  }

  Future<bool> _sendViaTransport(Message message, MessageTransport transport) async {
    switch (transport) {
      case MessageTransport.firebase:
        return await _sendViaFirebase(message);
      case MessageTransport.localNetwork:
        return await _sendViaLocalNetwork(message);
      case MessageTransport.bluetooth:
        return await _sendViaBluetooth(message);
    }
  }

  Future<bool> _sendViaFirebase(Message message) async {
    try {
      await _localDb.markMessageSynced(message.id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _sendViaLocalNetwork(Message message) async {
    try {
      final data = {
        'type': 'message',
        'data': message.toMap(),
      };
      await _localNetwork.broadcast(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _sendViaBluetooth(Message message) async {
    try {
      final data = {'type': 'message', 'data': message.toMap()};
      return await _bluetoothService.sendData(data);
    } catch (e) {
      return false;
    }
  }

  Future<void> _processOfflineQueue() async {
    if (!_connectionService.isOnline) return;
    
    final unsynced = await _localDb.getUnsyncedMessages();
    for (final message in unsynced) {
      try {
        await _sendViaFirebase(message);
      } catch (e) {
        print('Failed to sync: $e');
      }
    }
  }

  Future<bool> shareMediaViaBluetooth(String filePath) async {
    return await _bluetoothService.sendFile(filePath);
  }

  Future<bool> shareMediaViaLocalNetwork(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return false;
    
    final data = {
      'type': 'file',
      'path': filePath,
      'name': file.path.split('/').last,
    };
    
    await _localNetwork.broadcast(data);
    return true;
  }

  Future<void> startLocalNetworkServer({int port = 8765}) async {
    await _localNetwork.startServer(port: port);
  }

  Future<void> connectToLocalPeer(String ip, {int port = 8765}) async {
    await _localNetwork.connectToPeer(ip, port: port);
  }

  Future<bool> discoverAndConnectToFamily() async {
    final isOnline = _connectionService.isOnline;
    
    if (!isOnline) {
      final peers = await _localNetwork.discoverPeers();
      for (final ip in peers) {
        if (await _localNetwork.connectToPeer(ip)) {
          return true;
        }
      }
    }
    
    return false;
  }

  Future<List<BluetoothDeviceInfo>> scanForNearbyFamily({int timeout = 10}) async {
    final results = <BluetoothDeviceInfo>[];
    await for (final devices in _bluetoothService.scanForDevices(timeout: timeout)) {
      results.addAll(devices);
    }
    return results;
  }

  bool get isOnline => _connectionService.isOnline;

  void dispose() {
    _connectionSubscription?.cancel();
    _offlineQueue?.dispose();
    _messageController.close();
  }
}