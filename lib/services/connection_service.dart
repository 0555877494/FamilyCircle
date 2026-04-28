import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

enum ConnectionType { wifi, bluetooth, wifiDirect, offline }

class ConnectionInfo {
  final ConnectionType type;
  final String name;
  final String? address;
  final bool isConnected;

  ConnectionInfo({
    required this.type,
    required this.name,
    this.address,
    this.isConnected = true,
  });
}

class ConnectionService {
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();
  
  StreamController<ConnectionInfo> _connectionController = StreamController<ConnectionInfo>.broadcast();
  Timer? _syncTimer;
  bool _isOnline = false;
  
  Stream<ConnectionInfo> get connectionStream => _connectionController.stream;

  Future<void> initialize() async {
    _connectivity.onConnectivityChanged.listen(_handleConnectionChange);
    await _checkConnection();
    _startPeriodicSync();
  }

  Future<void> _checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    await _handleConnectionChange(results);
  }

  Future<void> _handleConnectionChange(List<ConnectivityResult> results) async {
    ConnectionType type;
    String? address;
    
    if (results.contains(ConnectivityResult.wifi)) {
      type = ConnectionType.wifi;
      try {
        address = await _networkInfo.getWifiIP();
      } catch (e) { address = null; }
      _isOnline = true;
    } else if (results.contains(ConnectivityResult.mobile)) {
      type = ConnectionType.wifi;
      address = 'mobile';
      _isOnline = true;
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      type = ConnectionType.bluetooth;
      _isOnline = false;
    } else {
      type = ConnectionType.offline;
      _isOnline = false;
    }

    _connectionController.add(ConnectionInfo(
      type: type,
      name: _getConnectionName(type),
      address: address,
    ));
  }

  String _getConnectionName(ConnectionType type) {
    switch (type) {
      case ConnectionType.wifi: return 'WiFi';
      case ConnectionType.bluetooth: return 'Bluetooth';
      case ConnectionType.wifiDirect: return 'WiFi Direct';
      case ConnectionType.offline: return 'Offline';
    }
  }

  bool get isOnline => _isOnline;

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (_isOnline) {
        await _checkConnection();
      }
    });
  }

  void dispose() {
    _syncTimer?.cancel();
    _connectionController.close();
  }
}

class LocalNetworkService {
  ServerSocket? _serverSocket;
  List<Socket> _connectedClients = [];
  int _port = 8765;
  
  final Map<String, Socket> _peers = {};

  Future<bool> startServer({int port = 8765}) async {
    try {
      _port = port;
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      
      _serverSocket!.listen(
        (client) => _handleClient(client),
        onError: (error) => print('Server error: $error'),
      );
      return true;
    } catch (e) {
      print('Failed to start server: $e');
      return false;
    }
  }

  void _handleClient(Socket client) {
    _connectedClients.add(client);
    print('Client connected: ${client.remoteAddress}');

    client.listen(
      (data) => _handleData(data, client),
      onDone: () {
        _connectedClients.remove(client);
        print('Client disconnected');
      },
    );
  }

  void _handleData(Uint8List data, Socket client) {
    try {
      final String message = utf8.decode(data);
      print('Received: $message');
    } catch (e) {
      print('Failed to decode message: $e');
    }
  }

  Future<bool> connectToPeer(String ip, {int port = 8765}) async {
    try {
      final socket = await Socket.connect(ip, port);
      _peers[ip] = socket;
      
      socket.listen(
        (data) => _handleData(data, socket),
        onDone: () {
          _peers.remove(ip);
        },
      );
      return true;
    } catch (e) {
      print('Failed to connect to peer: $e');
      return false;
    }
  }

  Future<void> broadcast(dynamic data) async {
    final bytes = utf8.encode(jsonEncode(data));
    
    for (final client in _connectedClients) {
      try {
        client.add(bytes);
      } catch (e) {
        print('Failed to send to client: $e');
      }
    }
  }

  Future<void> sendToPeer(String ip, dynamic data) async {
    final socket = _peers[ip];
    if (socket != null) {
      final bytes = utf8.encode(jsonEncode(data));
      socket.add(bytes);
    }
  }

  Future<List<String>> discoverPeers() async {
    return [];
  }

  void dispose() {
    _serverSocket?.close();
    for (final client in _connectedClients) {
      client.close();
    }
    for (final peer in _peers.values) {
      peer.close();
    }
  }
}

class SyncService {
  final ConnectionService _connectionService;
  bool _isSyncing = false;

  SyncService(this._connectionService);

  Future<void> syncMessages() async {
    if (_isSyncing || !_connectionService.isOnline) return;
    
    _isSyncing = true;
    _isSyncing = false;
  }

  Future<void> syncAll() async {
    if (!_connectionService.isOnline) return;
    await syncMessages();
  }
}