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
  static const int bombBrick = 11;

  // Special brick properties
  static const Map<int, String> specialBrickEmojis = {
    pandaBrick: '🐼', // Add panda emoji
    ghostBrick: '👻',
    catBrick: '🐱',
    tornadoBrick: '🌪️',
    bombBrick: '💣',
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
    // Bomb shape (1x1) - index 11
    [
      [11],
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
    Colors.redAccent, // Bomb brick (index 11)
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
    ghostBrick,
    catBrick,
    tornadoBrick,
    bombBrick,
  ];

  // Helper method to check if a brick is special (ghost or cat)
  static bool isSpecialBrick(int index) =>
      index == pandaBrick ||
      index == ghostBrick ||
      index == catBrick ||
      index == tornadoBrick ||
      index == bombBrick;

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

  // Helper methods for bomb brick (optional, if needed)
  static bool isBombBrick(int index) => index == bombBrick;
}

// Add this class to handle explosion particles
class ExplosionParticle {
  double x, y;
  double dx = 0, dy = 0;
  double size = 0;
  double opacity = 1.0;
  Color color = Colors.white;

  ExplosionParticle(this.x, this.y) {
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    final speed = 2 + random.nextDouble() * 8; // More varied speeds
    dx = cos(angle) * speed;
    dy = sin(angle) * speed;
    size = 4 + random.nextDouble() * 12; // More varied sizes
    opacity = 0.8 + random.nextDouble() * 0.2; // Varied initial opacity

    // Enhanced color palette for explosions
    color = [
      Colors.white,
      Colors.yellow,
      Colors.orange,
      Colors.pink,
      Colors.red,
      Colors.purple,
    ][random.nextInt(6)];
  }

  bool update() {
    x += dx;
    y += dy;
    dy += 0.2; // Reduced gravity for slower fall
    size *= 0.97; // Slower size reduction
    opacity *= 0.96; // Slower fade out
    return opacity > 0.1;
  }
}

class ExplosionPainter extends CustomPainter {
  final List<ExplosionParticle> particles;

  ExplosionPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withAlpha((particle.opacity * 255).round())
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
