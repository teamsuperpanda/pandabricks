import 'package:flutter/material.dart';
import 'package:pandabricks/services/language_service.dart';
import 'package:pandabricks/widgets/dialog/glowing_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageDialog extends StatefulWidget {
  final Function(Locale?) onLanguageChanged;

  const LanguageDialog({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final currentLang = await LanguageService.getCurrentLanguage();
    setState(() {
      _selectedLanguage = currentLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF1A1A2E)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withAlpha((0.1 * 255).round()),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🌍 Language',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<String>(
                value: _selectedLanguage ?? 'system',
                isExpanded: true,
                dropdownColor: const Color(0xFF2C3E50),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Fredoka',
                ),
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text(AppLocalizations.of(context)?.systemLanguage ??
                        'System'),
                  ),
                  const DropdownMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  const DropdownMenuItem(
                    value: 'es',
                    child: Text('Español'),
                  ),
                  const DropdownMenuItem(
                    value: 'fr',
                    child: Text('Français'),
                  ),
                  const DropdownMenuItem(
                    value: 'de',
                    child: Text('Deutsch'),
                  ),
                  const DropdownMenuItem(
                    value: 'it',
                    child: Text('Italiano'),
                  ),
                  const DropdownMenuItem(
                    value: 'pt',
                    child: Text('Português'),
                  ),
                  const DropdownMenuItem(
                    value: 'ja',
                    child: Text('日本語'),
                  ),
                  const DropdownMenuItem(
                    value: 'ko',
                    child: Text('한국어'),
                  ),
                  const DropdownMenuItem(
                    value: 'zh',
                    child: Text('简体中文'),
                  ),
                  const DropdownMenuItem(
                    value: 'zh_TW',
                    child: Text('繁體中文'),
                  ),
                ],
                onChanged: (String? value) async {
                  setState(() => _selectedLanguage = value);
                  await LanguageService.setLanguage(value);
                  if (value == 'system') {
                    widget.onLanguageChanged(null);
                  } else {
                    widget.onLanguageChanged(Locale(value!));
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            GlowingButton(
              onPressed: () => Navigator.pop(context),
              color: const Color(0xFF3498DB),
              text: AppLocalizations.of(context)?.close ?? 'Close',
            ),
          ],
        ),
      ),
    );
  }
}
