/// Command configuration model for RC car control
class CommandConfig {
  String forward;
  String backward;
  String left;
  String right;
  String stop;
  
  // Extra controls
  String ledOn;
  String ledOff;
  String horn;
  int speedLow;
  int speedMedium;
  int speedHigh;

  CommandConfig({
    this.forward = 'F',
    this.backward = 'B',
    this.left = 'L',
    this.right = 'R',
    this.stop = 'S',
    this.ledOn = 'L1',
    this.ledOff = 'L0',
    this.horn = 'H1',
    this.speedLow = 85,      // ~33%
    this.speedMedium = 170,  // ~66%
    this.speedHigh = 255,    // 100%
  });

  // Copy with method for easy modification
  CommandConfig copyWith({
    String? forward,
    String? backward,
    String? left,
    String? right,
    String? stop,
    String? ledOn,
    String? ledOff,
    String? horn,
    int? speedLow,
    int? speedMedium,
    int? speedHigh,
  }) {
    return CommandConfig(
      forward: forward ?? this.forward,
      backward: backward ?? this.backward,
      left: left ?? this.left,
      right: right ?? this.right,
      stop: stop ?? this.stop,
      ledOn: ledOn ?? this.ledOn,
      ledOff: ledOff ?? this.ledOff,
      horn: horn ?? this.horn,
      speedLow: speedLow ?? this.speedLow,
      speedMedium: speedMedium ?? this.speedMedium,
      speedHigh: speedHigh ?? this.speedHigh,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'forward': forward,
      'backward': backward,
      'left': left,
      'right': right,
      'stop': stop,
      'ledOn': ledOn,
      'ledOff': ledOff,
      'horn': horn,
      'speedLow': speedLow,
      'speedMedium': speedMedium,
      'speedHigh': speedHigh,
    };
  }

  // Create from JSON
  factory CommandConfig.fromJson(Map<String, dynamic> json) {
    return CommandConfig(
      forward: json['forward'] ?? 'F',
      backward: json['backward'] ?? 'B',
      left: json['left'] ?? 'L',
      right: json['right'] ?? 'R',
      stop: json['stop'] ?? 'S',
      ledOn: json['ledOn'] ?? 'L1',
      ledOff: json['ledOff'] ?? 'L0',
      horn: json['horn'] ?? 'H1',
      speedLow: json['speedLow'] ?? 85,
      speedMedium: json['speedMedium'] ?? 170,
      speedHigh: json['speedHigh'] ?? 255,
    );
  }
}
