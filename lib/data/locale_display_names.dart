import 'package:pandabricks/l10n/app_localizations.dart';

class LocaleDisplayNames {
  static Map<String, String> get names => _names;
  static final Map<String, String> _names = () {
    final map = <String, String>{};
    for (final locale in AppLocalizations.supportedLocales) {
      final loc = lookupAppLocalizations(locale);
      map[locale.languageCode] = loc.nativeName;
    }
    return map;
  }();
}
