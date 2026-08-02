import 'package:flutter/material.dart';
import 'package:pandabricks/models/game_types.dart' as game_data;
import 'package:pandabricks/widgets/game/board_painter.dart';
import 'package:pandabricks/widgets/game/game_palette.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class PiecePreview extends StatelessWidget {
  const PiecePreview({required this.next, super.key});

  final game_data.FallingBlock? next;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: next != null ? 'Next piece: ${next!.name}' : 'No next piece',
      child: GlassMorphismCard(
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: CustomPaint(
              painter: _PreviewPainter(next),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter(this.next);
  final game_data.FallingBlock? next;

  static final Paint _fillPaint = Paint();
  static final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..color = Colors.black.withValues(alpha: 0.4);

  @override
  void paint(Canvas canvas, Size size) {
    if (next == null) return;
    const palette = kGamePalette;
    final cells = _cellsFor(next!);

    var minX = 0.0;
    var maxX = 0.0;
    var minY = 0.0;
    var maxY = 0.0;
    if (cells.isNotEmpty) {
      minX = maxX = cells.first.dx;
      minY = maxY = cells.first.dy;
      for (final c in cells.skip(1)) {
        if (c.dx < minX) minX = c.dx;
        if (c.dx > maxX) maxX = c.dx;
        if (c.dy < minY) minY = c.dy;
        if (c.dy > maxY) maxY = c.dy;
      }
    }
    final pieceCols = maxX - minX + 1;
    final pieceRows = maxY - minY + 1;

    const padding = 8.0;
    final maxCellW = (size.width - padding * 2) / pieceCols;
    final maxCellH = (size.height - padding * 2) / pieceRows;
    final cellSize = maxCellW < maxCellH ? maxCellW : maxCellH;

    final pieceWidth = pieceCols * cellSize;
    final pieceHeight = pieceRows * cellSize;

    final offsetX = (size.width - pieceWidth) / 2;
    final offsetY = (size.height - pieceHeight) / 2;

    final colorIndex = game_data.colorFor[next] ?? 0;
    final isSpecial = colorIndex >= kSpecialBlockStartIndex;
    final color = palette[colorIndex % palette.length];
    final fillGradient = LinearGradient(
      colors: [color.withValues(alpha: 0.95), color.withValues(alpha: 0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    for (final c in cells) {
      final x = (c.dx - minX) * cellSize + offsetX;
      final y = (c.dy - minY) * cellSize + offsetY;
      final rect = Rect.fromLTWH(x, y, cellSize, cellSize).deflate(0.5);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      _fillPaint.shader = fillGradient.createShader(rect);
      canvas.drawRRect(rrect, _fillPaint);
      canvas.drawRRect(rrect, _borderPaint);

      if (isSpecial) {
        final emoji = kSpecialBlockEmojis[colorIndex] ?? '';
        if (emoji.isNotEmpty) {
          final tp = BoardPainter.cachedEmojiPainter(
            emoji: emoji,
            sizeFactor: 0.7,
            cellSize: cellSize,
          );
          final dx = x + (cellSize - tp.width) / 2;
          final dy = y + (cellSize - tp.height) / 2;
          tp.paint(canvas, Offset(dx, dy));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PreviewPainter oldDelegate) =>
      oldDelegate.next != next;

  List<Offset> _cellsFor(game_data.FallingBlock t) {
    final shape = game_data.shapes[t]!;
    final offsets = shape[game_data.Rotation.up]!;
    return offsets.map((p) => Offset(p.x.toDouble(), p.y.toDouble())).toList();
  }
}
