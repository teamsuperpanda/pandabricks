import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/game/playfield.dart';
import 'package:pandabricks/widgets/game/score.dart';
import 'package:pandabricks/widgets/game/nextpiece.dart';
import 'package:pandabricks/widgets/game/controls.dart';
import 'package:pandabricks/models/mode_model.dart';
import 'package:pandabricks/logic/game_logic.dart';
import 'dart:async';
import 'package:pandabricks/dialog/game/game_over_dialog.dart';
import 'package:pandabricks/services/audio_service.dart';
import 'package:pandabricks/l10n/app_localizations.dart';

class GameScreen extends StatefulWidget {
  final ModeModel mode;
  final bool isSoundEffectsEnabled;
  final bool isBackgroundMusicEnabled;

  const GameScreen({
    super.key,
    required this.mode,
    required this.isSoundEffectsEnabled,
    required this.isBackgroundMusicEnabled,
  });

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  dynamic _ticker; // ticker instance created via createTicker
  late GameLogic gameLogic;
  bool isPaused = false;
  final AudioService _audioService = AudioService();
  bool _isGameInitialized = false;
  bool _softDropping = false;
  bool _isHardDropInProgress = false;
  final GlobalKey<PlayfieldState> _playfieldKey = GlobalKey<PlayfieldState>();

  // Accumulator for ticker-driven gravity
  Duration _lastTick = Duration.zero;
  double _accumulatorMs = 0.0;

  @override
  void initState() {
    super.initState();
    gameLogic = GameLogic(
      List.generate(20, (index) => List.filled(10, 0)),
      _audioService,
      widget.mode,
    );
    _audioService.setSoundEffectsEnabled(widget.isSoundEffectsEnabled);
    _initGame();
  }

  Future<void> _initGame() async {
    // Start game immediately
    gameLogic.spawnPiece();
  _startTicker();
    _isGameInitialized = true;

    // Restart timer when speed changes
    gameLogic.onSpeedChanged = () {
      // No restart needed; ticker reads current speed each frame
      // Reset accumulator to make new speed effective immediately
      _accumulatorMs = 0.0;
    };

    // Handle audio setup separately
    if (widget.isBackgroundMusicEnabled) {
      try {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        await _audioService.setupGameMusic();
        if (mounted && !isPaused && _isGameInitialized) {
          _audioService.playGameMusic();
        }
      } catch (e) {
        // Handle audio setup error gracefully
        debugPrint('Audio setup error: $e');
      }
    }
  }

  void _moveLeft() {
    setState(() {
      gameLogic.movePiece(Direction.left);
    });
  }

  void _moveRight() {
    setState(() {
      gameLogic.movePiece(Direction.right);
    });
  }

  void _moveDown() {
    setState(() {
      gameLogic.movePiece(Direction.down);
      gameLogic.updateGame();
    });
  }

  void _rotate() {
    setState(() {
      gameLogic.rotatePiece();
    });
  }

  void _startTicker() {
    _ticker ??= createTicker((elapsed) {
      if (!mounted || isPaused) return;

      // Compute delta since last tick in milliseconds
      if (_lastTick == Duration.zero) {
        _lastTick = elapsed;
        return;
      }
      final dtMs = (elapsed - _lastTick).inMicroseconds / 1000.0;
      _lastTick = elapsed;

      // Determine interval based on current speed or soft drop
      final baseIntervalMs = (500.0 * (100.0 / gameLogic.currentSpeed)).clamp(40.0, 1200.0);
      final activeIntervalMs = _softDropping ? 75.0 : baseIntervalMs;

      _accumulatorMs += dtMs;

      // Update game for each interval passed (catch up if lagging)
      while (_accumulatorMs >= activeIntervalMs && mounted && !isPaused) {
        _accumulatorMs -= activeIntervalMs;
        setState(() {
          gameLogic.updateGame();
        });
        if (gameLogic.isGameOver) {
          _ticker?.stop();
          _showGameOverDialog();
          break;
        }
      }
    });
    _ticker!.start();
  }

  void _showGameOverDialog() {
    if (!mounted) return;

    // Stop background music first
    if (widget.isBackgroundMusicEnabled) {
      _audioService.stopGameMusic();
    }

    // Play game over sound only once
    if (widget.isSoundEffectsEnabled) {
      _audioService.playSound('game_over');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        mode: widget.mode,
        isSoundEffectsEnabled: widget.isSoundEffectsEnabled,
        isBackgroundMusicEnabled: widget.isBackgroundMusicEnabled,
        finalScore: gameLogic.score,
      ),
    ).then((_) {
      // Ensure that the menu music is not playing when retrying
      if (widget.isBackgroundMusicEnabled) {
        _audioService.stopMenuMusic(); // Stop menu music if it's playing
      }
    });
  }

  void _pauseGame() {
    if (!mounted) return;
    setState(() {
      isPaused = true;
  _ticker?.stop();
      if (widget.isBackgroundMusicEnabled) {
        _audioService.pauseGameMusic();
      }
    });
  }

  void _resumeGame() {
    if (!mounted) return;
    setState(() {
      isPaused = false;
  _lastTick = Duration.zero;
  _ticker?.start();
      if (widget.isBackgroundMusicEnabled && _isGameInitialized) {
        _audioService.playGameMusic();
      }
    });
  }

  void _hardDrop() {
    if (_isHardDropInProgress) return;

    setState(() {
      _isHardDropInProgress = true;
      gameLogic.hardDrop();
      // Reset the flag after a short delay to prevent multiple drops
      Future.delayed(const Duration(milliseconds: 300), () {
        _isHardDropInProgress = false;
      });
    });
  }

  void _forcePandaBrick() {
    setState(() {
      gameLogic.forceNextPandaBrick();
    });
  }

  void _handleSoftDropStart() {
  _softDropping = true;
  }

  void _handleSoftDropEnd() {
  _softDropping = false;
  }

  void _testFlip() {
    setState(() {
      gameLogic.startFlipAnimation();
    });
  }

  @override
  void dispose() {
  _ticker?.dispose();
    _audioService.stopGameMusic();
    gameLogic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String getModeTitle() {
      switch (widget.mode.id) {
        case ModeId.easy:
          return l10n.easyMode;
        case ModeId.normal:
          return l10n.normalMode;
        case ModeId.bambooblitz:
          return l10n.blitzMode;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            // Score row
            Score(
              mode: widget.mode,
              modeTitle: getModeTitle(),
              onPause: _pauseGame,
              onResume: _resumeGame,
              score: gameLogic.score,
            ),
            // Main content row
            Expanded(
              child: Row(
                children: [
                  // Playfield column
                  Expanded(
                    flex: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: 300,
                          height: 600,
                          child: RepaintBoundary(
                            child: Playfield(
                            key: _playfieldKey,
                            playfield: gameLogic.playfield,
                            activePiece: gameLogic.currentPiece,
                            isFlashing: gameLogic.isPandaFlashing,
                            flashingRows: gameLogic.flashingRows,
                            onAnimationComplete: () {
                              setState(() {
                                gameLogic.removeLines();
                              });
                            },
                            isSoundEffectsEnabled: widget.isSoundEffectsEnabled,
                            isFlipping: gameLogic.isFlipping,
                            flipProgress: gameLogic.flipProgress,
                            onTap: _rotate,
                            onSwipeDown: _hardDrop,
                            onSoftDropStart: _handleSoftDropStart,
                            onSoftDropEnd: _handleSoftDropEnd,
                            onSwipeLeft: _moveLeft,
                            onSwipeRight: _moveRight,
                            ref: (playfield) {
                              gameLogic.onPandaExplode = (x, y) {
                                _playfieldKey.currentState
                                    ?.startExplosion(x, y);
                              };
                              gameLogic.onBombExplode = (x, y) {
                                _playfieldKey.currentState
                                    ?.startExplosion(x * 30.0, y * 30.0);
                              };
                            },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Next piece column
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (gameLogic.nextPiece != null)
                            Center(
                              child: NextPiece(nextPiece: gameLogic.nextPiece!),
                            ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Controls with fixed height
            Controls(
              onLeft: _moveLeft,
              onDown: _moveDown,
              onRight: _moveRight,
              onRotate: _rotate,
              onHardDrop: _hardDrop,
              onForcePanda: _forcePandaBrick,
              onFlip: _testFlip,
            ),
          ],
        ),
      ),
    );
  }
}
