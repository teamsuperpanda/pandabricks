import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      fontFamily: 'Fredoka',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Fredoka'),
        bodyMedium: TextStyle(fontFamily: 'Fredoka'),
        bodySmall: TextStyle(fontFamily: 'Fredoka'),
        titleLarge: TextStyle(
          fontFamily: 'Fredoka',
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Fredoka',
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(fontFamily: 'Fredoka'),
      ),
    );
  }
}
