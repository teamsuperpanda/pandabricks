import 'package:flutter/material.dart';

/// Color palette from app.md (WCAG AA contrast targets)
class AppColors {
  static const primary = Color(0xFF16A085); // Panda Green 600
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFF4D35E); // Bamboo Yellow 500
  static const tertiary = Color(0xFFF78FB3); // Sakura Pink 400
  static const surface = Color(0xFF101417); // Panda Charcoal
  static const surfaceVariant = Color(0xFF1A2024);
  static const onSurface = Color(0xFFE6EEF2);
  static const accent = Color(0xFF2ECC71); // Leaf
  static const danger = Color(0xFFE74C3C); // Ember
  static const info = Color(0xFF3498DB); // Sky

  // Mode-specific colors
  static const easyMode = accent; // Leaf green
  static const normalMode = info; // Sky blue
  static const blitzMode = primary; // Panda green
}
