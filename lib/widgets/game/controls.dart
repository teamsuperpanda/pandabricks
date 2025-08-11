import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class GameControls extends StatelessWidget {
  const GameControls({
    super.key,
    required this.onLeft,
    required this.onRight,
    required this.onRotate,
    required this.onSoftDrop,
    required this.onHardDrop,
  });

  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onRotate;
  final VoidCallback onSoftDrop;
  final VoidCallback onHardDrop;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback onTap) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GlassMorphismCard(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: Icon(icon, color: Colors.white.withAlpha(230)),
                ),
              ),
            ),
          ),
        );

    return Column(
      children: [
        Row(
          children: [
            btn(Icons.rotate_90_degrees_cw_rounded, onRotate),
            btn(Icons.arrow_downward_rounded, onSoftDrop),
            btn(Icons.vertical_align_bottom_rounded, onHardDrop),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            btn(Icons.chevron_left_rounded, onLeft),
            btn(Icons.chevron_right_rounded, onRight),
          ],
        ),
      ],
    );
  }
}
