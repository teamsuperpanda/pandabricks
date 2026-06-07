import 'package:flutter/material.dart';
import 'package:pandabricks/dialogs/game/action_confirm_dialog.dart';
import 'package:pandabricks/l10n/app_localizations.dart';

class RestartConfirmDialog extends StatelessWidget {
  const RestartConfirmDialog({
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
      icon: Icons.refresh_rounded,
      title: l10n.restartGame,
      subtitle: l10n.areYouSureYouWantToRestart,
      confirmLabel: l10n.restart,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}
