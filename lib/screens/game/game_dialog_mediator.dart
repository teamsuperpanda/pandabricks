import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pandabricks/dialogs/game/game_over_dialog.dart';
import 'package:pandabricks/dialogs/game/main_menu_confirm_dialog.dart';
import 'package:pandabricks/dialogs/game/pause_dialog.dart';
import 'package:pandabricks/dialogs/game/restart_confirm_dialog.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/screens/game/game.dart';

class GameDialogMediator {
  GameDialogMediator({
    required NavigatorState navigator,
    required Game game,
    required AudioProvider audioProvider,
  }) : _navigator = navigator,
       _game = game,
       _audioProvider = audioProvider;

  final NavigatorState _navigator;
  final Game _game;
  final AudioProvider _audioProvider;

  bool _gameOverDialogShown = false;
  Timer? _gameOverDialogTimer;
  bool _disposed = false;

  void checkGameOver() {
    if (!_disposed && _game.isGameOver && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      _gameOverDialogTimer = Timer(
        const Duration(milliseconds: 500),
        showGameOverDialog,
      );
    }
  }

  void dispose() {
    _disposed = true;
    _cancelPendingGameOverDialog();
  }

  void showPauseDialog() {
    _cancelPendingGameOverDialog();
    _showGameDialog(
      (context) => PauseDialog(
        onResume: () {
          Navigator.of(context).pop();
          _game.togglePause();
        },
        onRestart: () {
          Navigator.of(context).pop();
          _gameOverDialogShown = false;
          _game.reset();
        },
        onMainMenu: () {
          Navigator.of(context).pop();
          showMainMenuConfirmDialog();
        },
      ),
    );
  }

  void showRestartDialog() {
    _cancelPendingGameOverDialog();
    final wasPaused = _game.isPaused;
    if (!wasPaused) {
      _game.togglePause();
    }
    _showGameDialog(
      (context) => RestartConfirmDialog(
        onConfirm: () {
          Navigator.of(context).pop();
          // Fresh game: the game-over dialog must be able to appear again.
          _gameOverDialogShown = false;
          _game.reset();
          if (wasPaused) {
            _game.togglePause();
          }
        },
        onCancel: () {
          Navigator.of(context).pop();
          if (!wasPaused) {
            _game.togglePause();
          }
        },
      ),
    );
  }

  void showGameOverDialog() {
    if (_disposed || !_game.isGameOver) return;
    _showGameDialog(
      (context) => GameOverDialog(
        score: _game.score,
        level: _game.level,
        lines: _game.linesCleared,
        onRestart: () {
          Navigator.of(context).pop();
          _gameOverDialogShown = false;
          _game.reset();
        },
        onMainMenu: () {
          Navigator.of(context).pop();
          showMainMenuConfirmDialog();
        },
      ),
    );
  }

  void showMainMenuConfirmDialog() {
    _cancelPendingGameOverDialog();
    final wasPaused = _game.isPaused;
    if (!wasPaused) {
      _game.togglePause();
    }
    _showGameDialog(
      (context) => MainMenuConfirmDialog(
        onConfirm: () {
          Navigator.of(context).pop();
          unawaited(_audioProvider.playMenuMusic());
          _navigator.pop();
        },
        onCancel: () {
          Navigator.of(context).pop();
          if (!wasPaused) {
            _game.togglePause();
          }
        },
      ),
    );
  }

  /// Shows a modal dialog that cannot be dismissed by the system back
  /// gesture or back button; only the in-dialog buttons can close it.
  void _showGameDialog(Widget Function(BuildContext) builder) {
    unawaited(
      showDialog(
        context: _navigator.context,
        barrierDismissible: false,
        builder: (dialogContext) =>
            PopScope(canPop: false, child: builder(dialogContext)),
      ),
    );
  }

  /// Cancels a pending game-over dialog so a stale timer never stacks on
  /// top of another dialog opened by this mediator.
  void _cancelPendingGameOverDialog() {
    _gameOverDialogTimer?.cancel();
    _gameOverDialogTimer = null;
  }
}
