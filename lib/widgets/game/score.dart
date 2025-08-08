import 'package:flutter/material.dart';
import 'package:pandabricks/models/mode_model.dart';
import 'package:pandabricks/dialog/game/pause_dialog.dart';

class Score extends StatefulWidget {
  final ModeModel mode;
  final String modeTitle;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final int score;

  const Score({
    super.key,
    required this.mode,
    required this.modeTitle,
    required this.onPause,
    required this.onResume,
    required this.score,
  });

  @override
  State<Score> createState() => _ScoreState();
}

class _ScoreState extends State<Score> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {}); // Force refresh when app is resumed
    }
  }

  void _showPauseDialog(BuildContext context) {
    widget.onPause();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PauseDialog(onResume: widget.onResume);
      },
    );
  }

  Color _getModeColor() {
    switch (widget.mode.id) {
      case ModeId.easy:
        return Colors.green;
      case ModeId.normal:
        return Colors.blue;
      case ModeId.bambooblitz:
        return Colors.orange;
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
              widget.modeTitle,
              style: TextStyle(
                color: _getModeColor(),
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
                widget.score.toString(),
                key: ValueKey<int>(widget.score),
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
