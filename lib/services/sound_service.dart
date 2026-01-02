import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static const String _soundEnabledKey = 'sound_enabled';
  
  late SharedPreferences _prefs;
  late AudioPlayer _audioPlayer;
  bool _soundEnabled = true;
  
  static final SoundService _instance = SoundService._internal();
  
  factory SoundService() {
    return _instance;
  }
  
  SoundService._internal() {
    _audioPlayer = AudioPlayer();
  }
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _soundEnabled = _prefs.getBool(_soundEnabledKey) ?? true;
  }
  
  bool get soundEnabled => _soundEnabled;
  
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _prefs.setBool(_soundEnabledKey, enabled);
  }
  
  Future<void> playCommandSound() async {
    if (!_soundEnabled) return;
    try {
      // Short beep sound (using system sound)
      await _audioPlayer.play(
        AssetSource('sounds/command.mp3'),
      );
    } catch (e) {
      // Fallback: just print error
      print('Error playing sound: $e');
    }
  }
  
  Future<void> playSuccessSound() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(
        AssetSource('sounds/success.mp3'),
      );
    } catch (e) {
      print('Error playing sound: $e');
    }
  }
  
  Future<void> playErrorSound() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(
        AssetSource('sounds/error.mp3'),
      );
    } catch (e) {
      print('Error playing sound: $e');
    }
  }
  
  void dispose() {
    _audioPlayer.dispose();
  }
}
