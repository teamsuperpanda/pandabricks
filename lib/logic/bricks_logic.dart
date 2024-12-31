import 'dart:math';
import 'package:flutter/material.dart';

class BrickShapes {
  // Brick type identifiers (0-based indices)
  static const int standardBrickStart = 0;
  static const int standardBrickEnd = 6;
  static const int pandaBrick = 7;
  static const int ghostBrick = 8;
  static const int catBrick = 9;
  static const int tornadoBrick = 10;

  // Special brick properties
  static const Map<int, String> specialBrickEmojis = {
    ghostBrick: '👻', // Ghost brick (index 8)
    catBrick: '🐱', // Cat brick (index 9)
    tornadoBrick: '🌪️', // Tornado brick (index 10)
  };

  static const List<List<List<int>>> shapes = [
    // Standard shapes (indices 0-6)
    [
      [1, 1, 1, 1],
    ],
    [
      [0, 0, 1],
      [1, 1, 1],
    ],
    [
      [1, 0, 0],
      [1, 1, 1],
    ],
    [
      [1, 1],
      [1, 1],
    ],
    [
      [0, 1, 1],
      [1, 1, 0],
    ],
    [
      [0, 1, 0],
      [1, 1, 1],
    ],
    [
      [1, 1, 0],
      [0, 1, 1],
    ],
    // Special shapes
    // Panda shape (2x2) - index 7
    [
      [7, 7],
      [7, 7],
    ],
    // Ghost shape (1x1) - index 8
    [
      [8],
    ],
    // Cat shape (3x1) - index 9
    [
      [9, 9, 9],
    ],
    // Tornado shape (T shape) - index 10
    [
      [0, 10, 0],
      [10, 10, 10],
    ],
  ];

  static final List<Color> colors = [
    Colors.cyan, // I shape (index 0)
    Colors.blue, // J shape (index 1)
    Colors.orange, // L shape (index 2)
    Colors.yellow, // O shape (index 3)
    Colors.green, // S shape (index 4)
    Colors.purple, // T shape (index 5)
    Colors.red, // Z shape (index 6)
    Colors.white, // Panda shape active (index 7)
    Colors.purple.shade300, // Ghost brick (index 8)
    Colors.orange.shade300, // Cat brick (index 9)
    Colors.blue.shade300, // Tornado brick (index 10)
  ];

  // Helper method to get emoji for a brick
  static String? getEmojiForBrick(int brickValue) {
    if (brickValue == pandaBrick) {
      return '🐼';
    }
    return specialBrickEmojis[brickValue];
  }

  // Helper methods for brick type checking
  static bool isStandardBrick(int index) =>
      index >= standardBrickStart && index <= standardBrickEnd;

  static bool isPandaBrick(int index) => index == pandaBrick;

  static bool isGhostBrick(int index) => index == ghostBrick;

  static bool isCatBrick(int index) => index == catBrick;

  // Cat brick movement logic
  static const catMovementInterval = Duration(milliseconds: 500);

  static Point<int> getNextCatMovement() {
    // Cat always moves down (y+1) and may move left (-1) or right (+1)
    int horizontalMove = Random().nextInt(3) - 1; // -1, 0, or 1
    return Point(horizontalMove, 1); // Always move down by 1
  }

  // Get color for active piece
  static Color getActiveColor(int colorIndex) {
    if (isSpecialBrick(colorIndex)) {
      return colors[colorIndex]; // Return full opacity for special bricks
    }
    return colors[colorIndex].withAlpha(230);
  }

  // Get color for placed piece
  static Color getPlacedColor(int colorIndex) {
    return colors[colorIndex]; // Remove the -1 offset, use direct indexing
  }

  // Update specialBrickIndices in GameLogic to match
  static const List<int> specialBrickIndices = [
    8,
    9,
    10
  ]; // [Ghost, Cat, Tornado]

  // Helper method to check if a brick is special (ghost or cat)
  static bool isSpecialBrick(int index) =>
      index == ghostBrick || index == catBrick || index == tornadoBrick;

  // Get glow colors for special bricks (simple glow)
  static List<Color> getGlowColors(int brickValue) {
    if (brickValue == ghostBrick) {
      return [Colors.purple.withAlpha(120)];
    }
    if (brickValue == tornadoBrick) {
      return [Colors.blue.withAlpha(120)];
    }
    return [Colors.orange.withAlpha(120)];
  }

  // Add tornado rotation logic
  static const tornadoRotationInterval = Duration(milliseconds: 500);
}
