import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/game/game_palette.dart';

class BoardPainter extends CustomPainter {
  final int width;
  final int height;
  final Iterable<List<int>> cells; // [x,y,colorIndex] negative colorIndex => ghost
  final Iterable<List<int>> effects; // [x,y,type]
  final List<Color> palette;
  final int version; // incremented on each game state change

  BoardPainter({
    required this.width,
    required this.height,
    required this.cells,
    this.effects = const [],
    required this.palette,
    this.version = 0,
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

    // Reusable Paint object to avoid per-cell allocation
    final paint = Paint();

    // Background grid subtle glow
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final gridGlow = Paint()
      ..color = Colors.cyanAccent.withAlpha(10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
    for (int x = 0; x <= width; x++) {
      final dx = offsetX + x * cellSize;
      canvas.drawLine(Offset(dx, offsetY), Offset(dx, offsetY + boardHeight), gridGlow);
      canvas.drawLine(Offset(dx, offsetY), Offset(dx, offsetY + boardHeight), gridPaint);
    }
    for (int y = 0; y <= height; y++) {
      final dy = offsetY + y * cellSize;
      canvas.drawLine(Offset(offsetX, dy), Offset(offsetX + boardWidth, dy), gridGlow);
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
      final color = isGhost ? base.withAlpha((255 * 0.15).toInt()) : base;

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      if (isGhost) {
        paint
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..shader = null
          ..maskFilter = null;
        canvas.drawRRect(rrect, paint);
      } else {
        // Outer glowing shadow
        paint
          ..color = color.withAlpha((255 * 0.4).toInt())
          ..style = PaintingStyle.fill
          ..shader = null
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(rrect, paint);

        // Fill with gradient glow
        paint
          ..maskFilter = null
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withAlpha((255 * 1.0).toInt()),
              color.withAlpha((255 * 0.6).toInt()),
            ],
          ).createShader(rect);
        canvas.drawRRect(rrect, paint);

        // Inner highlight
        final inner = rrect.deflate(2);
        paint.shader = LinearGradient(
          colors: [Colors.white.withAlpha((255 * 0.5).toInt()), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(inner.outerRect);
        canvas.drawRRect(inner, paint);
        paint.shader = null;
      }

      // Border and edge highlight
      if (!isGhost) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = Colors.white.withAlpha((255 * 0.4).toInt());
        canvas.drawRRect(rrect, paint);
      }

      // Draw emoji overlay for special blocks (we consider indices >= 7 special)
      if (!isGhost && idx >= kSpecialBlockStartIndex) {
        final emoji = kSpecialBlockEmojis[idx] ?? '';
        if (emoji.isNotEmpty) {
          final textStyle = TextStyle(fontSize: rect.height * 0.6);
          final tp = TextPainter(text: TextSpan(text: emoji, style: textStyle), textDirection: TextDirection.ltr);
          tp.layout();
          final dx = rect.left + (rect.width - tp.width) / 2;
          final dy = rect.top + (rect.height - tp.height) / 2;
          tp.paint(canvas, Offset(dx, dy));
          tp.dispose();
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
        _drawSparkles(canvas, offsetX + (ex + 0.5) * cellSize, offsetY, true, cellSize, boardHeight, sparkleColor, t, alpha, ex);
      } else {
        _drawSparkles(canvas, offsetX, offsetY + (ey + 0.5) * cellSize, false, cellSize, boardWidth, sparkleColor, t, alpha, ey);
      }
    }
  }

  void _drawSparkles(Canvas canvas, double fixedX, double fixedY, bool isColumn,
      double cellSize, double boardExtent, Color sparkleColor, double t, int alpha, int seed0) {
    final count = isColumn ? 20 : 25;
    final glowPaint = Paint();
    final corePaint = Paint();
    final whitePaint = Paint();
    for (int i = 0; i < count; i++) {
      final seed = seed0 * (isColumn ? 31 : 37) + i * (isColumn ? 17 : 19);
      final base = isColumn
          ? Offset(fixedX, fixedY + (i / count) * boardExtent)
          : Offset(fixedX + (i / count) * boardExtent, fixedY);
      final ox = ((seed % (isColumn ? 41 : 29)) - (isColumn ? 20 : 14)) / (isColumn ? 20.0 : 14.0) * cellSize * (isColumn ? 1.5 : 1.0);
      final oy = ((seed % (isColumn ? 23 : 31)) - (isColumn ? 11 : 15)) / (isColumn ? 11.0 : 15.0) * cellSize * (isColumn ? 1.0 : 1.5);
      final sx = base.dx + ox * t * (isColumn ? 3 : 2);
      final sy = base.dy + oy * t * (isColumn ? 2 : 3);
      final r = (4.0 + (seed % 6)) * (1.0 - t * 0.8);
      final a = (alpha * (1.0 - t * t)).toInt().clamp(0, 255);
      if (r > 0.5) {
        // Sparkle glow
        glowPaint.color = sparkleColor.withAlpha((a * 0.4).toInt());
        canvas.drawCircle(Offset(sx, sy), r * 2, glowPaint);
        // Sparkle core
        corePaint.color = sparkleColor.withAlpha(a);
        canvas.drawCircle(Offset(sx, sy), r, corePaint);
        whitePaint.color = Colors.white.withAlpha((a * 0.8).toInt().clamp(0, 255));
        canvas.drawCircle(Offset(sx, sy), r * 0.5, whitePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.version != version ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}
