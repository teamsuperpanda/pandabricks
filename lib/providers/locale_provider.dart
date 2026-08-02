import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pandabricks/services/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  LocaleProvider({bool enablePersistence = true})
    : _enablePersistence = enablePersistence {
    if (_enablePersistence) {
      unawaited(_loadLocale());
    }
  }
  Locale? _locale;
  bool _disposed = false;
  int _localeRevision = 0;
  final bool _enablePersistence;
  SharedPreferences? _prefs;

  Locale? get locale => _locale;

  /// Returns the cached [SharedPreferences] instance (fetched once and reused).
  Future<SharedPreferences> _prefsInstance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  static Locale? _buildLocale(String? languageCode) {
    if (languageCode == null) return null;
    return Locale(languageCode);
  }

  Future<void> _loadLocale() async {
    if (!_enablePersistence) return;

    final loadRevision = _localeRevision;
    try {
      final prefs = await _prefsInstance();
      final languageCode = prefs.getString('locale_language');
      if (_localeRevision != loadRevision) return;
      _locale = _buildLocale(languageCode);
    } catch (e) {
      logError('LocaleProvider', e);
    } finally {
      if (!_disposed && _localeRevision == loadRevision) {
        notifyListeners();
      }
    }
  }

  /// Sets the locale. Persistence errors are silently logged; UI updates optimistically.
  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;
    _localeRevision++;

    _locale = locale;
    if (!_disposed) {
      notifyListeners();
    }

    if (!_enablePersistence) return;

    try {
      final prefs = await _prefsInstance();
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
