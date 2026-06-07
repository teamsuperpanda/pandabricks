import 'package:flutter/material.dart';
import 'package:pandabricks/dialogs/game/action_confirm_dialog.dart';
import 'package:pandabricks/l10n/app_localizations.dart';

class MainMenuConfirmDialog extends StatelessWidget {
  const MainMenuConfirmDialog({
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ActionConfirmDialog(
      icon: Icons.home_rounded,
      title: l10n.returnToMainMenu,
      subtitle: l10n.progressWillBeLost,
      confirmLabel: l10n.mainMenu,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}
