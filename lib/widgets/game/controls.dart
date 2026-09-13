import 'package:flutter/material.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/models/game_input_callbacks.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class GameControls extends StatelessWidget {
  const GameControls({required this.callbacks, super.key});

  final GameInputCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Widget btn(IconData icon, VoidCallback onTap, String label) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Semantics(
          button: true,
          label: label,
          child: GlassMorphismCard(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 230 / 255.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Hold button: pressing starts the held direction (immediate move + DAS
    // repeat), releasing cancels it, mirroring the keyboard hold behavior.
    Widget holdBtn(IconData icon, int direction, String label) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Semantics(
          button: true,
          label: label,
          child: GlassMorphismCard(
            child: GestureDetector(
              onTapDown: (_) => callbacks.onHoldDirection?.call(direction),
              onTapUp: (_) => callbacks.onHoldDirection?.call(0),
              onTapCancel: () => callbacks.onHoldDirection?.call(0),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 230 / 255.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            btn(
              Icons.rotate_90_degrees_cw_rounded,
              callbacks.onRotate,
              l10n.rotatePiece,
            ),
            btn(
              Icons.arrow_downward_rounded,
              callbacks.onSoftDrop,
              l10n.softDrop,
            ),
            btn(
              Icons.vertical_align_bottom_rounded,
              callbacks.onHardDrop,
              l10n.hardDrop,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            holdBtn(Icons.chevron_left_rounded, -1, l10n.moveLeft),
            holdBtn(Icons.chevron_right_rounded, 1, l10n.moveRight),
            btn(
              Icons.swap_horiz_rounded,
              callbacks.onHold ?? () {},
              l10n.holdPiece,
            ),
          ],
        ),
      ],
    );
  }
}
