import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      fontFamily: 'Fredoka',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontFamily: 'Fredoka',
          fontFamilyFallback: [
            'NotoSans',
            'NotoSansArabic',
            'NotoSansDevanagari',
            'NotoSansBengali',
            'NotoSansSC',
            'NotoSansJP',
            'NotoSansKR',
          ],
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Fredoka',
          fontFamilyFallback: [
            'NotoSans',
            'NotoSansArabic',
            'NotoSansDevanagari',
            'NotoSansBengali',
            'NotoSansSC',
            'NotoSansJP',
            'NotoSansKR',
          ],
        ),
        bodySmall: TextStyle(
          fontFamily: 'Fredoka',
          fontFamilyFallback: [
            'NotoSans',
            'NotoSansArabic',
            'NotoSansDevanagari',
            'NotoSansBengali',
            'NotoSansSC',
            'NotoSansJP',
            'NotoSansKR',
          ],
        ),
        titleLarge: TextStyle(
          fontFamily: 'Fredoka',
          fontWeight: FontWeight.w700,
          fontFamilyFallback: [
            'NotoSans',
            'NotoSansArabic',
            'NotoSansDevanagari',
            'NotoSansBengali',
            'NotoSansSC',
            'NotoSansJP',
            'NotoSansKR',
          ],
        ),
        titleMedium: TextStyle(
          fontFamily: 'Fredoka',
          fontWeight: FontWeight.w600,
          fontFamilyFallback: [
            'NotoSans',
            'NotoSansArabic',
            'NotoSansDevanagari',
            'NotoSansBengali',
            'NotoSansSC',
            'NotoSansJP',
            'NotoSansKR',
          ],
        ),
        labelLarge: TextStyle(
          fontFamily: 'Fredoka',
          fontFamilyFallback: [
            'NotoSans',
            'NotoSansArabic',
            'NotoSansDevanagari',
            'NotoSansBengali',
            'NotoSansSC',
            'NotoSansJP',
            'NotoSansKR',
          ],
        ),
      ),
    );
  }
}
