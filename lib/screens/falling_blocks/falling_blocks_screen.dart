
import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:pandabricks/providers/audio_provider.dart';

import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/home/ambient_particles.dart';
import 'package:pandabricks/widgets/home/animated_background.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';
import 'package:pandabricks/widgets/falling_blocks/falling_blocks_board_painter.dart';
import 'package:pandabricks/widgets/falling_blocks/falling_blocks_controls.dart';
import 'package:pandabricks/widgets/falling_blocks/falling_blocks_hud.dart';
import 'package:pandabricks/widgets/falling_blocks/falling_blocks_preview.dart';
import 'package:pandabricks/screens/falling_blocks/falling_blocks_game.dart';
import 'package:pandabricks/dialogs/pause_dialog.dart';
import 'package:pandabricks/dialogs/restart_confirm_dialog.dart';
import 'package:pandabricks/dialogs/game_over_dialog.dart';

class FallingBlocksScreen extends StatefulWidget {
  const FallingBlocksScreen({super.key});

  @override
  State<FallingBlocksScreen> createState() => _FallingBlocksScreenState();
}

class _FallingBlocksScreenState extends State<FallingBlocksScreen> with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final Animation<double> _bgAnim;
  late FallingBlocksGame _game;
  Timer? _timer;
  Duration _tick = const Duration(milliseconds: 800);

  // gesture state
  double _dragAccum = 0;
  double _lastDx = 0;

  late AudioProvider _audioProvider;
  bool _musicStarted = false;
  bool _gameOverDialogShown = false;

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
    
    _game = FallingBlocksGame(audioProvider: _audioProvider);
    _tick = _game.currentSpeed();
    _startTimer();
    _game.addListener(_onGameChanged);
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
          _audioProvider.playMenuMusic();
          Navigator.of(context).pop();
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
          _audioProvider.playMenuMusic();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _game.removeListener(_onGameChanged);
    _bgController.dispose();
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
      ].map((c) => c.withAlpha(220)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(gradientAnimation: _bgAnim),
          const AmbientParticles(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                // playfield aspect ratio ~ 10:20 = 1:2
                final playfieldWidth = min(maxW * 0.9, 380.0);
                final playfieldHeight = playfieldWidth * 2.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      // Header with controls only
                      Row(
                        children: [
                          // Main Menu button on the left
                          GlassMorphismCard(
                            child: InkWell(
                              onTap: () {
                                _audioProvider.playMenuMusic();
                                Navigator.of(context).pop();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.home, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'Main Menu',
                                      style: TextStyle(
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
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.refresh, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'Restart',
                                      style: TextStyle(
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
                                      _game.isPaused ? 'Resume' : 'Pause',
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
                      const SizedBox(height: 14),
                      FallingBlocksHUD(score: _game.score, level: _game.level, lines: _game.linesCleared),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Playfield
                          Expanded(
                            flex: 3,
                            child: _buildPlayfield(context, playfieldWidth, playfieldHeight),
                          ),
                          const SizedBox(width: 12),
                          // Right sidebar: next piece
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Next',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 14,
                                      color: Colors.white.withAlpha(220),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FallingBlocksPreview(next: _game.next),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Controls
                      FallingBlocksControls(
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
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayfield(BuildContext context, double width, double height) {
    return GestureDetector(
      onTap: () {
        _startMusicOnFirstInteraction();
        _game.rotateCW();
      },
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
      child: GlassMorphismCard(
        child: AspectRatio(
          aspectRatio: _game.width / _game.height,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomPaint(
              painter: FallingBlocksBoardPainter(
                width: _game.width,
                height: _game.height,
                cells: _game.filledCellsWithGhost(),
                palette: _palette(context),
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}
