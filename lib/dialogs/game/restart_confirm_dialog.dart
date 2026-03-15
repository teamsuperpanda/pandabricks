import 'package:flutter/material.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';
import 'package:pandabricks/widgets/game/dialog_button.dart';

class RestartConfirmDialog extends StatelessWidget {
  final VoidCallback onRestart;
  final VoidCallback onCancel;

  const RestartConfirmDialog({
    super.key,
    required this.onRestart,
    required this.onCancel,
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
              const Icon(Icons.refresh_rounded, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              Text(l10n.restartGame, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(l10n.areYouSureYouWantToRestart, style: const TextStyle(fontSize: 14, color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  DialogButtonCompact(icon: Icons.close_rounded, label: l10n.cancel, onTap: onCancel),
                  const SizedBox(width: 12),
                  DialogButtonCompact(icon: Icons.refresh_rounded, label: l10n.restart, onTap: onRestart),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
