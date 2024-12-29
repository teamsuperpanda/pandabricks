import 'package:flutter/material.dart';

class AppTheme {
    static final ThemeData darkTheme = ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
        ),
        textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
        ),
        primaryColor: Colors.black,
    );

    // Define mode colors separately
    static const Map<String, Color> modeColors = {
        'Easy': Colors.green,
        'Normal': Colors.blue,
        'Hard': Colors.orange,
        'Bamboo Blitz': Colors.orange,
    };
} 