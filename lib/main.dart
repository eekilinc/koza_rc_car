import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'dart:io' show Platform;
import 'pages/rc_car_controller_page.dart';
import 'services/theme_service.dart';
import 'services/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final themeService = ThemeService();
  final soundService = SoundService();
  
  await themeService.init();
  await soundService.init();
  
  // Request necessary permissions
  await _requestPermissions();
  
  // Check if Bluetooth is enabled
  if (Platform.isAndroid) {
    final isBluetoothEnabled = await fbp.FlutterBluePlus.isOn;
    print('[Main] Bluetooth enabled: $isBluetoothEnabled');
  }
  
  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  print('[Permission] Requesting Bluetooth permissions...');
  
  if (Platform.isAndroid) {
    // For Android 12+, request specific Bluetooth permissions
    final bluetoothConnectStatus = await Permission.bluetoothConnect.request();
    print('[Permission] BLUETOOTH_CONNECT: ${bluetoothConnectStatus.isDenied ? "DENIED" : "GRANTED"}');
    
    final bluetoothScanStatus = await Permission.bluetoothScan.request();
    print('[Permission] BLUETOOTH_SCAN: ${bluetoothScanStatus.isDenied ? "DENIED" : "GRANTED"}');
    
    // Location permission is required for BLE scanning on Android 12+
    final locationStatus = await Permission.location.request();
    print('[Permission] LOCATION: ${locationStatus.isDenied ? "DENIED" : "GRANTED"}');
    
    // Additional permission for nearby devices (Android 12+)
    if (Platform.isAndroid) {
      try {
        final nearbyStatus = await Permission.nearbyWifiDevices.request();
        print('[Permission] NEARBY_WIFI_DEVICES: ${nearbyStatus.isDenied ? "DENIED" : "GRANTED"}');
      } catch (e) {
        print('[Permission] NEARBY_WIFI_DEVICES not available: $e');
      }
    }
  } else if (Platform.isIOS) {
    // iOS doesn't require special permissions for Bluetooth
    print('[Permission] iOS - no special Bluetooth permissions needed');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeService _themeService;
  
  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeService.themeNotifier,
      builder: (context, theme, child) {
        return MaterialApp(
          title: 'Koza RC Car',
          locale: const Locale('tr', 'TR'),
          theme: ThemeService.lightTheme,
          darkTheme: ThemeService.darkTheme,
          themeMode: theme,
          home: const RCCarControllerPage(),
        );
      },
    );
  }
}
