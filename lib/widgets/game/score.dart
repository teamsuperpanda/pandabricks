import 'package:flutter/material.dart';
import 'package:pandabricks/models/mode_model.dart';
import 'package:pandabricks/logic/modes_logic.dart';
import 'package:pandabricks/dialog/game/pause_dialog.dart';

class Score extends StatelessWidget {
  final ModeModel mode;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final int score;

  const Score({
    super.key,
    required this.mode,
    required this.onPause,
    required this.onResume,
    required this.score,
  });

  void _showPauseDialog(BuildContext context) {
    onPause();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PauseDialog(onResume: onResume);
      },
    );
  }

  Color _getModeColor() {
    switch (mode.name.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'normal':
        return Colors.blue;
      case 'bambooblitz':
        return Colors.orange;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Mode text aligned to left
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              Modes.getModeName(mode),
              style: TextStyle(
                color: _getModeColor(),
                fontSize: 16,
                fontFamily: 'Fredoka',
              ),
            ),
          ),
          // Score centered absolutely
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Text(
                score.toString(),
                key: ValueKey<int>(score),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Pause button aligned to right
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.pause, color: Colors.white),
              onPressed: () => _showPauseDialog(context),
            ),
          ),
        ],
      ),
    );
  }
}
