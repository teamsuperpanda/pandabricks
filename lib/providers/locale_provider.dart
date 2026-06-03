import 'package:flutter/material.dart';
import 'package:pandabricks/services/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  LocaleProvider({bool enablePersistence = true})
    : _enablePersistence = enablePersistence {
    if (_enablePersistence) {
      _loadLocale();
    }
  }
  Locale? _locale;
  bool _disposed = false;
  final bool _enablePersistence;

  Locale? get locale => _locale;

  static Locale? _buildLocale(
    String? languageCode,
    String? countryCode,
    String? scriptCode,
  ) {
    if (languageCode == null) return null;
    if (countryCode != null && scriptCode != null) {
      return Locale.fromSubtags(
        languageCode: languageCode,
        countryCode: countryCode,
        scriptCode: scriptCode,
      );
    }
    if (countryCode != null) {
      return Locale(languageCode, countryCode);
    }
    if (scriptCode != null) {
      return Locale.fromSubtags(
        languageCode: languageCode,
        scriptCode: scriptCode,
      );
    }
    return Locale(languageCode);
  }

  Future<void> _loadLocale() async {
    if (!_enablePersistence) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('locale_language');
      final countryCode = prefs.getString('locale_country');
      final scriptCode = prefs.getString('locale_script');
      _locale = _buildLocale(languageCode, countryCode, scriptCode);
    } catch (e) {
      logError('LocaleProvider', e);
    } finally {
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  /// Sets the locale. Persistence errors are silently logged; UI updates optimistically.
  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;

    _locale = locale;
    if (!_disposed) {
      notifyListeners();
    }

    if (!_enablePersistence) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale != null) {
        await prefs.setString('locale_language', locale.languageCode);
        if (locale.countryCode != null) {
          await prefs.setString('locale_country', locale.countryCode!);
        } else {
          await prefs.remove('locale_country');
        }
        if (locale.scriptCode != null) {
          await prefs.setString('locale_script', locale.scriptCode!);
        } else {
          await prefs.remove('locale_script');
        }
      } else {
        await prefs.remove('locale_language');
        await prefs.remove('locale_country');
        await prefs.remove('locale_script');
      }
    } catch (e) {
      logError('LocaleProvider', e);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
