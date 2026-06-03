import 'package:flutter/material.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/models/game_input_callbacks.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class GameControls extends StatelessWidget {
  const GameControls({
    required this.callbacks, super.key,
  });

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
                    child: Icon(icon, color: Colors.white.withValues(alpha: 230/255.0)),
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
            btn(Icons.rotate_90_degrees_cw_rounded, callbacks.onRotate, l10n.rotatePiece),
            btn(Icons.arrow_downward_rounded, callbacks.onSoftDrop, l10n.softDrop),
            btn(Icons.vertical_align_bottom_rounded, callbacks.onHardDrop, l10n.hardDrop),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            btn(Icons.chevron_left_rounded, callbacks.onMoveLeft, l10n.moveLeft),
            btn(Icons.chevron_right_rounded, callbacks.onMoveRight, l10n.moveRight),
          ],
        ),
      ],
    );
  }
}
