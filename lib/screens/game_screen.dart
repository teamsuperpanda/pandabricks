import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/game/playfield.dart';
import 'package:pandabricks/widgets/game/score.dart';
import 'package:pandabricks/widgets/game/nextpiece.dart';
import 'package:pandabricks/widgets/game/controls.dart';
import 'package:pandabricks/models/mode_model.dart';
import 'package:pandabricks/logic/game_logic.dart';
import 'dart:async';
import 'package:pandabricks/dialog/game/game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  final ModeModel mode;

  const GameScreen({super.key, required this.mode});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late Timer _timer;
  GameLogic gameLogic;

  GameScreenState()
      : gameLogic = GameLogic(List.generate(20, (index) => List.filled(10, 0)));

  @override
  void initState() {
    super.initState();
    gameLogic.spawnPiece();
    _startGame();
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
        return GameOverDialog(mode: widget.mode);
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
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
            Score(mode: widget.mode),
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
            ),
          ],
        ),
      ),
    );
  }
}
