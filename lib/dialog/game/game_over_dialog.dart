import 'package:flutter/material.dart';
import 'package:pandabricks/screens/game_screen.dart';
import 'package:pandabricks/models/mode_model.dart';
import 'package:pandabricks/widgets/dialog/glowing_button.dart';
import 'package:pandabricks/services/audio_service.dart';

class GameOverDialog extends StatelessWidget {
  final ModeModel mode;
  final bool isSoundEffectsEnabled;
  final bool isBackgroundMusicEnabled;

  GameOverDialog({
    super.key,
    required this.mode,
    required this.isSoundEffectsEnabled,
    required this.isBackgroundMusicEnabled,
  }) {
    AudioService().playSound('game_over');
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
            const Text(
              'GAME OVER',
              style: TextStyle(
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
                          mode: mode,
                          isSoundEffectsEnabled: isSoundEffectsEnabled,
                          isBackgroundMusicEnabled: isBackgroundMusicEnabled,
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
