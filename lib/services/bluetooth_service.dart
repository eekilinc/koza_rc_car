import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'dart:async';

/// Scanned device during discovery
class ScannedDevice {
  final String name;
  final String address;
  final String type;
  final int rssi;
  
  ScannedDevice({
    required this.name,
    required this.address,
    required this.type,
    required this.rssi,
  });
  
  @override
  String toString() => '$name ($address) [$type] RSSI: $rssi';
}

/// Bonded Bluetooth device with name and address
class BondedDevice {
  final String name;
  final String address;
  final String type; // "CLASSIC", "BLE", "DUAL", or "UNKNOWN"
  
  BondedDevice({
    required this.name,
    required this.address,
    this.type = "UNKNOWN",
  });
  
  // Strict filtering: only return true if EXACTLY that type
  bool get isClassicOnly => type == "CLASSIC";
  bool get isBLEOnly => type == "BLE";
  bool get isDual => type == "DUAL";
  
  // For UI: shows which mode can use this device
  bool get canUseInClassicMode => type == "CLASSIC" || type == "DUAL";
  bool get canUseInBLEMode => type == "BLE" || type == "DUAL";
  
  @override
  String toString() => '$name ($address) [$type]';
}

/// Bluetooth service for HC-06 communication
class BluetoothServiceManager {
  static final BluetoothServiceManager _instance = BluetoothServiceManager._internal();
  
  // Method channel for native Android calls
  static const platform = MethodChannel('com.kozaakademi.rc_car/bluetooth');

  factory BluetoothServiceManager() {
    return _instance;
  }

  BluetoothServiceManager._internal() {
    // Setup method call handler for incoming calls from native
    platform.setMethodCallHandler(_handleMethodCalls);
  }

  fbp.BluetoothDevice? _connectedDevice;
  fbp.BluetoothCharacteristic? _writeCharacteristic;
  
  // Scan state
  final _scannedDevices = <String, ScannedDevice>{};
  final _scanController = StreamController<ScannedDevice>.broadcast();
  final _scanFinishedController = StreamController<void>.broadcast();
  
  Stream<ScannedDevice> get scanResults => _scanController.stream;
  Stream<void> get scanFinished => _scanFinishedController.stream;

  bool get isConnected => _connectedDevice != null && _writeCharacteristic != null;
  fbp.BluetoothDevice? get connectedDevice => _connectedDevice;
  
  // Handle incoming method calls from native
  Future<dynamic> _handleMethodCalls(MethodCall call) async {
    switch (call.method) {
      case 'onDeviceFound':
        final device = ScannedDevice(
          name: call.arguments['name'] ?? 'Unknown',
          address: call.arguments['address'] ?? '',
          type: call.arguments['type'] ?? 'UNKNOWN',
          rssi: call.arguments['rssi'] ?? 0,
        );
        print('[BT Scan] Device found: $device');
        _scannedDevices[device.address] = device;
        _scanController.add(device);
        break;
      case 'onScanFinished':
        print('[BT Scan] Scan finished');
        _scanFinishedController.add(null);
        break;
    }
  }

  /// Send command to Arduino via Bluetooth
  Future<bool> sendCommand(String command) async {
    try {
      // Try native Android method first (for classic Bluetooth)
      final bool result = await platform.invokeMethod('sendCommand', {
        'command': command,
      });
      
      print('[BT Service] Command sent: "$command" -> Result: $result');
      
      if (result) {
        return true;
      }
    } catch (e) {
      print('[BT Service] Native send failed: $e');
    }

    // Fallback to BLE characteristic write if classic Bluetooth isn't available
    if (_writeCharacteristic == null) {
      print('[BT Service] Bluetooth not connected');
      return false;
    }

    try {
      await _writeCharacteristic!.write(command.codeUnits);
      print('[BT Service] Fallback BLE write successful: "$command"');
      return true;
    } catch (e) {
      print('[BT Service] Error sending command: $e');
      return false;
    }
  }
  
  /// Start device scanning via native Android
  Future<void> startScan() async {
    try {
      _scannedDevices.clear();
      print('[BT Scan] Starting device scan via native Android...');
      
      try {
        final result = await platform.invokeMethod('startScan');
        print('[BT Scan] Native startScan returned: $result');
      } on PlatformException catch (e) {
        print('[BT Scan] ❌ PlatformException from native: ${e.code}');
        print('[BT Scan] Message: ${e.message}');
        print('[BT Scan] Details: ${e.details}');
        rethrow;
      } catch (e) {
        print('[BT Scan] ❌ Unexpected error from native: $e');
        print('[BT Scan] Error type: ${e.runtimeType}');
        rethrow;
      }
    } catch (e) {
      print('[BT Scan] ❌ Error: $e');
      rethrow;
    }
  }
  
  /// Stop device scanning
  Future<void> stopScan() async {
    try {
      print('[BT Scan] Stopping scan...');
      await platform.invokeMethod('stopScan');
    } on PlatformException catch (e) {
      print('[BT Scan] Error: ${e.message}');
    }
  }
  
  /// Get all scanned devices so far
  List<ScannedDevice> getScannedDevices() {
    return _scannedDevices.values.toList();
  }

  /// Connect to HC-06 device from bonded device (classic Bluetooth)
  Future<bool> connectToBondedDevice(BondedDevice bondedDevice) async {
    try {
      print('[BLE Service] Starting connection to ${bondedDevice.address}');
      
      // Use native Android method for classic Bluetooth connection with timeout
      final bool success = await platform.invokeMethod('connectToDevice', {
        'address': bondedDevice.address,
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('[BLE Service] Connection timeout');
          return false;
        },
      );

      print('[BLE Service] Native method returned: $success');

      if (success) {
        print('[BLE Service] Connection successful to: ${bondedDevice.name}');
        _connectedDevice = fbp.BluetoothDevice.fromId(bondedDevice.address);
        return true;
      } else {
        print('[BLE Service] Connection failed - native returned false');
        return false;
      }
    } on PlatformException catch (e) {
      print('[BLE Service] PlatformException: ${e.message}');
      return false;
    } catch (e) {
      print('[BLE Service] Error connecting to device: $e');
      return false;
    }
  }

  /// Connect to BLE device from scan result
  Future<bool> connectToBluetoothDevice(fbp.BluetoothDevice device) async {
    try {
      print('[BLE Connect] Attempting BLE connection to ${device.remoteId}...');
      
      // Timeout after 15 seconds
      await Future.wait([
        device.connect(autoConnect: false),
      ]).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('[BLE Connect] Connection timeout for ${device.remoteId}');
          throw TimeoutException('Connection timeout', const Duration(seconds: 15));
        },
      );
      
      print('[BLE Connect] Connected to device, discovering services...');
      _connectedDevice = device;
      
      // Discover services with timeout
      List<fbp.BluetoothService> services = await device.discoverServices()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('[BLE Connect] Service discovery timeout');
              return [];
            },
          );
      
      print('[BLE Connect] Found ${services.length} services');
      
      // Find the write characteristic
      bool foundCharacteristic = false;
      for (fbp.BluetoothService service in services) {
        print('[BLE Connect] Service UUID: ${service.uuid}');
        
        for (fbp.BluetoothCharacteristic characteristic in service.characteristics) {
          print('[BLE Connect] Characteristic: ${characteristic.uuid}, write: ${characteristic.properties.write}');
          
          if (characteristic.properties.write) {
            _writeCharacteristic = characteristic;
            foundCharacteristic = true;
            print('[BLE Connect] ✓ Found write characteristic: ${characteristic.uuid}');
            break;
          }
        }
        
        if (foundCharacteristic) break;
      }
      
      if (!foundCharacteristic) {
        print('[BLE Connect] ✗ No write characteristic found, trying first writable characteristic...');
        // Fallback: try any characteristic that supports write
        for (fbp.BluetoothService service in services) {
          for (fbp.BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
              _writeCharacteristic = characteristic;
              foundCharacteristic = true;
              print('[BLE Connect] ✓ Using fallback characteristic: ${characteristic.uuid}');
              break;
            }
          }
          if (foundCharacteristic) break;
        }
      }
      
      if (foundCharacteristic) {
        print('[BLE Connect] ✓ Successfully connected via BLE to ${device.remoteId}');
        return true;
      } else {
        print('[BLE Connect] ✗ No writable characteristic found');
        await device.disconnect();
        return false;
      }
    } on TimeoutException catch (e) {
      print('[BLE Connect] Timeout error: $e');
      try {
        await device.disconnect();
      } catch (_) {}
      return false;
    } catch (e) {
      print('[BLE Connect] Error connecting to BLE device: $e');
      try {
        await device.disconnect();
      } catch (_) {}
      return false;
    }
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    try {
      // Call native disconnect for classic Bluetooth
      await platform.invokeMethod('disconnect');
    } catch (e) {
      print('Error in native disconnect: $e');
    }

    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
      _connectedDevice = null;
      _writeCharacteristic = null;
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  /// Get list of bonded/paired Bluetooth devices with names
  Future<List<BondedDevice>> getAvailableDevices() async {
    try {
      // Try to get bonded devices from native Android
      final List<dynamic> bondedDevices = 
          await platform.invokeMethod('getBondedDevices');
      
      print('Got ${bondedDevices.length} bonded devices from Android');
      
      // Convert to BondedDevice objects
      List<BondedDevice> devices = [];
      for (var device in bondedDevices) {
        if (device is Map) {
          final name = device['name'] as String?;
          final address = device['address'] as String?;
          final type = device['type'] as String? ?? 'UNKNOWN';
          
          if (address != null && name != null) {
            final bondedDevice = BondedDevice(
              name: name,
              address: address,
              type: type,
            );
            devices.add(bondedDevice);
            print('Bonded device: $name ($address) Type: $type');
          }
        }
      }
      
      return devices;
    } on PlatformException catch (e) {
      print('Error getting bonded devices: ${e.message}');
      return [];
    } catch (e) {
      print('Unexpected error getting devices: $e');
      return [];
    }
  }

  /// Scan for Bluetooth devices (deprecated - use native scanning instead)
  Stream<List<fbp.ScanResult>> scanForDevices() {
    print('[BLE Scan] Creating scan results stream...');
    final stream = fbp.FlutterBluePlus.scanResults;
    print('[BLE Scan] Stream created: ${stream.toString()}');
    return stream;
  }

  /// Check if Bluetooth is available
  Future<bool> isBluetoothAvailable() async {
    try {
      return await fbp.FlutterBluePlus.isSupported;
    } catch (e) {
      print('Error checking Bluetooth availability: $e');
      return false;
    }
  }
}
