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

class GameScreenState extends State<GameScreen> {
  late Timer _timer;
  GameLogic gameLogic;
  bool isPaused = false;
  final AudioService _audioService = AudioService();

  GameScreenState()
      : gameLogic = GameLogic(List.generate(20, (index) => List.filled(10, 0)));

  @override
  void initState() {
    super.initState();
    gameLogic.spawnPiece();
    _startGame();
    if (widget.isBackgroundMusicEnabled) {
      _setupGameMusic();
    }
  }

  Future<void> _setupGameMusic() async {
    await _audioService.setupGameMusic();
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

  void _startGame() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        gameLogic.updateGame();
        if (gameLogic.isGameOver) {
          _timer.cancel();
          _showGameOverDialog();
        }
      });
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameOverDialog(
          mode: widget.mode,
          isSoundEffectsEnabled: widget.isSoundEffectsEnabled,
          isBackgroundMusicEnabled: widget.isBackgroundMusicEnabled,
        );
      },
    );
  }

  void _pauseGame() {
    setState(() {
      isPaused = true;
      _timer.cancel();
      if (widget.isBackgroundMusicEnabled) {
        _audioService.pauseGameMusic();
      }
    });
  }

  void _resumeGame() {
    setState(() {
      isPaused = false;
      _startGame();
      if (widget.isBackgroundMusicEnabled) {
        _audioService.playGameMusic();
      }
    });
  }

  void _hardDrop() {
    setState(() {
      gameLogic.hardDrop();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioService.stopGameMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            // Score row
            Score(
              mode: widget.mode,
              onPause: _pauseGame,
              onResume: _resumeGame,
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
                          child: Playfield(
                            playfield: gameLogic.playfield,
                            activePiece: gameLogic.currentPiece,
                            flashingRows: gameLogic.flashingRows,
                            onAnimationComplete: () {
                              setState(() {
                                gameLogic.removeLines();
                              });
                            },
                            isSoundEffectsEnabled: widget.isSoundEffectsEnabled,
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
            ),
          ],
        ),
      ),
    );
  }
}
