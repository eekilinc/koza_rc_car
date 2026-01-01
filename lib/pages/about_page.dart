import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// About page with app information
class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = 'v1.0.4';

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  Future<void> _getVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _version = 'v${info.version}';
      });
    } catch (e) {
      print('Error getting version: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkımda'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App name and logo section
              Center(
                child: Column(
                  children: [
                    const AnimatedKozaLogo(),
                    const SizedBox(height: 16),
                    Text(
                      'Koza RC Car',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _version,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Description section
              Text(
                'Uygulamalar Hakkında',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'Koza RC Car, HC-06 Bluetooth modülü üzerinden Arduino tabanlı uzaktan kontrollü arabalar için tasarlanmış bir Flutter uygulamasıdır.\n\n'
                'D-Pad veya Joystick kontrol seçenekleri ile aracınızı kolayca kontrol edebilirsiniz. Komut ayarları sayesinde kontrol tuşlarınızı özelleştirebilirsiniz.',
                style: TextStyle(height: 1.6),
              ),
              const SizedBox(height: 24),

              // Features section
              Text(
                'Özellikler',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildFeatureTile(
                icon: Icons.videogame_asset,
                title: 'D-Pad Kontrol',
                description: 'Klasik dört düğme kontrolü',
              ),
              _buildFeatureTile(
                icon: Icons.touch_app,
                title: 'Joystick Kontrol',
                description: 'Analog joystick ile hassas kontrol',
              ),
              _buildFeatureTile(
                icon: Icons.bluetooth,
                title: 'HC-06 Desteği',
                description: 'Bluetooth seri iletişim modülü uyumluluğu',
              ),
              _buildFeatureTile(
                icon: Icons.settings,
                title: 'Komut Ayarları',
                description: 'Kontrol komutlarını özelleştirin',
              ),
              const SizedBox(height: 24),

              // Creator and date section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bilgiler',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Oluşturan:', 'Koza Akademi'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Tarih:', 'Aralık 2025'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Sürüm:', '1.0.0'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Platform:', 'Android, iOS, Web'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Dil:', 'Dart / Flutter'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Requirements section
              Text(
                'Gereksinimler',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildRequirementTile(
                icon: Icons.devices,
                title: 'Android Cihaz',
                description: 'API 21 ve üzeri',
              ),
              _buildRequirementTile(
                icon: Icons.bluetooth_connected,
                title: 'Bluetooth 4.0+',
                description: 'HC-06 modülü ile iletişim için',
              ),
              _buildRequirementTile(
                icon: Icons.settings_remote,
                title: 'Arduino Panosu',
                description: 'Motor kontrol devresi (L298N)',
              ),
              const SizedBox(height: 24),

              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      '© 2025 Koza Akademi',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tüm Hakları Saklıdır',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.blue[700]),
        ),
      ],
    );
  }
}

/// Animated Koza Academy Logo Widget
class AnimatedKozaLogo extends StatefulWidget {
  const AnimatedKozaLogo({Key? key}) : super(key: key);

  @override
  State<AnimatedKozaLogo> createState() => _AnimatedKozaLogoState();
}

class _AnimatedKozaLogoState extends State<AnimatedKozaLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationController,
        _scaleController,
        _fadeController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_scaleController.value * 0.1),
          child: Transform.rotate(
            angle: _rotationController.value * 2 * 3.14159265359,
            child: Opacity(
              opacity: 0.7 + (_fadeController.value * 0.3),
              child: Image.asset(
                'assets/images/koza_logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}

