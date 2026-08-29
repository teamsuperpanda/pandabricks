import 'package:flutter/foundation.dart';

class GameInputCallbacks {
  const GameInputCallbacks({
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onRotate,
    required this.onSoftDrop,
    required this.onHardDrop,
    this.onHold,
    this.onHoldDirection,
    this.onStartMusic,
  });

  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onRotate;
  final VoidCallback onSoftDrop;
  final VoidCallback onHardDrop;

  /// Swaps the active piece into hold. Usable once per drop.
  final VoidCallback? onHold;

  /// Held-direction changes: -1 left, 1 right, 0 released. Drives DAS/ARR.
  final void Function(int direction)? onHoldDirection;
  final VoidCallback? onStartMusic;
}
