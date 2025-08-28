
import 'package:pandabricks/l10n/app_localizations.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:pandabricks/providers/audio_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pandabricks/widgets/home/ambient_particles.dart';
import 'package:pandabricks/widgets/home/animated_background.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';
import 'package:pandabricks/widgets/game/board_painter.dart';
import 'package:pandabricks/widgets/game/controls.dart';
import 'package:pandabricks/widgets/game/hud.dart';
import 'package:pandabricks/widgets/game/preview.dart';
import 'package:pandabricks/widgets/game/timer_display.dart';
import 'package:pandabricks/screens/game/game.dart';
import 'package:pandabricks/dialogs/game/pause_dialog.dart';
import 'package:pandabricks/dialogs/game/restart_confirm_dialog.dart';
import 'package:pandabricks/dialogs/game/game_over_dialog.dart';
import 'package:pandabricks/dialogs/game/main_menu_confirm_dialog.dart';

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
  Duration _tick = const Duration(milliseconds: 800);
  // Keyboard focus and down-key soft drop timer
  late FocusNode _focusNode;
  Timer? _keyboardDownTimer;

  // gesture state
  double _dragAccum = 0;
  double _lastDx = 0;

  late AudioProvider _audioProvider;
  bool _musicStarted = false;
  bool _gameOverDialogShown = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(duration: const Duration(seconds: 10), vsync: this)..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

    // Initialize audio provider first
    _audioProvider = context.read<AudioProvider>();
    
    // Stop menu music and start game music immediately
    _audioProvider.stopMusic();
    if (_audioProvider.musicEnabled.value) {
      _audioProvider.playGameMusic();
      _musicStarted = true;
    }
  // Keyboard focus for desktop/web
  _focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_initialized) {
      // Get game mode from route arguments
      final arguments = ModalRoute.of(context)?.settings.arguments as String?;
      final gameMode = arguments == 'timeChallenge' 
          ? GameMode.timeChallenge 
          : arguments == 'blitz'
              ? GameMode.blitz
              : GameMode.classic;
      
      _game = Game(audioProvider: _audioProvider, gameMode: gameMode);
      _tick = _game.currentSpeed();
      _startTimer();
      _game.addListener(_onGameChanged);
      _initialized = true;
    }
  }

  void _onGameChanged() {
    final newTick = _game.currentSpeed();
    if (newTick != _tick) {
      _tick = newTick;
      _restartTimer();
    }
    
    // Check for game over state
    if (_game.isGameOver && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      // Show game over dialog after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _game.isGameOver) {
          _showGameOverDialog();
        }
      });
    }
    
    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _game.tick());
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _game.tick());
  }

  void _startMusicOnFirstInteraction() {
    if (!_musicStarted && _audioProvider.musicEnabled.value) {
      _audioProvider.playGameMusic();
      _musicStarted = true;
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
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
          _showMainMenuConfirmDialog();
        },
      ),
    );
  }

  void _showRestartDialog() {
    bool wasPaused = _game.isPaused;
    if (!wasPaused) {
      _game.togglePause(); // Pause the game
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RestartConfirmDialog(
        onRestart: () {
          Navigator.of(context).pop();
          _game.reset();
          if (wasPaused) {
            _game.togglePause(); // Resume if it was already paused
          }
        },
        onCancel: () {
          Navigator.of(context).pop();
          if (!wasPaused) {
            _game.togglePause(); // Resume if we paused it
          }
        },
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
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
          _showMainMenuConfirmDialog();
        },
      ),
    );
  }

  void _showMainMenuConfirmDialog() {
    bool wasPaused = _game.isPaused;
    if (!wasPaused) {
      _game.togglePause(); // Pause the game
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MainMenuConfirmDialog(
        onConfirm: () {
          Navigator.of(context).pop();
          _audioProvider.playMenuMusic();
          Navigator.of(context).pop();
        },
        onCancel: () {
          Navigator.of(context).pop();
          if (!wasPaused) {
            _game.togglePause(); // Resume if we paused it
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
  _keyboardDownTimer?.cancel();
    _game.removeListener(_onGameChanged);
    _bgController.dispose();
  _focusNode.dispose();
    // Stop music when leaving game screen
    if (mounted) {
      _audioProvider.playMenuMusic();
    }
    super.dispose();
  }

  List<Color> _palette(BuildContext context) => [
        Colors.cyanAccent,
        Colors.yellowAccent,
        Colors.purpleAccent,
        Colors.greenAccent,
        Colors.redAccent,
        Colors.blueAccent,
        Colors.orangeAccent,
        // Special block colors
        Colors.pink,           // PandaBrick
        Colors.grey,           // GhostBrick
        Colors.brown,          // CatBrick
        Colors.tealAccent,     // TornadoBrick
        Colors.deepOrangeAccent, // BombBrick
      ].map((c) => c.withAlpha(220)).toList();

  @override
    Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        // Only handle key down/up for physical keyboards
        if (event is KeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowLeft) {
            _startMusicOnFirstInteraction();
            _game.moveLeft();
          } else if (key == LogicalKeyboardKey.arrowRight) {
            _startMusicOnFirstInteraction();
            _game.moveRight();
          } else if (key == LogicalKeyboardKey.arrowUp) {
            _startMusicOnFirstInteraction();
            _game.rotateCW();
          } else if (key == LogicalKeyboardKey.arrowDown) {
            _startMusicOnFirstInteraction();
            // Start a timer to repeatedly soft-drop while held
            _keyboardDownTimer?.cancel();
            _game.softDrop();
            _keyboardDownTimer = Timer.periodic(const Duration(milliseconds: 120), (_) => _game.softDrop());
          }
        } else if (event is KeyUpEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _keyboardDownTimer?.cancel();
            _keyboardDownTimer = null;
          }
        }
      },
      child: Scaffold(
        body: GestureDetector(
          onHorizontalDragStart: (d) {
            _startMusicOnFirstInteraction();
            _dragAccum = 0;
            _lastDx = d.localPosition.dx;
          },
          onHorizontalDragUpdate: (d) {
            final dx = d.localPosition.dx;
            final delta = dx - _lastDx;
            _dragAccum += delta;
            _lastDx = dx;
            const threshold = 18.0;
            while (_dragAccum.abs() > threshold) {
              if (_dragAccum > 0) {
                _game.moveRight();
                _dragAccum -= threshold;
              } else {
                _game.moveLeft();
                _dragAccum += threshold;
              }
            }
          },
          onVerticalDragUpdate: (d) {
            if (d.primaryDelta != null && d.primaryDelta! > 6) {
              _game.softDrop();
            }
          },
          onVerticalDragEnd: (d) {
            // Quick downward fling triggers hard drop
            if (d.primaryVelocity != null && d.primaryVelocity! > 900) {
              _game.hardDrop();
            }
          },
          child: Stack(
            children: [
              AnimatedBackground(gradientAnimation: _bgAnim),
              const AmbientParticles(),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        // Header with controls only
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Row(
                            children: [
                              // Main Menu button on the left
                              GlassMorphismCard(
                                child: InkWell(
                                  onTap: () {
                                    _showMainMenuConfirmDialog();
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.home, color: Colors.white),
                                        const SizedBox(width: 6),
                                        Text(
                                          l10n.mainMenu,
                                          style: const TextStyle(
                                            fontFamily: 'Fredoka',
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Restart button in the middle
                              GlassMorphismCard(
                                child: InkWell(
                                  onTap: () {
                                    _startMusicOnFirstInteraction();
                                    _showRestartDialog();
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.refresh, color: Colors.white),
                                        const SizedBox(width: 6),
                                        Text(
                                          l10n.restart,
                                          style: const TextStyle(
                                            fontFamily: 'Fredoka',
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Pause/Resume button on the right
                              GlassMorphismCard(
                                child: InkWell(
                                  onTap: () {
                                    _startMusicOnFirstInteraction();
                                    if (_game.isPaused) {
                                      _game.togglePause();
                                    } else {
                                      _game.togglePause();
                                      _showPauseDialog();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _game.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _game.isPaused ? l10n.resume : l10n.pause,
                                          style: const TextStyle(
                                            fontFamily: 'Fredoka',
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // HUD
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GameHUD(score: _game.score, level: _game.level, lines: _game.linesCleared),
                        ),
                        const SizedBox(height: 14),
                        // Main game area that expands to fill available space
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 500),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Playfield
                                    Expanded(
                                      flex: 5,
                                      child: _buildPlayfield(context),
                                    ),
                                    const SizedBox(width: 12),
                                    // Right sidebar: next piece and timer
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              l10n.next,
                                              style: TextStyle(
                                                fontFamily: 'Fredoka',
                                                fontSize: 14,
                                                color: Colors.white.withAlpha(220),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          PiecePreview(next: _game.next),
                                          if (_game.gameMode == GameMode.timeChallenge && _game.timeRemaining != null) ...[
                                            const SizedBox(height: 16),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                l10n.timeLeft,
                                                style: TextStyle(
                                                  fontFamily: 'Fredoka',
                                                  fontSize: 14,
                                                  color: Colors.white.withAlpha(220),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TimerDisplay(timeRemaining: _game.timeRemaining!),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Controls at the bottom
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                          child: GameControls(
                            onLeft: () {
                              _startMusicOnFirstInteraction();
                              _game.moveLeft();
                            },
                            onRight: () {
                              _startMusicOnFirstInteraction();
                              _game.moveRight();
                            },
                            onRotate: () {
                              _startMusicOnFirstInteraction();
                              _game.rotateCW();
                            },
                            onSoftDrop: () {
                              _startMusicOnFirstInteraction();
                              _game.softDrop();
                            },
                            onHardDrop: () {
                              _startMusicOnFirstInteraction();
                              _game.hardDrop();
                            },
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
    );
  }

  Widget _buildPlayfield(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _startMusicOnFirstInteraction();
        _game.rotateCW();
      },
      child: GlassMorphismCard(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxHeight: double.infinity,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: _game.width / _game.height,
              child: CustomPaint(
                painter: BoardPainter(
                  width: _game.width,
                  height: _game.height,
                  cells: _game.filledCellsWithGhost(),
                  effects: _game.currentEffects(),
                  palette: _palette(context),
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

