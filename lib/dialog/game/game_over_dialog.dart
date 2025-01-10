import 'package:flutter/material.dart';
import 'package:pandabricks/screens/game_screen.dart';
import 'package:pandabricks/models/mode_model.dart';
import 'package:pandabricks/widgets/dialog/glowing_button.dart';
import 'package:pandabricks/services/high_score_service.dart';
import 'package:pandabricks/services/audio_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameOverDialog extends StatefulWidget {
  final ModeModel mode;
  final bool isSoundEffectsEnabled;
  final bool isBackgroundMusicEnabled;
  final int finalScore;

  const GameOverDialog({
    super.key,
    required this.mode,
    required this.isSoundEffectsEnabled,
    required this.isBackgroundMusicEnabled,
    required this.finalScore,
  });

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog> {
  bool _isNewHighScore = false;
  int _previousHighScore = 0;

  @override
  void initState() {
    super.initState();
    AudioService().stopAllSounds();
    _checkHighScore();
  }

  Future<void> _checkHighScore() async {
    _previousHighScore = await HighScoreService.getHighScore(widget.mode.name);
    if (widget.finalScore > _previousHighScore) {
      setState(() => _isNewHighScore = true);
      // Save new high score
      await HighScoreService.updateHighScore(
        widget.mode.name,
        widget.finalScore,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF1A1A2E)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withAlpha((0.1 * 255).round()),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withAlpha((0.2 * 255).round()),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withAlpha((0.3 * 255).round()),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sports_score_rounded,
                size: 60,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.gameOver,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ready for Another Round?',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Final Score: ${widget.finalScore}',
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            if (_isNewHighScore) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.yellow),
                  const SizedBox(width: 8),
                  Text(
                    _previousHighScore > 0
                        ? 'New High Score!\nPrevious: $_previousHighScore'
                        : 'New High Score!',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      color: Colors.yellow,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 30),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlowingButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  color: const Color(0xFFE74C3C),
                  text: 'MENU',
                ),
                const SizedBox(width: 16),
                GlowingButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => GameScreen(
                          mode: widget.mode,
                          isSoundEffectsEnabled: widget.isSoundEffectsEnabled,
                          isBackgroundMusicEnabled:
                              widget.isBackgroundMusicEnabled,
                        ),
                      ),
                    );
                  },
                  color: const Color(0xFF2ECC71),
                  text: 'RETRY',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
