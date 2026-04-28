import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';
import 'dart:convert';

enum BluetoothDeviceType { sender, receiver, both }

class BluetoothDeviceInfo {
  final String id;
  final String name;
  final int rssi;
  final BluetoothDeviceType type;

  BluetoothDeviceInfo({
    required this.id,
    required this.name,
    required this.rssi,
    required this.type,
  });
}

class BluetoothService {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  
  final Map<String, BluetoothDevice> _connectedDevices = {};
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;
  
  final _dataController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;

  final _stateController = StreamController<BluetoothAdapterState>.broadcast();
  Stream<BluetoothAdapterState> get stateStream => _stateController.stream;

  Future<bool> initialize() async {
    try {
      _adapterSubscription = FlutterBluePlus.adapterState.listen((state) {
        _stateController.add(state);
      });
      
      if (await FlutterBluePlus.state == BluetoothAdapterState.on) {
        return true;
      }
      return false;
    } catch (e) {
      print('Bluetooth init error: $e');
      return false;
    }
  }

  Future<bool> isBluetoothAvailable() async {
    final state = await FlutterBluePlus.state;
    return state == BluetoothAdapterState.on;
  }

  Future<bool> requestEnable() async {
    try {
      await FlutterBluePlus.turnOn();
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<BluetoothDeviceInfo>> scanForDevices({int timeout = 10}) async* {
    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: timeout));
      
      await for (final results in FlutterBluePlus.scanResults) {
        yield results
            .where((r) => r.device.platformName.isNotEmpty)
            .map((r) => BluetoothDeviceInfo(
                  id: r.device.remoteId.str,
                  name: r.device.platformName.isNotEmpty ? r.device.platformName : 'Unknown',
                  rssi: r.rssi,
                  type: BluetoothDeviceType.both,
                ))
            .toList();
      }
    } catch (e) {
      print('Scan error: $e');
    }
  }

  Future<bool> connectToDevice(String deviceId) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      await device.connect(timeout: const Duration(seconds: 15));
      
      _connectedDevices[deviceId] = device;
      
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _connectedDevices.remove(deviceId);
        }
      });
      
      await _setupCharacteristics(device);
      return true;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  Future<void> _setupCharacteristics(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      
      for (final service in services) {
        for (final char in service.characteristics) {
          if (char.uuid.str.contains('2a00')) { // Device Name
            _readCharacteristic = char;
          }
          if (char.uuid.str.contains('2a00')) { // Write
            _writeCharacteristic = char;
          }
        }
      }
    } catch (e) {
      print('Setup error: $e');
    }
  }

  Future<bool> sendData(Map<String, dynamic> data) async {
    try {
      if (_writeCharacteristic == null) return false;
      
      final jsonString = jsonEncode(data);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      
      await _writeCharacteristic!.write(bytes, withoutResponse: true);
      return true;
    } catch (e) {
      print('Send error: $e');
      return false;
    }
  }

  Future<bool> sendFile(String filePath) async {
    try {
      if (_writeCharacteristic == null) return false;
      
      final fileData = await _readFile(filePath);
      if (fileData == null) return false;
      
      const chunkSize = 512;
      final chunks = fileData.length ~/ chunkSize + 1;
      
      for (var i = 0; i < chunks; i++) {
        final start = i * chunkSize;
        final end = (start + chunkSize > fileData.length) 
            ? fileData.length 
            : start + chunkSize;
        final chunk = fileData.sublist(start, end);
        
        await _writeCharacteristic!.write(
          Uint8List.fromList(utf8.encode(jsonEncode({
            'type': 'file_chunk',
            'data': base64Encode(chunk),
            'index': i,
            'total': chunks,
          }))),
          withoutResponse: true,
        );
        
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      return true;
    } catch (e) {
      print('Send file error: $e');
      return false;
    }
  }

  Future<Uint8List?> _readFile(String path) async {
    return null;
  }

  Future<Uint8List?> _openFile(String path) async {
    return null;
  }

  Future<void> receiveData() async {
    try {
      if (_readCharacteristic == null) return;
      
      _readCharacteristic!.lastValueStream.listen((value) {
        try {
          final String message = utf8.decode(value);
          final data = jsonDecode(message) as Map<String, dynamic>;
          _dataController.add(data);
        } catch (e) {
          print('Decode error: $e');
        }
      });
    } catch (e) {
      print('Receive error: $e');
    }
  }

  List<BluetoothDevice> get connectedDevices => _connectedDevices.values.toList();

  Future<void> disconnect(String deviceId) async {
    final device = _connectedDevices[deviceId];
    if (device != null) {
      await device.disconnect();
      _connectedDevices.remove(deviceId);
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  void dispose() {
    _scanSubscription?.cancel();
    _adapterSubscription?.cancel();
    _connectionSubscription?.cancel();
    _dataController.close();
    _stateController.close();
    
    for (final device in _connectedDevices.values) {
      device.disconnect();
    }
  }
}

class WifiDirectService {
  bool _isConnected = false;
  String? _groupOwnerAddress;
  String? _ssid;

  Future<bool> initialize() async {
    return false;
  }

  bool get isConnected => _isConnected;

  Future<List<String>> discoverDevices() async {
    return [];
  }

  Future<bool> connectToDevice(String ssid) async {
    return false;
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _ssid = null;
    _groupOwnerAddress = null;
  }

  String? get groupOwnerAddress => _groupOwnerAddress;
  String? get ssid => _ssid;
}