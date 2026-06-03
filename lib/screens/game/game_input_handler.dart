import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pandabricks/models/game_input_callbacks.dart';

class GameInputHandler {
  GameInputHandler(GameInputCallbacks callbacks) : _callbacks = callbacks;

  final GameInputCallbacks _callbacks;

  static const double dragThreshold = 18;
  static const double minFlingVelocity = 900;
  static const int keyboardSoftDropMs = 120;

  double _dragAccum = 0;
  Timer? _keyboardDownTimer;

  final FocusNode focusNode = FocusNode();

  void dispose() {
    _keyboardDownTimer?.cancel();
    focusNode.dispose();
  }

  KeyEventResult handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.arrowLeft) {
        _callbacks.onStartMusic?.call();
        _callbacks.onMoveLeft();
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowRight) {
        _callbacks.onStartMusic?.call();
        _callbacks.onMoveRight();
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowUp) {
        _callbacks.onStartMusic?.call();
        _callbacks.onRotate();
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowDown) {
        _callbacks.onStartMusic?.call();
        _keyboardDownTimer?.cancel();
        _callbacks.onSoftDrop();
        _keyboardDownTimer = Timer.periodic(
          const Duration(milliseconds: keyboardSoftDropMs),
          (_) => _callbacks.onSoftDrop(),
        );
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.space) {
        _callbacks.onStartMusic?.call();
        _callbacks.onRotate();
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.enter) {
        _callbacks.onStartMusic?.call();
        _callbacks.onHardDrop();
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _keyboardDownTimer?.cancel();
        _keyboardDownTimer = null;
      }
    }
    return KeyEventResult.ignored;
  }

  void onHorizontalDragStart(DragStartDetails _) {
    _callbacks.onStartMusic?.call();
    _dragAccum = 0;
  }

  void onHorizontalDragUpdate(DragUpdateDetails d) {
    final dx = d.delta.dx;
    _dragAccum += dx;
    while (_dragAccum.abs() > dragThreshold) {
      if (_dragAccum > 0) {
        _callbacks.onMoveRight();
        _dragAccum -= dragThreshold;
      } else {
        _callbacks.onMoveLeft();
        _dragAccum += dragThreshold;
      }
    }
  }

  void onVerticalDragUpdate(DragUpdateDetails d) {
    if (d.primaryDelta != null && d.primaryDelta! > 6) {
      _callbacks.onSoftDrop();
    }
  }

  void onVerticalDragEnd(DragEndDetails d) {
    if (d.primaryVelocity != null && d.primaryVelocity! > minFlingVelocity) {
      _callbacks.onHardDrop();
    }
  }
}
