import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/logic/bricks_logic.dart';
import 'package:flutter/material.dart';

void main() {
  group('BrickShapes Tests', () {
    test('should have correct number of standard shapes', () {
      expect(
          BrickShapes.standardBrickEnd - BrickShapes.standardBrickStart + 1, 7);
    });

    test('should correctly identify brick types', () {
      // Standard bricks
      expect(BrickShapes.isStandardBrick(0), true);
      expect(BrickShapes.isStandardBrick(6), true);
      expect(BrickShapes.isStandardBrick(7), false);

      // Special bricks
      expect(BrickShapes.isPandaBrick(7), true);
      expect(BrickShapes.isGhostBrick(8), true);
      expect(BrickShapes.isCatBrick(9), true);
    });

    test('should return correct emojis for special bricks', () {
      expect(BrickShapes.getEmojiForBrick(7), '🐼'); // Panda
      expect(BrickShapes.getEmojiForBrick(8), '👻'); // Ghost
      expect(BrickShapes.getEmojiForBrick(9), '🐱'); // Cat
      expect(BrickShapes.getEmojiForBrick(10), '🌪️'); // Tornado
      expect(BrickShapes.getEmojiForBrick(0), null); // Standard brick
    });

    test('should have correct colors for all bricks', () {
      expect(BrickShapes.colors[0], Colors.cyan); // I piece
      expect(BrickShapes.colors[1], Colors.blue); // J piece
      expect(BrickShapes.colors[2], Colors.orange); // L piece
      expect(BrickShapes.colors[3], Colors.yellow); // O piece
      expect(BrickShapes.colors[7], Colors.white); // Panda brick
    });

    test('should get correct active colors', () {
      Color standardColor = BrickShapes.getActiveColor(0);
      Color specialColor = BrickShapes.getActiveColor(8);

      expect(standardColor.a, 0.9019607843137255); // ~230/255
      expect(specialColor.a, 1.0); // 255/255
    });

    test('should get correct glow colors for special bricks', () {
      List<Color> ghostGlow = BrickShapes.getGlowColors(8);
      List<Color> catGlow = BrickShapes.getGlowColors(9);
      List<Color> tornadoGlow = BrickShapes.getGlowColors(10);

      expect(ghostGlow[0], Colors.purple.withAlpha(120));
      expect(catGlow[0], Colors.orange.withAlpha(120));
      expect(tornadoGlow[0], Colors.blue.withAlpha(120));
    });
  });
}
