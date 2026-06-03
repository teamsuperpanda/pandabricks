import 'package:flutter/material.dart';
import 'package:pandabricks/data/locale_display_names.dart';
import 'package:pandabricks/dialogs/game/game_dialog_wrapper.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';
import 'package:provider/provider.dart';

class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();
    const supportedLocales = AppLocalizations.supportedLocales;
    final languageNames = LocaleDisplayNames.names;

    return Semantics(
      label: l10n.language,
      child: GameDialogWrapper(
        icon: Semantics(
          header: true,
          child: const Icon(Icons.language_rounded, size: 48, color: Colors.cyanAccent),
        ),
        title: l10n.language,
        child: SizedBox(
          height: 340,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: supportedLocales.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _LanguageCard(
                  languageName: l10n.system,
                  onTap: () {
                    localeProvider.setLocale(null);
                    Navigator.of(context).pop();
                  },
                );
              }
              final locale = supportedLocales[index - 1];
              final languageName = languageNames[locale.languageCode] ?? locale.languageCode;
              return _LanguageCard(
                languageName: languageName,
                onTap: () {
                  localeProvider.setLocale(locale);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.languageName,
    required this.onTap,
  });

  final String languageName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: languageName,
      child: GlassMorphismCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              languageName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
