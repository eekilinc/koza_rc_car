class ConnectionStats {
  late DateTime _connectionStartTime;
  int _commandsSent = 0;
  int _commandsFailed = 0;
  int _rssi = 0; // Signal strength
  bool _isConnected = false;
  
  static final ConnectionStats _instance = ConnectionStats._internal();
  
  factory ConnectionStats() {
    return _instance;
  }
  
  ConnectionStats._internal();
  
  void startConnection() {
    _connectionStartTime = DateTime.now();
    _commandsSent = 0;
    _commandsFailed = 0;
    _isConnected = true;
  }
  
  void recordCommandSent(bool success) {
    if (success) {
      _commandsSent++;
    } else {
      _commandsFailed++;
    }
  }
  
  void endConnection() {
    _isConnected = false;
  }
  
  Duration get connectionDuration {
    if (!_isConnected) return Duration.zero;
    return DateTime.now().difference(_connectionStartTime);
  }
  
  int get commandsSent => _commandsSent;
  int get commandsFailed => _commandsFailed;
  int get totalCommands => _commandsSent + _commandsFailed;
  
  double get successRate {
    if (totalCommands == 0) return 100.0;
    return (_commandsSent / totalCommands) * 100;
  }
  
  void setRSSI(int rssi) {
    _rssi = rssi;
  }
  
  int get rssi => _rssi;
  
  String get connectionTimeString {
    final duration = connectionDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  void reset() {
    _commandsSent = 0;
    _commandsFailed = 0;
    _rssi = 0;
    _isConnected = false;
  }
}
