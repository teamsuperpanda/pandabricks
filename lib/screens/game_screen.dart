import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/game/playfield.dart';
import 'package:pandabricks/widgets/game/score.dart';
import 'package:pandabricks/widgets/game/nextpiece.dart';
import 'package:pandabricks/widgets/game/controls.dart';

class GameScreen extends StatelessWidget {
    final String mode;

    const GameScreen({super.key, required this.mode});

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
                                            Score(mode: mode),
                                            Expanded(child: Playfield()),
                                        ],
                                    ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child: Container(
                                        color: Colors.black,
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                NextPiece(),
                                                const Spacer(),
                                            ],
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Controls(),
                    ),
                ],
            ),
        );
    }
}
