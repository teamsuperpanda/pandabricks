import 'package:flutter/material.dart';

class FallingBlocksBoardPainter extends CustomPainter {
  final int width;
  final int height;
  final Iterable<List<int>> cells; // [x,y,colorIndex] negative colorIndex => ghost
  final List<Color> palette;

  FallingBlocksBoardPainter({
    required this.width,
    required this.height,
    required this.cells,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / width;
    final cellH = size.height / height;

    // Background grid subtle
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int x = 0; x <= width; x++) {
      final dx = x * cellW;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
    }
    for (int y = 0; y <= height; y++) {
      final dy = y * cellH;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    // Draw cells
    for (final triple in cells) {
      final x = triple[0];
      final y = triple[1];
      final colorIndex = triple[2];
      final rect = Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH).deflate(1.5);
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
    }
  }

  @override
  bool shouldRepaint(covariant FallingBlocksBoardPainter oldDelegate) {
    return oldDelegate.width != width ||
        oldDelegate.height != height ||
        !identical(oldDelegate.cells, cells);
  }
}
