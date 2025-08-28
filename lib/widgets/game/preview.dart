import 'package:flutter/material.dart';
import 'package:pandabricks/screens/game/game.dart' as game; // avoid name clash
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class PiecePreview extends StatelessWidget {
  const PiecePreview({super.key, required this.next});

  final game.FallingBlock? next;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassMorphismCard(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: CustomPaint(
            painter: _PreviewPainter(next, theme),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  final game.FallingBlock? next;
  final ThemeData theme;

  _PreviewPainter(this.next, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    if (next == null) return;
    final palette = _palette(theme);
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
    final isSpecial = colorIndex >= 7; // Special blocks start at index 7

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
        final emojiMap = {
          7: '🐼', // pandaBrick
          8: '👻', // ghostBrick
          9: '🐱', // catBrick
          10: '🌪️', // tornadoBrick
          11: '💣', // bombBrick
        };
        final emoji = emojiMap[colorIndex] ?? '';
        if (emoji.isNotEmpty) {
          final textStyle = TextStyle(fontSize: cellSize * 0.7);
          final tp = TextPainter(text: TextSpan(text: emoji, style: textStyle), textDirection: TextDirection.ltr);
          tp.layout();
          final dx = x + (cellSize - tp.width) / 2;
          final dy = y + (cellSize - tp.height) / 2;
          tp.paint(canvas, Offset(dx, dy));
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

  List<Color> _palette(ThemeData theme) => [
        Colors.cyanAccent,
        Colors.yellowAccent,
        Colors.purpleAccent,
        Colors.greenAccent,
        Colors.redAccent,
        Colors.blueAccent,
        Colors.orangeAccent,
        // Special block colors
        Colors.pink,           // PandaBrick
        Colors.grey,           // GhostBrick
        Colors.brown,          // CatBrick
        Colors.tealAccent,     // TornadoBrick
        Colors.deepOrangeAccent, // BombBrick
      ].map((c) => c.withAlpha(220)).toList();
}
