import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  bool _disposed = false;
  final bool _enablePersistence;

  Locale? get locale => _locale;

  LocaleProvider({bool enablePersistence = true}) : _enablePersistence = enablePersistence {
    if (_enablePersistence) {
      _loadLocale();
    }
  }

  Future<void> _loadLocale() async {
    if (!_enablePersistence) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('locale_language');
      final countryCode = prefs.getString('locale_country');
      
      if (languageCode != null) {
        _locale = countryCode != null 
            ? Locale(languageCode, countryCode) 
            : Locale(languageCode);
      }
    } catch (e) {
      // Ignore errors and use system default
    } finally {
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

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
      } else {
        await prefs.remove('locale_language');
        await prefs.remove('locale_country');
      }
    } catch (e) {
      // Ignore save errors
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
