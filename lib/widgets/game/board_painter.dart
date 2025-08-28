import 'package:flutter/material.dart';

class BoardPainter extends CustomPainter {
  final int width;
  final int height;
  final Iterable<List<int>> cells; // [x,y,colorIndex] negative colorIndex => ghost
  final Iterable<List<int>> effects; // [x,y,type]
  final List<Color> palette;

  BoardPainter({
    required this.width,
    required this.height,
    required this.cells,
    this.effects = const [],
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
  final cellW = size.width / width;
  final cellH = size.height / height;

  // Force square cells: pick the smaller of the two and center the board
  final cellSize = cellW < cellH ? cellW : cellH;
  final boardWidth = cellSize * width;
  final boardHeight = cellSize * height;
  final offsetX = (size.width - boardWidth) / 2.0;
  final offsetY = (size.height - boardHeight) / 2.0;

    // Background grid subtle
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int x = 0; x <= width; x++) {
      final dx = offsetX + x * cellSize;
      canvas.drawLine(Offset(dx, offsetY), Offset(dx, offsetY + boardHeight), gridPaint);
    }
    for (int y = 0; y <= height; y++) {
      final dy = offsetY + y * cellSize;
      canvas.drawLine(Offset(offsetX, dy), Offset(offsetX + boardWidth, dy), gridPaint);
    }

    // Draw cells
    for (final triple in cells) {
      final x = triple[0];
      final y = triple[1];
      final colorIndex = triple[2];
  final rect = Rect.fromLTWH(offsetX + x * cellSize, offsetY + y * cellSize, cellSize, cellSize).deflate(1.5);
      final isGhost = colorIndex < 0;
      final idx = isGhost ? (-colorIndex - 1) : colorIndex;
      final base = palette[idx % palette.length];
      final color = isGhost ? base.withAlpha((255 * 0.25).toInt()) : base;

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      if (isGhost) {
        final paint = Paint()..color = color;
        canvas.drawRRect(rrect, paint);
      } else {
        // Fill with gradient glow
        final paint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withAlpha((255 * 0.95).toInt()),
              color.withAlpha((255 * 0.7).toInt()),
            ],
          ).createShader(rect);
        canvas.drawRRect(rrect, paint);

        // Inner highlight
        final inner = rrect.deflate(2);
        final innerPaint = Paint()
          ..shader = LinearGradient(
            colors: [Colors.white.withAlpha((255 * 0.2).toInt()), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(inner.outerRect);
        canvas.drawRRect(inner, innerPaint);
      }

      // Border
      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = Colors.black.withAlpha((255 * 0.25).toInt());
      canvas.drawRRect(rrect, border);

      // Draw emoji overlay for special blocks (we consider indices >= 7 special)
      final specialIndexStart = 7;
      if (!isGhost && idx >= specialIndexStart) {
        final emojiMap = {
          7: '🐼', // pandaBrick
          8: '👻', // ghostBrick
          9: '🐱', // catBrick
          10: '🌪️', // tornadoBrick
          11: '💣', // bombBrick
        };
        final emoji = emojiMap[idx] ?? '';
        if (emoji.isNotEmpty) {
          final textStyle = TextStyle(fontSize: rect.height * 0.6);
          final tp = TextPainter(text: TextSpan(text: emoji, style: textStyle), textDirection: TextDirection.ltr);
          tp.layout();
          final dx = rect.left + (rect.width - tp.width) / 2;
          final dy = rect.top + (rect.height - tp.height) / 2;
          tp.paint(canvas, Offset(dx, dy));
        }
      }
    }

    // Draw effects (sparkle/dissolve animation)
    for (final eff in effects) {
      final ex = eff[0];
      final ey = eff[1];
      final type = eff.length > 2 ? eff[2] : 0;
      final alpha = eff.length > 3 ? (eff[3]).clamp(0, 255) : 120;
      
      // Create sparkle/particle effect instead of solid flash
      final t = 1.0 - (alpha / 160.0); // Progress from 0 to 1
      final sparkleColor = (type == 0 ? Colors.cyanAccent : Colors.deepOrangeAccent);
      
      if (type == 0) {
        // Column sparkle effect - vertical particles
        _drawColumnSparkles(canvas, ex, cellSize, boardHeight, offsetX, offsetY, sparkleColor, t, alpha);
      } else {
        // Row sparkle effect - horizontal particles  
        _drawRowSparkles(canvas, ey, cellSize, boardWidth, offsetX, offsetY, sparkleColor, t, alpha);
      }
    }
  }

  void _drawColumnSparkles(Canvas canvas, int col, double cellSize, double boardHeight, double offsetX, double offsetY, Color sparkleColor, double t, int alpha) {
    final x = offsetX + (col + 0.5) * cellSize;
    const particleCount = 12;

    for (int i = 0; i < particleCount; i++) {
      final seed = col * 31 + i * 17;
      final baseY = offsetY + (i / particleCount) * boardHeight;
      final localOffsetX = ((seed % 41) - 20) / 20.0 * cellSize * 0.8;
      final localOffsetY = ((seed % 23) - 11) / 11.0 * cellSize * 0.5;

      // Sparkle moves outward and fades
      final sparkleX = x + localOffsetX * t * 2;
      final sparkleY = baseY + localOffsetY * t;
      final sparkleRadius = (3.0 + (seed % 5)) * (1.0 - t * 0.7);
      final sparkleAlpha = (alpha * (1.0 - t * t)).toInt().clamp(0, 255);

      if (sparkleRadius > 0.5) {
        final paint = Paint()..color = sparkleColor.withAlpha(sparkleAlpha);
        canvas.drawCircle(Offset(sparkleX, sparkleY), sparkleRadius, paint);

        // Add inner glow
        final glowPaint = Paint()..color = Colors.white.withAlpha((sparkleAlpha * 0.6).toInt().clamp(0, 255));
        canvas.drawCircle(Offset(sparkleX, sparkleY), sparkleRadius * 0.4, glowPaint);
      }
    }
  }

  void _drawRowSparkles(Canvas canvas, int row, double cellSize, double boardWidth, double offsetX, double offsetY, Color sparkleColor, double t, int alpha) {
    final y = offsetY + (row + 0.5) * cellSize;
    const particleCount = 15;

    for (int i = 0; i < particleCount; i++) {
      final seed = row * 37 + i * 19;
      final baseX = offsetX + (i / particleCount) * boardWidth;
      final localOffsetX = ((seed % 29) - 14) / 14.0 * cellSize * 0.5;
      final localOffsetY = ((seed % 31) - 15) / 15.0 * cellSize * 0.8;

      // Sparkle moves outward and fades
      final sparkleX = baseX + localOffsetX * t;
      final sparkleY = y + localOffsetY * t * 2;
      final sparkleRadius = (3.0 + (seed % 5)) * (1.0 - t * 0.7);
      final sparkleAlpha = (alpha * (1.0 - t * t)).toInt().clamp(0, 255);

      if (sparkleRadius > 0.5) {
        final paint = Paint()..color = sparkleColor.withAlpha(sparkleAlpha);
        canvas.drawCircle(Offset(sparkleX, sparkleY), sparkleRadius, paint);

        // Add inner glow
        final glowPaint = Paint()..color = Colors.white.withAlpha((sparkleAlpha * 0.6).toInt().clamp(0, 255));
        canvas.drawCircle(Offset(sparkleX, sparkleY), sparkleRadius * 0.4, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.width != width ||
        oldDelegate.height != height ||
        !identical(oldDelegate.cells, cells) ||
        !identical(oldDelegate.effects, effects);
  }
}
