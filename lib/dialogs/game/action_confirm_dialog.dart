import 'package:flutter/material.dart';
import 'package:pandabricks/dialogs/game/game_dialog_wrapper.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/widgets/game/dialog_button.dart';

class ActionConfirmDialog extends StatelessWidget {
  const ActionConfirmDialog({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.onConfirm,
    this.onCancel,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: title,
      child: GameDialogWrapper(
        icon: Semantics(
          label: title,
          child: Icon(icon, size: 64, color: Colors.white),
        ),
        title: title,
        subtitle: subtitle,
        actions: [
          Semantics(
            button: true,
            child: Row(
              children: [
                DialogButton(icon: Icons.close_rounded, label: l10n.cancel, onTap: onCancel ?? () => Navigator.of(context).pop(), compact: true),
                const SizedBox(width: 12),
                DialogButton(icon: icon, label: confirmLabel, onTap: onConfirm, compact: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
