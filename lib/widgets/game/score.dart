import 'package:flutter/material.dart';
import 'package:pandabricks/models/mode_model.dart';
import 'package:pandabricks/logic/modes/modes.dart';

class Score extends StatelessWidget {
  final ModeModel mode;

  const Score({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Modes.getModeName(mode),
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontFamily: 'Fredoka'),
          ),
          const Text(
            '0',
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontFamily: 'Fredoka'),
          ),
          const Icon(Icons.pause, color: Colors.white),
        ],
      ),
    );
  }
}
