import 'package:flutter/material.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class GameHUD extends StatelessWidget {
  const GameHUD({
    super.key,
    required this.score,
    required this.level,
    required this.lines,
  });

  final int score;
  final int level;
  final int lines;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: GlassMorphismCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }

  Widget _hudItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.cyanAccent.withAlpha(200),
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
                offset: Offset(0, 0),
              ),
              Shadow(
                color: Colors.blueAccent,
                blurRadius: 16,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
