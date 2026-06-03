import 'package:flutter/material.dart';
import 'package:pandabricks/screens/game/game.dart' as game;
import 'package:pandabricks/widgets/game/game_palette.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class PiecePreview extends StatelessWidget {
  const PiecePreview({required this.next, super.key});

  final game.FallingBlock? next;

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
  final game.FallingBlock? next;

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

    final colorIndex = game.Game.colorFor[next] ?? 0;
    final isSpecial = colorIndex >= kSpecialBlockStartIndex;

    for (final c in cells) {
      final x = (c.dx - minX) * cellSize + offsetX;
      final y = (c.dy - minY) * cellSize + offsetY;
      final rect = Rect.fromLTWH(x, y, cellSize, cellSize).deflate(0.5);
      final color = palette[colorIndex % palette.length];
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [color.withValues(alpha: 0.95), color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
      canvas.drawRRect(rrect, paint);
      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.black.withValues(alpha: 0.4);
      canvas.drawRRect(rrect, border);

      if (isSpecial) {
        final emoji = kSpecialBlockEmojis[colorIndex] ?? '';
        if (emoji.isNotEmpty) {
          final textStyle = TextStyle(
            fontSize: cellSize * 0.7,
            fontFamilyFallback: ['Noto Color Emoji', 'Apple Color Emoji'],
          );
          final tp = TextPainter(
            text: TextSpan(text: emoji, style: textStyle),
            textDirection: TextDirection.ltr,
          );
          try {
            tp.layout();
            final dx = x + (cellSize - tp.width) / 2;
            final dy = y + (cellSize - tp.height) / 2;
            tp.paint(canvas, Offset(dx, dy));
          } finally {
            tp.dispose();
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PreviewPainter oldDelegate) =>
      oldDelegate.next != next;

  List<Offset> _cellsFor(game.FallingBlock t) {
    final shape = game.Game.shapes[t]!;
    final offsets = shape[game.Rotation.up]!;
    return offsets.map((p) => Offset(p.x.toDouble(), p.y.toDouble())).toList();
  }
}
