import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const List<String> _fontFallback = [
    'NotoSans',
    'NotoSansArabic',
    'NotoSansDevanagari',
    'NotoSansBengali',
    'NotoSansSC',
    'NotoSansJP',
    'NotoSansKR',
  ];

  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
    fontFamily: 'Fredoka',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fontFallback,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fontFallback,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fontFallback,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Fredoka',
        fontWeight: FontWeight.w700,
        fontFamilyFallback: _fontFallback,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Fredoka',
        fontWeight: FontWeight.w600,
        fontFamilyFallback: _fontFallback,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Fredoka',
        fontFamilyFallback: _fontFallback,
      ),
    ),
  );
}
