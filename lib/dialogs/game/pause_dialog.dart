import 'package:flutter/material.dart';
import 'package:pandabricks/dialogs/game/game_dialog_wrapper.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/widgets/game/dialog_button.dart';

class PauseDialog extends StatelessWidget {
  const PauseDialog({
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
    super.key,
  });
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.gamePaused,
      child: GameDialogWrapper(
        icon: Semantics(
          label: l10n.gamePaused,
          child: const Icon(Icons.pause_circle_filled_rounded, size: 64, color: Colors.white),
        ),
        title: l10n.gamePaused,
        subtitle: l10n.yourGameIsPaused,
        actions: [
          DialogButton(icon: Icons.play_arrow_rounded, label: l10n.resume, onTap: onResume),
          const SizedBox(height: 12),
          DialogButton(icon: Icons.home_rounded, label: l10n.mainMenu, onTap: onMainMenu),
        ],
      ),
    );
  }
}
