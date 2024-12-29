import 'package:flutter/material.dart';
import 'package:pandabricks/logic/game_logic.dart';
import 'package:pandabricks/models/mode_model.dart';

class Playfield extends StatefulWidget {
  final ModeModel mode;

  const Playfield({super.key, required this.mode});

  @override
  PlayfieldState createState() => PlayfieldState();
}

class PlayfieldState extends State<Playfield> {
  late GameLogic gameLogic;

  @override
  void initState() {
    super.initState();
    gameLogic = GameLogic(widget.mode);
    gameLogic.spawnPiece(); // Spawn the first piece
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          // Display the current state of the playfield
          return Container(
            margin: const EdgeInsets.all(1),
            color: gameLogic.playfield[index ~/ 10][index % 10] == 1
                ? Colors.orange // Color for the current piece
                : Colors.grey[800], // Darker color for empty spaces
          );
        },
        itemCount: 200, // 20 rows * 10 columns
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }
}
