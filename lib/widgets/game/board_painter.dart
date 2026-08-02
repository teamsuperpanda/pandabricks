import 'package:flutter/material.dart';
import 'package:pandabricks/models/game_types.dart';
import 'package:pandabricks/widgets/game/game_palette.dart';

class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.width,
    required this.height,
    required this.cells,
    required this.palette,
    this.effects = const [],
    this.version = 0,
  }) : _cachedShaderGradient = _buildShaderGradient(palette);
  final int width;
  final int height;
  final Iterable<CellRender> cells;
  final Iterable<EffectRender> effects;
  final List<Color> palette;
  final int version;

  // Bounded static caches: the oldest entry is evicted once the cap is hit.
  static const int _cacheMaxEntries = 20;
  static final Map<String, TextPainter> _emojiPainters = {};

  static final Paint _gridPaint = Paint()
    ..color = Colors.white.withValues(alpha: 15 / 255.0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  static final Paint _gridGlow = Paint()
    ..color = Colors.cyanAccent.withValues(alpha: 10 / 255.0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
  static final Paint _cellPaint = Paint();
  static final Paint _sparkleGlowPaint = Paint();
  static final Paint _sparkleCorePaint = Paint();
  static final Paint _sparkleWhitePaint = Paint();

  // Hoisted gradient used for the per-cell inner highlight.
  static const LinearGradient _innerHighlightGradient = LinearGradient(
    colors: [Colors.white54, Colors.transparent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final Map<int, LinearGradient> _cachedShaderGradient;

  static Map<int, LinearGradient> _buildShaderGradient(List<Color> palette) {
    final cache = <int, LinearGradient>{};
    for (var i = 0; i < palette.length; i++) {
      cache[i] = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          palette[i].withValues(alpha: 1),
          palette[i].withValues(alpha: 0.6),
        ],
      );
    }
    return cache;
  }

  static TextPainter cachedEmojiPainter({
    required String emoji,
    required double sizeFactor,
    required double cellSize,
  }) {
    final fontSize = cellSize * sizeFactor;
    final cacheKey = '$emoji-$fontSize';
    final cached = _emojiPainters[cacheKey];
    if (cached != null) return cached;
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: fontSize,
          fontFamilyFallback: ['Noto Color Emoji', 'Apple Color Emoji'],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    if (_emojiPainters.length >= _cacheMaxEntries) {
      _emojiPainters.remove(_emojiPainters.keys.first)?.dispose();
    }
    _emojiPainters[cacheKey] = tp;
    return tp;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / width;
    final cellH = size.height / height;

    final cellSize = cellW < cellH ? cellW : cellH;
    final boardWidth = cellSize * width;
    final boardHeight = cellSize * height;
    final offsetX = (size.width - boardWidth) / 2.0;
    final offsetY = (size.height - boardHeight) / 2.0;

    for (var x = 0; x <= width; x++) {
      final dx = offsetX + x * cellSize;
      canvas.drawLine(
        Offset(dx, offsetY),
        Offset(dx, offsetY + boardHeight),
        _gridGlow,
      );
      canvas.drawLine(
        Offset(dx, offsetY),
        Offset(dx, offsetY + boardHeight),
        _gridPaint,
      );
    }
    for (var y = 0; y <= height; y++) {
      final dy = offsetY + y * cellSize;
      canvas.drawLine(
        Offset(offsetX, dy),
        Offset(offsetX + boardWidth, dy),
        _gridGlow,
      );
      canvas.drawLine(
        Offset(offsetX, dy),
        Offset(offsetX + boardWidth, dy),
        _gridPaint,
      );
    }

    final filledCells = <CellRender>[];
    final ghostCells = <CellRender>[];
    for (final c in cells) {
      if (!c.isGhost) {
        filledCells.add(c);
      } else {
        ghostCells.add(c);
      }
    }

    // Shaders are anchored to the rect they were created with, so each cell is
    // drawn in a translated local space. That allows one shader per palette
    // color and a single inner shader to be reused across all cells.
    final fillRect = Rect.fromLTWH(0, 0, cellSize - 3, cellSize - 3);
    final fillRRect = RRect.fromRectAndRadius(
      fillRect,
      const Radius.circular(6),
    );
    final innerRRect = fillRRect.deflate(2);
    final innerShader = _innerHighlightGradient.createShader(
      innerRRect.outerRect,
    );
    final fillShaders = <int, Shader>{};

    for (final cell in filledCells) {
      final x = cell.x;
      final y = cell.y;
      final idx = cell.colorIndex % palette.length;
      final base = palette[idx];
      final rect = Rect.fromLTWH(
        offsetX + x * cellSize,
        offsetY + y * cellSize,
        cellSize,
        cellSize,
      ).deflate(1.5);

      canvas.save();
      canvas.translate(rect.left, rect.top);

      _cellPaint
        ..color = base.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill
        ..shader = null
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(fillRRect, _cellPaint);

      _cellPaint
        ..maskFilter = null
        ..shader = fillShaders[idx] ??= _cachedShaderGradient[idx]!
            .createShader(fillRect);
      canvas.drawRRect(fillRRect, _cellPaint);

      _cellPaint.shader = innerShader;
      canvas.drawRRect(innerRRect, _cellPaint);
      _cellPaint.shader = null;

      _cellPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.4);
      canvas.drawRRect(fillRRect, _cellPaint);

      if (cell.colorIndex >= kSpecialBlockStartIndex) {
        final emoji = kSpecialBlockEmojis[cell.colorIndex] ?? '';
        if (emoji.isNotEmpty) {
          final tp = cachedEmojiPainter(
            emoji: emoji,
            sizeFactor: 0.6,
            cellSize: fillRect.height,
          );
          final dx = (fillRect.width - tp.width) / 2;
          final dy = (fillRect.height - tp.height) / 2;
          tp.paint(canvas, Offset(dx, dy));
        }
      }

      canvas.restore();
    }

    for (final cell in ghostCells) {
      final x = cell.x;
      final y = cell.y;
      final rect = Rect.fromLTWH(
        offsetX + x * cellSize,
        offsetY + y * cellSize,
        cellSize,
        cellSize,
      ).deflate(1.5);
      final idx = cell.colorIndex;
      final base = palette[idx % palette.length];
      final color = base.withValues(alpha: 0.15);

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      _cellPaint
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = null
        ..maskFilter = null;
      canvas.drawRRect(rrect, _cellPaint);
    }

    for (final eff in effects) {
      final t = 1.0 - (eff.alpha / 160.0);
      final sparkleColor = (eff.type == EffectType.column
          ? Colors.cyanAccent
          : Colors.deepOrangeAccent);

      if (eff.type == EffectType.column) {
        _drawSparkles(
          canvas,
          offsetX + (eff.x + 0.5) * cellSize,
          offsetY,
          true,
          cellSize,
          boardHeight,
          sparkleColor,
          t,
          eff.alpha,
          eff.x,
        );
      } else {
        _drawSparkles(
          canvas,
          offsetX,
          offsetY + (eff.y + 0.5) * cellSize,
          false,
          cellSize,
          boardWidth,
          sparkleColor,
          t,
          eff.alpha,
          eff.y,
        );
      }
    }
  }

  void _drawSparkles(
    Canvas canvas,
    double fixedX,
    double fixedY,
    bool isColumn,
    double cellSize,
    double boardExtent,
    Color sparkleColor,
    double t,
    int alpha,
    int seed0,
  ) {
    final count = isColumn ? 20 : 25;
    for (var i = 0; i < count; i++) {
      final seed = seed0 * (isColumn ? 31 : 37) + i * (isColumn ? 17 : 19);
      final base = isColumn
          ? Offset(fixedX, fixedY + (i / count) * boardExtent)
          : Offset(fixedX + (i / count) * boardExtent, fixedY);
      final ox =
          ((seed % (isColumn ? 41 : 29)) - (isColumn ? 20 : 14)) /
          (isColumn ? 20.0 : 14.0) *
          cellSize *
          (isColumn ? 1.5 : 1.0);
      final oy =
          ((seed % (isColumn ? 23 : 31)) - (isColumn ? 11 : 15)) /
          (isColumn ? 11.0 : 15.0) *
          cellSize *
          (isColumn ? 1.0 : 1.5);
      final sx = base.dx + ox * t * (isColumn ? 3 : 2);
      final sy = base.dy + oy * t * (isColumn ? 2 : 3);
      final r = (4.0 + (seed % 6)) * (1.0 - t * 0.8);
      final a = (alpha * (1.0 - t * t)).toInt().clamp(0, 255);
      _sparkleGlowPaint.color = sparkleColor.withValues(
        alpha: (a * 0.4 / 255).clamp(0.0, 1.0),
      );
      canvas.drawCircle(Offset(sx, sy), r * 2, _sparkleGlowPaint);
      _sparkleCorePaint.color = sparkleColor.withValues(alpha: a / 255.0);
      canvas.drawCircle(Offset(sx, sy), r, _sparkleCorePaint);
      _sparkleWhitePaint.color = Colors.white.withValues(
        alpha: ((a * 0.8) / 255.0).clamp(0.0, 1.0),
      );
      canvas.drawCircle(Offset(sx, sy), r * 0.5, _sparkleWhitePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.version != version ||
        oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.palette != palette;
  }
}
