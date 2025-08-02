import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/dialog/glowing_button.dart';
import 'package:pandabricks/l10n/app_localizations.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.specialBricks,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildHelpItem('🐼', 'Panda Brick', l10n.pandaBrickDescription),
            _buildHelpItem('👻', 'Ghost Brick', l10n.ghostBrickDescription),
            _buildHelpItem('🐱', 'Cat Brick', l10n.catBrickDescription),
            _buildHelpItem(
                '🌪️', 'Tornado Brick', l10n.tornadoBrickDescription),
            _buildHelpItem('💣', 'Bomb Brick', l10n.bombBrickDescription),
            const SizedBox(height: 16),
            GlowingButton(
              onPressed: () => Navigator.pop(context),
              color: const Color(0xFF3498DB),
              text: l10n.close,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withAlpha((0.1 * 255).round()),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Fredoka',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
