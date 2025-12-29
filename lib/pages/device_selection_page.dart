import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bluetooth_service.dart';

/// Device selection page for connecting to HC-06
class DeviceSelectionPage extends StatefulWidget {
  const DeviceSelectionPage({Key? key}) : super(key: key);

  @override
  State<DeviceSelectionPage> createState() => _DeviceSelectionPageState();
}

class _DeviceSelectionPageState extends State<DeviceSelectionPage> {
  final BluetoothServiceManager _bluetoothService = BluetoothServiceManager();
  List<BondedDevice> _availableDevices = [];
  List<BondedDevice> _recentlyConnectedDevices = [];
  bool _isLoading = true;
  
  // Bluetooth mode: true = Classic (HC-06), false = BLE
  bool _isClassicMode = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableDevices();
    _loadRecentlyConnectedDevices();
  }

  Future<void> _loadRecentlyConnectedDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentDevices = prefs.getStringList('recently_connected_devices') ?? [];
      
      if (mounted) {
        setState(() {
          _recentlyConnectedDevices = recentDevices.map((deviceJson) {
            try {
              final parts = deviceJson.split('|');
              if (parts.length >= 3) {
                return BondedDevice(
                  name: parts[0],
                  address: parts[1],
                  type: parts[2],
                );
              }
            } catch (e) {
              print('Error parsing recent device: $e');
            }
            return null;
          }).whereType<BondedDevice>().toList();
        });
      }
    } catch (e) {
      print('Error loading recently connected devices: $e');
    }
  }

  Future<void> _addToRecentlyConnected(BondedDevice device) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentList = prefs.getStringList('recently_connected_devices') ?? [];
      
      // Format: name|address|type
      final deviceStr = '${device.name}|${device.address}|${device.type}';
      
      // Remove if already exists
      recentList.removeWhere((item) => item.split('|')[1] == device.address);
      
      // Add to beginning
      recentList.insert(0, deviceStr);
      
      // Keep only last 5
      if (recentList.length > 5) {
        recentList.removeLast();
      }
      
      await prefs.setStringList('recently_connected_devices', recentList);
      _loadRecentlyConnectedDevices();
    } catch (e) {
      print('Error adding to recently connected: $e');
    }
  }

  Future<void> _loadAvailableDevices() async {
    setState(() => _isLoading = true);

    // Get paired/bonded devices
    final allDevices = await _bluetoothService.getAvailableDevices();
    print('All bonded devices found: ${allDevices.length}');
    
    // Strictly filter devices: Classic mode gets ONLY Classic, BLE mode gets ONLY BLE
    // DUAL devices only shown in the mode explicitly selected
    List<BondedDevice> filteredDevices;
    if (_isClassicMode) {
      // Classic mode: ONLY show CLASSIC devices (not BLE, not UNKNOWN)
      filteredDevices = allDevices.where((d) => d.type == "CLASSIC").toList();
      print('Classic mode - showing ${filteredDevices.length} CLASSIC devices (excluding BLE and DUAL)');
    } else {
      // BLE mode: ONLY show BLE devices (not CLASSIC, not UNKNOWN)
      filteredDevices = allDevices.where((d) => d.type == "BLE").toList();
      print('BLE mode - showing ${filteredDevices.length} BLE devices (excluding CLASSIC and DUAL)');
    }
    
    for (var device in filteredDevices) {
      print('  - ${device.name} (${device.address}) [${device.type}]');
    }
    
    setState(() {
      _availableDevices = filteredDevices;
      _isLoading = false;
    });
  }

  Future<void> _connectToDevice(BondedDevice bondedDevice) async {
    print('=== Starting connection to ${bondedDevice.name} ===');
    print('Mode: ${_isClassicMode ? "Classic" : "BLE"}');
    
    // Show dialog with its own context
    BuildContext? dialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        dialogContext = dialogCtx;
        print('Dialog opened with context');
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text('${bondedDevice.name}\'ya bağlanılıyor...'),
            ],
          ),
        );
      },
    );

    print('Dialog shown, attempting to connect...');
    
    bool success = false;
    
    if (_isClassicMode) {
      // Classic Bluetooth connection using native Android
      success = await _bluetoothService.connectToBondedDevice(bondedDevice);
    } else {
      // BLE connection using flutter_blue_plus
      try {
        final device = fbp.BluetoothDevice.fromId(bondedDevice.address);
        success = await _bluetoothService.connectToBluetoothDevice(device);
      } catch (e) {
        print('BLE connection error: $e');
        success = false;
      }
    }
    
    print('Connection result: $success');
    print('mounted: $mounted, dialogContext: $dialogContext');

    if (mounted) {
      print('Widget is mounted, attempting to close dialog');
      
      // Close loading dialog
      if (dialogContext != null) {
        print('Closing dialog...');
        Navigator.of(dialogContext!).pop();
        print('Dialog closed');
      }
      
      if (success) {
        print('Connection successful, navigating back to RC controller');
        // Add to recently connected devices
        await _addToRecentlyConnected(bondedDevice);
        // Small delay to ensure dialog is fully closed
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          Navigator.of(context).pop(bondedDevice);
          print('Navigated back with device');
        }
      } else {
        print('Connection failed, showing error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isClassicMode 
              ? 'HC-06 cihazına bağlanılamadı' 
              : 'BLE cihazına bağlanılamadı'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('Widget not mounted!');
    }
  }

  void _showBluetoothInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Teknolojileri'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Classic Bluetooth
              Text(
                'Classic Bluetooth (HC-06)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Daha yüksek güç tüketimi\n'
                '• Daha uzun menzil (~100m)\n'
                '• Daha yüksek veri iletim hızı\n'
                '• Uydu cihazları ve HC-06 modülleri\n'
                '• Eski cihazlarla uyumlu',
                style: TextStyle(fontSize: 12, height: 1.6),
              ),
              const SizedBox(height: 16),
              
              // BLE
              Text(
                'Bluetooth Low Energy (BLE)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Çok düşük güç tüketimi\n'
                '• Orta menzil (~50m)\n'
                '• Düşük veri iletim hızı\n'
                '• Smartwatch, akıllı bilezik\n'
                '• Modern akıllı cihazlar\n'
                '• Şifre istemez - Bağlanması çok kolay!',
                style: TextStyle(fontSize: 12, height: 1.6),
              ),
              const SizedBox(height: 16),
              
              // Important Note
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[300]!),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dikkat: Piyasada "HC-06" olarak satılan ürünlerin çoğu aslında BLE cihazıdır. BLE modu denemeyi unutmayın!',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  void _showPairingGuideDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📱 Bluetooth Eşleştirme Rehberi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Classic Pairing
              _buildPairingSection(
                title: '🔵 Classic Bluetooth (HC-06) Eşleştirme',
                steps: [
                  '1. Android cihazınızın Ayarlar → Bluetooth bölümünü açın',
                  '2. "Cihazları bul" veya "Yeni cihaz ekle" seçeneğine basın',
                  '3. İltişin Bluetooth cihazlarının listesinde HC-06 modülünü bulun',
                  '4. HC-06\'ya dokunarak eşleştirmeyi başlatın',
                  '5. Şifre istenirse varsayılan şifreler: 1234 veya 0000',
                  '6. "Eşleştir" butonuna basın',
                  '7. Eşleştirme başarılı mesajını bekleyin',
                ],
                color: Colors.blue,
              ),
              const SizedBox(height: 16),

              // BLE Pairing
              _buildPairingSection(
                title: '💚 BLE (Bluetooth Low Energy) Eşleştirme',
                steps: [
                  '1. Android cihazınızın Ayarlar → Bluetooth bölümünü açın',
                  '2. "Cihazları bul" seçeneğine basın',
                  '3. BLE cihazını listede bulup seçin',
                  '4. BLE genellikle şifre istemez - direkt eşleştirilir',
                  '5. Bağlanmak için uygulamada BLE modunu seçin',
                  '6. Cihaza dokunarak bağlanın',
                  '⚡ İpucu: BLE çok hızlı eşleşir, sessizce olur',
                ],
                color: Colors.green,
              ),
              const SizedBox(height: 16),

              // Troubleshooting
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Eşleştirme Başarısız Olursa',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Cihazı açık ve keşfedilebilir modda olduğundan emin olun\n'
                      '• Cihazı yaklaştırmayı deneyin\n'
                      '• Bluetooth\'u açıp kapatmayı deneyip tekrar eşleştirin\n'
                      '• Cihazın pil seviyesini kontrol edin\n'
                      '• Telefonu ve cihazı yeniden başlatmayı deneyin',
                      style: TextStyle(fontSize: 11, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  Widget _buildPairingSection({
    required String title,
    required List<String> steps,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...steps.map((step) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              step,
              style: const TextStyle(fontSize: 11, height: 1.4),
            ),
          )).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Bağlan'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Bluetooth Mode Selector
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Bluetooth Modu',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: _showBluetoothInfo,
                                  tooltip: 'Classic vs BLE hakkında bilgi',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SegmentedButton<bool>(
                                    segments: const [
                                      ButtonSegment(
                                        value: true,
                                        label: Text('Classic (HC-06)'),
                                        icon: Icon(Icons.bluetooth),
                                      ),
                                      ButtonSegment(
                                        value: false,
                                        label: Text('BLE'),
                                        icon: Icon(Icons.bluetooth_searching),
                                      ),
                                    ],
                                    selected: {_isClassicMode},
                                    onSelectionChanged: (Set<bool> newSelection) async {
                                      setState(() {
                                        _isClassicMode = newSelection.first;
                                      });
                                      
                                      // Reload bonded devices filtered by mode
                                      await _loadAvailableDevices();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (_isClassicMode)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'HC-06 Classic Bluetooth - Eşleştirilmiş cihazlar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Bluetooth Low Energy - Eşleştirilmiş BLE cihazları gösterir',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Recently Connected Devices section
                  if (_recentlyConnectedDevices.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.history, color: Colors.purple[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Son Bağlanan Cihazlar',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.purple[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _recentlyConnectedDevices.length,
                              itemBuilder: (context, index) {
                                final device = _recentlyConnectedDevices[index];
                                // Only show if matches current mode
                                final matches = (_isClassicMode && device.type == "CLASSIC") ||
                                    (!_isClassicMode && device.type == "BLE");
                                
                                if (!matches) return const SizedBox.shrink();
                                
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () => _connectToDevice(device),
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      color: Colors.purple[50],
                                      child: Container(
                                        width: 100,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.purple[200]!,
                                            width: 2,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              device.type == "BLE" 
                                                ? Icons.bluetooth_searching
                                                : Icons.bluetooth,
                                              color: Colors.purple[700],
                                              size: 28,
                                            ),
                                            Flexible(
                                              child: Text(
                                                device.name,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'Bağlan',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.purple[700],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                  
                  // Instructions section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 2,
                      color: Colors.amber[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info, color: Colors.amber[700]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Nasıl Kullanılır?',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.amber[900],
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: _showPairingGuideDialog,
                                  icon: const Icon(Icons.help_outline, size: 18),
                                  label: const Text('Eşleştir', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isClassicMode
                                ? '1. Android Ayarlar → Bluetooth → Cihaz Eşleştir\n'
                                  '2. HC-06 cihazını bulun ve eşleştirin\n'
                                  '3. Eşleştirilen cihazı aşağıdan seçip bağlanın'
                                : '1. Android Ayarlar → Bluetooth → Cihaz Eşleştir\n'
                                  '2. BLE cihazını bulun ve eşleştirin\n'
                                  '3. Eşleştirilen cihazı aşağıdan seçip bağlanın',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Paired devices section (filtered by mode)
                  if (_availableDevices.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isClassicMode
                              ? 'Eşleştirilmiş Classic Cihazlar'
                              : 'Eşleştirilmiş BLE Cihazlar',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          ..._availableDevices.map((device) {
                            return _buildDeviceTile(device, isPaired: true);
                          }).toList(),
                        ],
                      ),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          _isClassicMode
                            ? 'Eşleştirilmiş HC-06 cihazı bulunamadı'
                            : 'Eşleştirilmiş BLE cihazı bulunamadı',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildDeviceTile(BondedDevice device, {required bool isPaired}) {
    return Card(
      elevation: isPaired ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 8),
      color: isPaired ? Colors.blue[50] : Colors.white,
      child: ListTile(
        leading: Icon(
          isPaired ? Icons.bluetooth_connected : Icons.bluetooth,
          color: isPaired ? Colors.blue : Colors.grey,
          size: isPaired ? 28 : 24,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.name.isEmpty ? 'Bilinmeyen Cihaz' : device.name,
                style: TextStyle(
                  fontWeight: isPaired ? FontWeight.bold : FontWeight.normal,
                  fontSize: isPaired ? 15 : 14,
                ),
              ),
            ),
            if (isPaired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Eşleşti',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          device.address,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: 'monospace',
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () => _connectToDevice(device),
          style: ElevatedButton.styleFrom(
            backgroundColor: isPaired ? Colors.blue : Colors.grey[400],
          ),
          child: Text(
            'Bağlan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: isPaired ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
