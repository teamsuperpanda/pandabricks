import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class FallingBlocksHUD extends StatelessWidget {
  const FallingBlocksHUD({
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
    final textColor = Colors.white;
    return Row(
      children: [
        Expanded(
          child: GlassMorphismCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _hudItem('Level', level.toString(), textColor),
                  _hudItem('Score', score.toString(), textColor),
                  _hudItem('Lines', lines.toString(), textColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _hudItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 12,
            color: color.withAlpha(200),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
