import 'package:flutter/material.dart';
import 'dart:async';
import '../models/command_config.dart';

/// Flash/Tap Buttons controller - one-tap 1-second movement
/// Perfect for instant mode with no input lag
class FlashButtonsController extends StatefulWidget {
  final Function(String) onCommand;
  final CommandConfig commandConfig;
  final double size;

  const FlashButtonsController({
    Key? key,
    required this.onCommand,
    required this.commandConfig,
    this.size = 200,
  }) : super(key: key);

  @override
  State<FlashButtonsController> createState() => _FlashButtonsControllerState();
}

class _FlashButtonsControllerState extends State<FlashButtonsController> {
  Timer? _autoStopTimer;
  String? _lastCommand;
  static const int _commandDuration = 1000; // 1 second

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    super.dispose();
  }

  void _sendCommand(String command) {
    // Cancel existing timer
    _autoStopTimer?.cancel();

    // Send the movement command
    widget.onCommand(command);
    _lastCommand = command;

    // Auto-stop after 1 second
    _autoStopTimer = Timer(
      Duration(milliseconds: _commandDuration),
      () {
        widget.onCommand(widget.commandConfig.stop);
        _lastCommand = null;
        _autoStopTimer = null;
      },
    );
  }

  Widget _buildButton({
    required String label,
    required String command,
    required double size,
  }) {
    return GestureDetector(
      onTap: () => _sendCommand(command),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.6),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _sendCommand(command),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = widget.size / 2.2; // Daha büyük butonlar

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Işın Butonları',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        // Top button (Forward)
        _buildButton(
          label: '▲',
          command: widget.commandConfig.forward,
          size: buttonSize,
        ),
        const SizedBox(height: 16),
        // Middle row (Left, Center, Right)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(
              label: '◄',
              command: widget.commandConfig.left,
              size: buttonSize,
            ),
            SizedBox(width: buttonSize + 16),
            _buildButton(
              label: '►',
              command: widget.commandConfig.right,
              size: buttonSize,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Bottom button (Backward)
        _buildButton(
          label: '▼',
          command: widget.commandConfig.backward,
          size: buttonSize,
        ),
        const SizedBox(height: 24),
        Text(
          'Komut: ${_lastCommand ?? "Beklemede"}',
          style: TextStyle(
            fontSize: 14,
            color: _lastCommand != null ? Colors.blue : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
