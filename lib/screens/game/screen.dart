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

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

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
      unawaited(_audioProvider.stopMusic());
      if (_audioProvider.musicEnabled) {
        unawaited(_audioProvider.playGameMusic());
        _musicStarted = true;
      }

      final args = ModalRoute.of(context)?.settings.arguments;
      final settings =
          (args is GameSettings ? args : null) ?? const GameSettings.classic();

      _game = Game(
        audioProvider: _audioProvider,
        gameMode: settings.mode,
        customConfig: settings.customConfig,
        width: settings.boardWidth,
        height: settings.boardHeight,
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
    setState(() {});
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
    _bgController.dispose();
    _inputHandler.dispose();
    _game.dispose();
    unawaited(_audioProvider.playMenuMusic());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          child: Scaffold(
            body: GestureDetector(
              onHorizontalDragStart: _inputHandler.onHorizontalDragStart,
              onHorizontalDragUpdate: _inputHandler.onHorizontalDragUpdate,
              onVerticalDragUpdate: _inputHandler.onVerticalDragUpdate,
              onVerticalDragEnd: _inputHandler.onVerticalDragEnd,
              child: Stack(
                children: [
                  Semantics(
                    label: 'Background',
                    child: AnimatedBackground(gradientAnimation: _bgAnim),
                  ),
                  Semantics(
                    label: 'Ambient particles',
                    child: const AmbientParticles(),
                  ),
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                              child: Semantics(
                                label: 'Game controls header',
                                child: Row(
                                  children: [
                                    Semantics(
                                      button: true,
                                      label: '${l10n.mainMenu} button',
                                      child: HeaderButton(
                                        icon: Icons.home,
                                        label: l10n.mainMenu,
                                        onPressed: _dialogMediator
                                            .showMainMenuConfirmDialog,
                                      ),
                                    ),
                                    const Spacer(),
                                    Semantics(
                                      button: true,
                                      label: '${l10n.restart} button',
                                      child: HeaderButton(
                                        icon: Icons.refresh,
                                        label: l10n.restart,
                                        onPressed: () => _withMusic(
                                          _dialogMediator.showRestartDialog,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Consumer<Game>(
                                      builder: (context, game, _) => Semantics(
                                        button: true,
                                        label: game.isPaused
                                            ? '${l10n.resume} button'
                                            : '${l10n.pause} button',
                                        child: HeaderButton(
                                          icon: game.isPaused
                                              ? Icons.play_arrow_rounded
                                              : Icons.pause_rounded,
                                          label: game.isPaused
                                              ? l10n.resume
                                              : l10n.pause,
                                          onPressed: () => _withMusic(() {
                                            _game.togglePause();
            if (_game.isPaused) {
              _dialogMediator.showPauseDialog();
            }
                                          }),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Semantics(
                              label: 'Score display',
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: GameHUD(
                                  score: _game.score,
                                  level: _game.level,
                                  lines: _game.linesCleared,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 500,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: _buildPlayfield(context),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 2,
                                          child: Semantics(
                                            label: 'Side panel',
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    l10n.next,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 220 / 255.0,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Semantics(
                                                  label: 'Next piece preview',
                                                  child: PiecePreview(
                                                    next: _game.next,
                                                  ),
                                                ),
                                                if ((_game.gameMode ==
                                                            GameMode
                                                                .timeChallenge ||
                                                        (_game.gameMode ==
                                                                GameMode
                                                                    .custom &&
                                                            _game
                                                                    .customConfig
                                                                    ?.timeLimit !=
                                                                null)) &&
                                                    _game.timeRemaining !=
                                                        null) ...[
                                                  const SizedBox(height: 16),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      l10n.timeLeft,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha:
                                                                  220 / 255.0,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Semantics(
                                                    label:
                                                        'Time remaining: ${_game.timeRemaining!.inMinutes}:${(_game.timeRemaining!.inSeconds % 60).toString().padLeft(2, '0')}',
                                                    child: TimerDisplay(
                                                      timeRemaining:
                                                          _game.timeRemaining!,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Semantics(
                              label: 'Game controls',
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  32,
                                ),
                                child: GameControls(callbacks: _inputCallbacks),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayfield(BuildContext context) {
    return Semantics(
      label: 'Game board',
      child: GestureDetector(
        onTap: () => _withMusic(_game.rotateCW),
        child: GlassMorphismCard(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AspectRatio(
                aspectRatio: _game.width / _game.height,
                child: CustomPaint(
                  painter: BoardPainter(
                    width: _game.width,
                    height: _game.height,
                    cells: _game.filledCellsWithGhost(),
                    effects: _game.currentEffects(),
                    palette: kGamePalette,
                    version: _game.version,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
