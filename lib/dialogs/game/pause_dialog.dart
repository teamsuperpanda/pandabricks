import 'package:flutter/material.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';
import 'package:pandabricks/widgets/game/dialog_button.dart';

class PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  const PauseDialog({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassMorphismCard(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled_rounded, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              Text(l10n.gamePaused, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(l10n.yourGameIsPaused, style: const TextStyle(fontSize: 14, color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              DialogButton(icon: Icons.play_arrow_rounded, label: l10n.resume, onTap: onResume),
              const SizedBox(height: 12),
              DialogButton(icon: Icons.home_rounded, label: l10n.mainMenu, onTap: onMainMenu),
            ],
          ),
        ),
      ),
    );
  }
}
