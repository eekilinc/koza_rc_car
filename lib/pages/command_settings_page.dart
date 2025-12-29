import 'package:flutter/material.dart';
import '../models/command_config.dart';

/// Settings page for configuring control commands
class CommandSettingsPage extends StatefulWidget {
  final CommandConfig initialConfig;

  const CommandSettingsPage({
    Key? key,
    required this.initialConfig,
  }) : super(key: key);

  @override
  State<CommandSettingsPage> createState() => _CommandSettingsPageState();
}

class _CommandSettingsPageState extends State<CommandSettingsPage> {
  late TextEditingController _forwardController;
  late TextEditingController _backwardController;
  late TextEditingController _leftController;
  late TextEditingController _rightController;
  late TextEditingController _stopController;
  late TextEditingController _ledOnController;
  late TextEditingController _ledOffController;
  late TextEditingController _hornController;
  late TextEditingController _speedLowController;
  late TextEditingController _speedMediumController;
  late TextEditingController _speedHighController;

  @override
  void initState() {
    super.initState();
    _forwardController = TextEditingController(text: widget.initialConfig.forward);
    _backwardController = TextEditingController(text: widget.initialConfig.backward);
    _leftController = TextEditingController(text: widget.initialConfig.left);
    _rightController = TextEditingController(text: widget.initialConfig.right);
    _stopController = TextEditingController(text: widget.initialConfig.stop);
    _ledOnController = TextEditingController(text: widget.initialConfig.ledOn);
    _ledOffController = TextEditingController(text: widget.initialConfig.ledOff);
    _hornController = TextEditingController(text: widget.initialConfig.horn);
    _speedLowController = TextEditingController(text: widget.initialConfig.speedLow.toString());
    _speedMediumController = TextEditingController(text: widget.initialConfig.speedMedium.toString());
    _speedHighController = TextEditingController(text: widget.initialConfig.speedHigh.toString());
  }

  @override
  void dispose() {
    _forwardController.dispose();
    _backwardController.dispose();
    _leftController.dispose();
    _rightController.dispose();
    _stopController.dispose();
    _ledOnController.dispose();
    _ledOffController.dispose();
    _hornController.dispose();
    _speedLowController.dispose();
    _speedMediumController.dispose();
    _speedHighController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komut Ayarları'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movement Commands Section
            _buildSectionTitle('Hareket Komutları'),
            const SizedBox(height: 12),
            _buildCommandField(
              label: 'İleri Komutu',
              controller: _forwardController,
              icon: Icons.arrow_upward,
            ),
            const SizedBox(height: 16),
            _buildCommandField(
              label: 'Geri Komutu',
              controller: _backwardController,
              icon: Icons.arrow_downward,
            ),
            const SizedBox(height: 16),
            _buildCommandField(
              label: 'Sol Komutu',
              controller: _leftController,
              icon: Icons.arrow_back,
            ),
            const SizedBox(height: 16),
            _buildCommandField(
              label: 'Sağ Komutu',
              controller: _rightController,
              icon: Icons.arrow_forward,
            ),
            const SizedBox(height: 16),
            _buildCommandField(
              label: 'Dur Komutu',
              controller: _stopController,
              icon: Icons.stop_circle,
            ),
            
            // Extra Controls Section
            const SizedBox(height: 32),
            _buildSectionTitle('Ek Kontroller'),
            const SizedBox(height: 12),
            
            // LED Controls
            _buildCommandField(
              label: 'LED Aç Komutu',
              controller: _ledOnController,
              icon: Icons.lightbulb,
            ),
            const SizedBox(height: 16),
            _buildCommandField(
              label: 'LED Kapat Komutu',
              controller: _ledOffController,
              icon: Icons.lightbulb_outline,
            ),
            const SizedBox(height: 16),
            
            // Horn Control
            _buildCommandField(
              label: 'Korna Komutu',
              controller: _hornController,
              icon: Icons.volume_up,
            ),
            
            // Speed Presets Section
            const SizedBox(height: 32),
            _buildSectionTitle('Hız Hazır Ayarları (0-255)'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSpeedField(
                    label: 'Düşük Hız',
                    controller: _speedLowController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSpeedField(
                    label: 'Orta Hız',
                    controller: _speedMediumController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSpeedField(
                    label: 'Yüksek Hız',
                    controller: _speedHighController,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('İptal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.check),
                    label: const Text('Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildCommandField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: controller,
                    maxLength: 10,
                    decoration: InputDecoration(
                      hintText: 'Komut gir',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedField({
    required String label,
    required TextEditingController controller,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 3,
              decoration: InputDecoration(
                hintText: '0-255',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                counterText: '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    final newConfig = CommandConfig(
      forward: _forwardController.text.isNotEmpty ? _forwardController.text : 'F',
      backward: _backwardController.text.isNotEmpty ? _backwardController.text : 'B',
      left: _leftController.text.isNotEmpty ? _leftController.text : 'L',
      right: _rightController.text.isNotEmpty ? _rightController.text : 'R',
      stop: _stopController.text.isNotEmpty ? _stopController.text : 'S',
      ledOn: _ledOnController.text.isNotEmpty ? _ledOnController.text : 'L1',
      ledOff: _ledOffController.text.isNotEmpty ? _ledOffController.text : 'L0',
      horn: _hornController.text.isNotEmpty ? _hornController.text : 'H1',
      speedLow: int.tryParse(_speedLowController.text) ?? 85,
      speedMedium: int.tryParse(_speedMediumController.text) ?? 170,
      speedHigh: int.tryParse(_speedHighController.text) ?? 255,
    );

    Navigator.pop(context, newConfig);
  }
}
