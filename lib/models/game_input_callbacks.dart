import 'package:flutter/foundation.dart';

class GameInputCallbacks {
  const GameInputCallbacks({
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onRotate,
    required this.onSoftDrop,
    required this.onHardDrop,
    this.onStartMusic,
  });

  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onRotate;
  final VoidCallback onSoftDrop;
  final VoidCallback onHardDrop;
  final VoidCallback? onStartMusic;
}
