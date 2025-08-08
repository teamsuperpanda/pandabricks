import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:pandabricks/logic/bricks_logic.dart';
import 'package:pandabricks/logic/game_logic.dart';

class NextPiece extends StatelessWidget {
  final TetrisPiece nextPiece;

  const NextPiece({super.key, required this.nextPiece});

  @override
  Widget build(BuildContext context) {
    // Regular next piece display
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(60, 60),
          painter: NextPiecePainter(nextPiece),
        ),
      ),
    );
  }
}

class NextPiecePainter extends CustomPainter {
  final TetrisPiece nextPiece;

  NextPiecePainter(this.nextPiece);

  @override
  void paint(Canvas canvas, Size size) {
    double maxDimension = max(nextPiece.shape.length.toDouble(),
        nextPiece.shape[0].length.toDouble());
    double cellSize = size.width / (maxDimension + 1);

    double offsetX = (size.width - (nextPiece.shape[0].length * cellSize)) / 2;
    double offsetY = (size.height - (nextPiece.shape.length * cellSize)) / 2;

    for (int y = 0; y < nextPiece.shape.length; y++) {
      for (int x = 0; x < nextPiece.shape[y].length; x++) {
        if (nextPiece.shape[y][x] != 0) {
          Rect rect = Rect.fromLTWH(
            offsetX + (x * cellSize),
            offsetY + (y * cellSize),
            cellSize - 1,
            cellSize - 1,
          );
          RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

          // Add static glow effect for special bricks (no ticker required)
          if (BrickShapes.isSpecialBrick(nextPiece.colorIndex)) {
            List<Color> glowColors = BrickShapes.getGlowColors(nextPiece.colorIndex)
                .map((c) => c.withAlpha(160))
                .toList();
            for (final color in glowColors) {
              final glowPaint = Paint()
                ..color = color
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
              canvas.drawRRect(rRect, glowPaint);
            }
          }

          // Draw the base brick
          Paint paint = Paint()
            ..color = BrickShapes.colors[nextPiece.colorIndex]
            ..style = PaintingStyle.fill;
          canvas.drawRRect(rRect, paint);

          // Draw emoji if it's a special brick
          String? emoji = BrickShapes.getEmojiForBrick(nextPiece.shape[y][x]);
          if (emoji != null) {
            TextPainter textPainter = TextPainter(
              text: TextSpan(
                text: emoji,
                style: TextStyle(fontSize: cellSize * 0.8),
              ),
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            textPainter.paint(
              canvas,
              Offset(
                offsetX + (x * cellSize) + (cellSize - textPainter.width) / 2,
                offsetY + (y * cellSize) + (cellSize - textPainter.height) / 2,
              ),
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
