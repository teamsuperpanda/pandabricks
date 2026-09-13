import 'dart:async';

import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pandabricks/dialogs/game/game_over_dialog.dart';
import 'package:pandabricks/dialogs/game/main_menu_confirm_dialog.dart';
import 'package:pandabricks/dialogs/game/pause_dialog.dart';
import 'package:pandabricks/dialogs/game/restart_confirm_dialog.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/models/game_input_callbacks.dart';
import 'package:pandabricks/models/game_settings.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/screens/game/flame/panda_game.dart';
import 'package:pandabricks/screens/game/game.dart';
import 'package:pandabricks/screens/game/game_input_handler.dart';
import 'package:pandabricks/widgets/game/controls.dart';
import 'package:pandabricks/widgets/game/dialog_button.dart';
import 'package:pandabricks/widgets/game/hold_preview.dart';
import 'package:pandabricks/widgets/game/hud.dart';
import 'package:pandabricks/widgets/game/preview.dart';
import 'package:pandabricks/widgets/game/timer_display.dart';
import 'package:pandabricks/widgets/home/ambient_particles.dart';
import 'package:pandabricks/widgets/home/animated_background.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';
import 'package:provider/provider.dart';

part 'game_view.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.settings = const GameSettings.classic()});

  final GameSettings settings;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final Animation<double> _bgAnim;
  late final ValueNotifier<HudSnapshot> _hud;
  late final PandaGame _pandaGame;
  late final GameInputCallbacks _inputCallbacks;
  late final GameInputHandler _inputHandler;

  late final AudioProvider _audioProvider;
  bool _musicStarted = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _bgController.repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);
    _hud = ValueNotifier<HudSnapshot>(
      const HudSnapshot(score: 0, level: 1, lines: 0, timeRemaining: null),
    );

    final callbacks = GameInputCallbacks(
      onMoveLeft: () => _withMusic(_pandaGame.sim.moveLeft),
      onMoveRight: () => _withMusic(_pandaGame.sim.moveRight),
      onRotate: () => _withMusic(_pandaGame.sim.rotateCW),
      onSoftDrop: () => _withMusic(_pandaGame.sim.softDrop),
      onHardDrop: () => _withMusic(_pandaGame.sim.hardDrop),
      onHold: () => _withMusic(_pandaGame.sim.swapHold),
      onHoldDirection: (direction) =>
          _withMusic(() => _pandaGame.setHeldDirection(direction)),
      onStartMusic: _startMusicOnFirstInteraction,
    );
    _inputHandler = GameInputHandler(callbacks);
    _inputCallbacks = callbacks;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _audioProvider = context.read<AudioProvider>();
      if (_audioProvider.musicEnabled) {
        unawaited(_audioProvider.playGameMusic());
        _musicStarted = true;
      } else {
        unawaited(_audioProvider.stopMusic());
      }

      final sim = Game(
        audioProvider: _audioProvider,
        gameMode: widget.settings.mode,
        customConfig: widget.settings.customConfig,
        width: widget.settings.boardWidth,
        height: widget.settings.boardHeight,
      );
      _pandaGame = PandaGame(sim: sim, hud: _hud);
      PandaGame.current = _pandaGame;

      _initialized = true;
    }
  }

  void _startMusicOnFirstInteraction() {
    if (!_musicStarted && _audioProvider.musicEnabled) {
      unawaited(_audioProvider.playGameMusic());
      _musicStarted = true;
    }
  }

  void _withMusic(void Function() action) {
    _startMusicOnFirstInteraction();
    action();
  }

  void _onPause() {
    _withMusic(() {
      _pandaGame.sim.togglePause();
      if (_pandaGame.sim.isPaused) {
        _pandaGame.overlays.add('pause');
      } else {
        _pandaGame.overlays.remove('pause');
      }
      _pandaGame.pushHud();
    });
  }

  void _showRestartConfirm() {
    _withMusic(() {
      if (!_pandaGame.sim.isPaused && !_pandaGame.sim.isGameOver) {
        _pandaGame.sim.togglePause();
      }
      _pandaGame.overlays.add('restart');
    });
  }

  void _showMainMenuConfirm() {
    if (!_pandaGame.sim.isPaused && !_pandaGame.sim.isGameOver) {
      _pandaGame.sim.togglePause();
    }
    _pandaGame.overlays.add('mainmenu');
  }

  Map<String, Widget Function(BuildContext, PandaGame)> _overlayBuilders() {
    return {
      'pause': (ctx, game) => PauseDialog(
        onResume: () {
          game.overlays.remove('pause');
          game.sim.togglePause();
          game.pushHud();
          _startMusicOnFirstInteraction();
        },
        onRestart: () {
          game.overlays.remove('pause');
          game.restart();
          _startMusicOnFirstInteraction();
        },
        onMainMenu: () {
          game.overlays.remove('pause');
          _showMainMenuConfirm();
        },
      ),
      'gameover': (ctx, game) => GameOverDialog(
        score: game.sim.score,
        level: game.sim.level,
        lines: game.sim.linesCleared,
        onRestart: () {
          game.restart();
          _startMusicOnFirstInteraction();
        },
        onMainMenu: _showMainMenuConfirm,
      ),
      'restart': (ctx, game) => RestartConfirmDialog(
        onConfirm: () {
          game.overlays.remove('restart');
          game.restart();
          _startMusicOnFirstInteraction();
        },
        onCancel: () {
          game.overlays.remove('restart');
          if (game.sim.isPaused) game.sim.togglePause();
          game.pushHud();
        },
      ),
      'mainmenu': (ctx, game) => MainMenuConfirmDialog(
        onConfirm: () {
          unawaited(_audioProvider.playMenuMusic());
          context.go('/');
        },
        onCancel: () {
          game.overlays.remove('mainmenu');
          if (game.sim.isPaused) game.sim.togglePause();
          game.pushHud();
        },
      ),
    };
  }

  @override
  void dispose() {
    _inputHandler.dispose();
    _bgController.dispose();
    if (!_initialized) {
      super.dispose();
      return;
    }
    if (PandaGame.current == _pandaGame) {
      PandaGame.current = null;
    }
    _hud.dispose();
    unawaited(_audioProvider.playMenuMusic());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showMainMenuConfirm();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ),
        child: KeyboardListener(
          focusNode: _inputHandler.focusNode,
          autofocus: true,
          onKeyEvent: _inputHandler.handleKeyEvent,
          child: _GameView(
            backgroundAnimation: _bgAnim,
            inputHandler: _inputHandler,
            inputCallbacks: _inputCallbacks,
            pandaGame: _pandaGame,
            hud: _hud,
            overlayBuilders: _overlayBuilders(),
            onMainMenu: _showMainMenuConfirm,
            onRestart: _showRestartConfirm,
            onPause: _onPause,
            onRotate: () => _withMusic(_pandaGame.sim.rotateCW),
          ),
        ),
      ),
    );
  }
}
