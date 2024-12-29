import 'package:flutter/material.dart';
import 'package:pandabricks/screens/game_screen.dart';
import 'package:pandabricks/models/mode_model.dart';

class GameOverDialog extends StatelessWidget {
  final ModeModel mode;

  const GameOverDialog({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.white,
      elevation: 10,
      title: const Text(
        'Game Over',
        style: TextStyle(
          fontFamily: 'Fredoka',
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: Colors.black,
        ),
      ),
      content: const Text(
        'Play Again?',
        style: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 20,
          color: Colors.black,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Navigate to Main Menu
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text(
            'Main Menu',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 18,
              color: Colors.blue,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Restart the game
            Navigator.of(context).pop(); // Close the dialog
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => GameScreen(
                  mode: mode,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Start Again'),
        ),
      ],
    );
  }
}
