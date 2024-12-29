import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/game/playfield.dart';
import 'package:pandabricks/widgets/game/score.dart';
import 'package:pandabricks/widgets/game/nextpiece.dart';
import 'package:pandabricks/widgets/game/controls.dart';
import 'package:pandabricks/models/mode_model.dart';
import 'package:pandabricks/logic/game_logic.dart';
import 'dart:async';

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

  void _startGame() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        gameLogic.updateGame();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: Column(
                    children: [
                      Score(mode: widget.mode),
                      Expanded(
                          child: Playfield(
                        playfield: gameLogic.playfield,
                        activePiece: gameLogic.currentPiece,
                      )),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.black,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NextPiece(),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 1,
            child: Controls(),
          ),
        ],
      ),
    );
  }
}
