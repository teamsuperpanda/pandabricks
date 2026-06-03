import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pandabricks/dialogs/game/game_dialog_wrapper.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/widgets/game/dialog_button.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class GameOverDialog extends StatelessWidget {

  const GameOverDialog({
    required this.score, required this.level, required this.lines, required this.onRestart, required this.onMainMenu, super.key,
  });
  final int score;
  final int level;
  final int lines;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formattedScore = _formatScore(score);
    return Semantics(
      label: l10n.gameOver,
      child: GameDialogWrapper(
        icon: Semantics(
          label: l10n.gameOver,
          child: const Icon(Icons.gamepad_rounded, size: 64, color: Colors.redAccent),
        ),
        title: l10n.gameOver,
        actions: [
          GlassMorphismCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Semantics(
                    label: '${l10n.finalScore} $formattedScore',
                    child: Text(l10n.finalScore, style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _scoreItem(l10n.score, formattedScore),
                      _scoreItem(l10n.level, level.toString()),
                      _scoreItem(l10n.lines, lines.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            button: true,
            label: l10n.playAgain,
            child: Row(
              children: [
                DialogButton(icon: Icons.refresh, label: l10n.playAgain, onTap: onRestart, compact: true),
                const SizedBox(width: 12),
                DialogButton(icon: Icons.home, label: l10n.mainMenu, onTap: onMainMenu, compact: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatScore(int score) => NumberFormat('#,###').format(score);

  Widget _scoreItem(String label, String value) {
    return Semantics(
      label: '$label $value',
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
