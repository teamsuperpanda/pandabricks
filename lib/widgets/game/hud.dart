import 'package:flutter/material.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class GameHUD extends StatelessWidget {
  const GameHUD({
    required this.score,
    required this.level,
    required this.lines,
    super.key,
  });

  final int score;
  final int level;
  final int lines;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: 'Game HUD',
      child: Row(
        children: [
          Expanded(
            child: GlassMorphismCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _hudItem(l10n.level, level.toString()),
                    _hudItem(l10n.score, score.toString()),
                    _hudItem(l10n.lines, lines.toString()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hudItem(String label, String value) {
    return Semantics(
      label: '$label $value',
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.cyanAccent.withValues(alpha: 200 / 255.0),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: Colors.cyanAccent,
                  blurRadius: 8,
                ),
                Shadow(
                  color: Colors.blueAccent,
                  blurRadius: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
