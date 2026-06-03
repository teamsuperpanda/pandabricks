import 'package:flutter/material.dart';
import 'package:pandabricks/dialogs/game/game_dialog_wrapper.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/widgets/game/dialog_button.dart';
import 'package:pandabricks/widgets/game/game_palette.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: l10n.help,
      child: GameDialogWrapper(
        icon: Semantics(
          header: true,
          child: const Icon(Icons.help_outline_rounded, size: 48, color: Colors.cyanAccent),
        ),
        title: l10n.specialBricks,
        actions: [
          Semantics(
            button: true,
            label: l10n.close,
            child: DialogButton(
              icon: Icons.close_rounded,
              label: l10n.close,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _helpRow(kSpecialBlockEmojis[7] ?? '🐼', l10n.pandaBrick, l10n.pandaBrickDescription),
            const SizedBox(height: 12),
            _helpRow(kSpecialBlockEmojis[8] ?? '👻', l10n.ghostBrick, l10n.ghostBrickDescription),
            const SizedBox(height: 12),
            _helpRow(kSpecialBlockEmojis[9] ?? '🐱', l10n.catBrick, l10n.catBrickDescription),
            const SizedBox(height: 12),
            _helpRow(kSpecialBlockEmojis[10] ?? '🌪️', l10n.tornadoBrick, l10n.tornadoBrickDescription),
            const SizedBox(height: 12),
            _helpRow(kSpecialBlockEmojis[11] ?? '💣', l10n.bombBrick, l10n.bombBrickDescription),
          ],
        ),
      ),
    );
  }

  Widget _helpRow(String emoji, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 20 / 255.0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24, fontFamilyFallback: ['Noto Color Emoji', 'Apple Color Emoji'])),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 180 / 255.0),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
