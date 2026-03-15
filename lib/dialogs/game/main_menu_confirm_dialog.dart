import 'package:flutter/material.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';
import 'package:pandabricks/widgets/game/dialog_button.dart';

class MainMenuConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const MainMenuConfirmDialog({
    super.key,
    required this.onConfirm,
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
              const Icon(Icons.home_rounded, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              Text(l10n.returnToMainMenu, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(l10n.progressWillBeLost, style: const TextStyle(fontSize: 14, color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  DialogButtonCompact(icon: Icons.close_rounded, label: l10n.cancel, onTap: onCancel),
                  const SizedBox(width: 12),
                  DialogButtonCompact(icon: Icons.home_rounded, label: l10n.mainMenu, onTap: onConfirm),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
