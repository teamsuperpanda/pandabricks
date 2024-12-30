import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/logic/bricks_logic.dart';
import 'package:flutter/material.dart';

void main() {
  group('BrickShapes', () {
    test('shapes array contains correct number of tetromino shapes', () {
      // Should have 8 shapes (7 standard tetrominoes + 1 panda brick)
      expect(BrickShapes.shapes.length, 8);

      // Test I-piece shape (first piece)
      expect(BrickShapes.shapes[0], [
        [1, 1, 1, 1],
      ]);

      // Test O-piece shape (fourth piece)
      expect(BrickShapes.shapes[3], [
        [1, 1],
        [1, 1],
      ]);

      // Test panda shape (last piece)
      expect(BrickShapes.shapes[7], [
        [8, 8],
        [8, 8],
      ]);
    });

    test('colors array matches number of shapes plus locked panda', () {
      // Should have 9 colors (7 standard + 1 panda falling + 1 panda locked)
      expect(BrickShapes.colors.length, 9);

      // Test some specific colors
      expect(BrickShapes.colors[0], Colors.cyan); // I piece
      expect(BrickShapes.colors[7], Colors.white); // Falling panda
      expect(BrickShapes.colors[8], Colors.grey); // Locked panda
    });
  });
}
