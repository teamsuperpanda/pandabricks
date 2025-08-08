import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';

  static Future<Locale?> getSelectedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_languageKey);

    if (languageCode == null || languageCode == 'system') {
      return null; // null means system default
    }
    return Locale(languageCode);
  }

  static Future<void> setLanguage(String? languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == null || languageCode == 'system') {
      await prefs.setString(_languageKey, 'system');
    } else {
      await prefs.setString(_languageKey, languageCode);
    }
  }

  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'system';
  }
}
