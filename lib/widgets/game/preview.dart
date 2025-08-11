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
    
    // Use a larger cell size for better visibility
    const double cellSize = 28.0;
    
    // Calculate bounds of the piece
    double minX = cells.isEmpty ? 0 : cells.map((c) => c.dx).reduce((a, b) => a < b ? a : b);
    double maxX = cells.isEmpty ? 0 : cells.map((c) => c.dx).reduce((a, b) => a > b ? a : b);
    double minY = cells.isEmpty ? 0 : cells.map((c) => c.dy).reduce((a, b) => a < b ? a : b);
    double maxY = cells.isEmpty ? 0 : cells.map((c) => c.dy).reduce((a, b) => a > b ? a : b);
    
    double pieceWidth = (maxX - minX + 1) * cellSize;
    double pieceHeight = (maxY - minY + 1) * cellSize;
    
    // Center the piece
    double offsetX = (size.width - pieceWidth) / 2;
    double offsetY = (size.height - pieceHeight) / 2;

    for (final c in cells) {
      final x = (c.dx - minX) * cellSize + offsetX;
      final y = (c.dy - minY) * cellSize + offsetY;
      final rect = Rect.fromLTWH(x, y, cellSize, cellSize).deflate(0.5);
      final color = palette[game.Game.colorFor[next!]! % palette.length];
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
      ].map((c) => c.withAlpha(220)).toList();
}
