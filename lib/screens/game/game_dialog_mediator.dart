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
  })  : _navigator = navigator,
        _game = game,
        _audioProvider = audioProvider;

  final NavigatorState _navigator;
  final Game _game;
  final AudioProvider _audioProvider;

  bool _gameOverDialogShown = false;

  void checkGameOver() {
    if (_game.isGameOver && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      Future.delayed(const Duration(milliseconds: 500), showGameOverDialog);
    }
  }

  void showPauseDialog() {
    showDialog(
      context: _navigator.context,
      barrierDismissible: false,
      builder: (context) => PauseDialog(
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
    final wasPaused = _game.isPaused;
    if (!wasPaused) {
      _game.togglePause();
    }
    showDialog(
      context: _navigator.context,
      barrierDismissible: false,
      builder: (context) => RestartConfirmDialog(
        onConfirm: () {
          Navigator.of(context).pop();
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
    if (!_game.isGameOver) return;
    showDialog(
      context: _navigator.context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
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
    final wasPaused = _game.isPaused;
    if (!wasPaused) {
      _game.togglePause();
    }
    showDialog(
      context: _navigator.context,
      barrierDismissible: false,
      builder: (context) => MainMenuConfirmDialog(
        onConfirm: () {
          Navigator.of(context).pop();
          _audioProvider.playMenuMusic();
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
}
