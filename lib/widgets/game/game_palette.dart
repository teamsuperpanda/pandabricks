import 'package:flutter/material.dart';

/// Shared color palette for game piece rendering.
/// Used by both the board painter and piece preview to ensure consistency.
const List<Color> kGamePalette = [
  Color(0xFF00FFFF),       // I - Neon Cyan
  Color(0xFFFFEA00),       // O - Neon Yellow
  Color(0xFFB026FF),       // T - Neon Purple
  Color(0xFF00FF00),       // S - Neon Green
  Color(0xFFFF003C),       // Z - Neon Red
  Color(0xFF0088FF),       // J - Neon Blue
  Color(0xFFFF7B00),       // L - Neon Orange
  // Special block colors
  Color(0xFFFF1493),       // PandaBrick - Neon Pink
  Color(0xFFAAAAAA),       // GhostBrick - Silver Glow
  Color(0xFFFF9933),       // CatBrick - Vibrant Brown/Orange
  Color(0xFF00FA9A),       // TornadoBrick - Neon Spring Green
  Color(0xFFFF4500),       // BombBrick - Neon Deep Orange
];

/// Pre-computed palette with alpha applied, matching in-game rendering.
final List<Color> kGamePaletteWithAlpha =
    kGamePalette.map((c) => c).toList(growable: false);

/// Emoji overlays for special block types (index 7+).
const Map<int, String> kSpecialBlockEmojis = {
  7: '🐼',  // pandaBrick
  8: '👻',  // ghostBrick
  9: '🐱',  // catBrick
  10: '🌪️', // tornadoBrick
  11: '💣',  // bombBrick
};

/// Index at which special blocks begin in the palette.
const int kSpecialBlockStartIndex = 7;
