import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/models/game_input_callbacks.dart';
import 'package:pandabricks/models/game_settings.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/screens/game/game.dart';
import 'package:pandabricks/screens/game/game_dialog_mediator.dart';
import 'package:pandabricks/screens/game/game_input_handler.dart';
import 'package:pandabricks/widgets/game/board_painter.dart';
import 'package:pandabricks/widgets/game/controls.dart';
import 'package:pandabricks/widgets/game/game_palette.dart';
import 'package:pandabricks/widgets/game/header_button.dart';
import 'package:pandabricks/widgets/game/hud.dart';
import 'package:pandabricks/widgets/game/preview.dart';
import 'package:pandabricks/widgets/game/timer_display.dart';
import 'package:pandabricks/widgets/home/ambient_particles.dart';
import 'package:pandabricks/widgets/home/animated_background.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';
import 'package:provider/provider.dart';

part 'game_view.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    this.settings = const GameSettings.classic(),
  });

  final GameSettings settings;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final Animation<double> _bgAnim;
  late Game _game;
  Timer? _timer;
  Duration _tick = Duration(milliseconds: Game.baseSpeedMs);
  late GameInputCallbacks _inputCallbacks;
  late GameInputHandler _inputHandler;
  late GameDialogMediator _dialogMediator;

  late AudioProvider _audioProvider;
  bool _musicStarted = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    unawaited(_bgController.repeat(reverse: true));
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

    final callbacks = GameInputCallbacks(
      onMoveLeft: () => _withMusic(_game.moveLeft),
      onMoveRight: () => _withMusic(_game.moveRight),
      onRotate: () => _withMusic(_game.rotateCW),
      onSoftDrop: () => _withMusic(_game.softDrop),
      onHardDrop: () => _withMusic(_game.hardDrop),
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

      _game = Game(
        audioProvider: _audioProvider,
        gameMode: widget.settings.mode,
        customConfig: widget.settings.customConfig,
        width: widget.settings.boardWidth,
        height: widget.settings.boardHeight,
      );
      _tick = _game.currentSpeed();
      _restartTimer();
      _game.addListener(_onGameChanged);

      _dialogMediator = GameDialogMediator(
        navigator: Navigator.of(context),
        game: _game,
        audioProvider: _audioProvider,
      );

      _initialized = true;
    }
  }

  void _onGameChanged() {
    final newTick = _game.currentSpeed();
    if (newTick != _tick) {
      _tick = newTick;
      _restartTimer();
    }
    _dialogMediator.checkGameOver();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _game.tick());
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

  @override
  void dispose() {
    _timer?.cancel();
    _game.removeListener(_onGameChanged);
    _dialogMediator.dispose();
    _bgController.dispose();
    _inputHandler.dispose();
    _game.dispose();
    unawaited(_audioProvider.playMenuMusic());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Game>.value(
      value: _game,
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
            onMainMenu: _dialogMediator.showMainMenuConfirmDialog,
            onRestart: () => _withMusic(
              _dialogMediator.showRestartDialog,
            ),
            onPause: () => _withMusic(() {
              _game.togglePause();
              if (_game.isPaused) {
                _dialogMediator.showPauseDialog();
              }
            }),
            onRotate: () => _withMusic(_game.rotateCW),
          ),
        ),
      ),
    );
  }
}
