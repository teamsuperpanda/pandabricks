import 'package:flutter/material.dart';
import 'package:pandabricks/screens/game/game.dart' as game; // avoid name clash
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';
import 'package:pandabricks/widgets/game/game_palette.dart';

class PiecePreview extends StatelessWidget {
  const PiecePreview({super.key, required this.next});

  final game.FallingBlock? next;

  @override
  Widget build(BuildContext context) {
    return GlassMorphismCard(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: CustomPaint(
            painter: _PreviewPainter(next),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  final game.FallingBlock? next;

  _PreviewPainter(this.next);

  @override
  void paint(Canvas canvas, Size size) {
    if (next == null) return;
    final palette = kGamePaletteWithAlpha;
    final cells = _cellsFor(next!);
    
  // Choose a cell size that fits the preview area while keeping square cells
  // Calculate bounds of the piece
    double minX = cells.isEmpty ? 0 : cells.map((c) => c.dx).reduce((a, b) => a < b ? a : b);
    double maxX = cells.isEmpty ? 0 : cells.map((c) => c.dx).reduce((a, b) => a > b ? a : b);
    double minY = cells.isEmpty ? 0 : cells.map((c) => c.dy).reduce((a, b) => a < b ? a : b);
    double maxY = cells.isEmpty ? 0 : cells.map((c) => c.dy).reduce((a, b) => a > b ? a : b);
  final pieceCols = (maxX - minX + 1);
  final pieceRows = (maxY - minY + 1);

  // compute cell size to fit within size while leaving some padding
  final padding = 8.0;
  final maxCellW = (size.width - padding * 2) / pieceCols;
  final maxCellH = (size.height - padding * 2) / pieceRows;
  final cellSize = maxCellW < maxCellH ? maxCellW : maxCellH;

  double pieceWidth = pieceCols * cellSize;
  double pieceHeight = pieceRows * cellSize;
    
    // Center the piece
  double offsetX = (size.width - pieceWidth) / 2;
  double offsetY = (size.height - pieceHeight) / 2;

    final colorIndex = game.Game.colorFor[next!]!;
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

      // Draw emoji overlay for special blocks
      if (isSpecial) {
        final emoji = kSpecialBlockEmojis[colorIndex] ?? '';
        if (emoji.isNotEmpty) {
          final textStyle = TextStyle(fontSize: cellSize * 0.7);
          final tp = TextPainter(text: TextSpan(text: emoji, style: textStyle), textDirection: TextDirection.ltr);
          tp.layout();
          final dx = x + (cellSize - tp.width) / 2;
          final dy = y + (cellSize - tp.height) / 2;
          tp.paint(canvas, Offset(dx, dy));
          tp.dispose();
        }
      }
    }
  }  @override
  bool shouldRepaint(covariant _PreviewPainter oldDelegate) => oldDelegate.next != next;

  List<Offset> _cellsFor(game.FallingBlock t) {
    // minimal preview using Rotation.up shapes
    final m = game.Game.shapes[t]!;
    final offsets = m[game.Rotation.up]!;
    return offsets.map((p) => Offset(p.x.toDouble(), p.y.toDouble())).toList();
  }
}
