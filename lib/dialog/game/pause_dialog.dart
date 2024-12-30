import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/dialog/glowing_button.dart';
import 'package:pandabricks/services/audio_service.dart';

class PauseDialog extends StatelessWidget {
  final VoidCallback onResume;

  PauseDialog({super.key, required this.onResume}) {
    AudioService().playSound('pause');
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
              color: Colors.blue.withAlpha((0.2 * 255).round()),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_outlined,
              size: 60,
              color: Colors.white70,
            ),
            const SizedBox(height: 20),
            const Text(
              'PAUSED',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: Colors.white,
                letterSpacing: 3,
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
                  text: 'QUIT',
                ),
                const SizedBox(width: 16),
                GlowingButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onResume();
                  },
                  color: const Color(0xFF2ECC71),
                  text: 'RESUME',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
