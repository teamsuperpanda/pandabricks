import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:pandabricks/constants/tetris_shapes.dart';
import 'package:pandabricks/logic/game_logic.dart';

class NextPiece extends StatelessWidget {
  final TetrisPiece nextPiece;

  const NextPiece({super.key, required this.nextPiece});

  @override
  Widget build(BuildContext context) {
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

    Paint paint = Paint()
      ..color = TetrisShapes.colors[nextPiece.colorIndex]
      ..style = PaintingStyle.fill;

    for (int y = 0; y < nextPiece.shape.length; y++) {
      for (int x = 0; x < nextPiece.shape[y].length; x++) {
        if (nextPiece.shape[y][x] != 0) {
          Rect rect = Rect.fromLTWH(
            offsetX + (x * cellSize),
            offsetY + (y * cellSize),
            cellSize - 1,
            cellSize - 1,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
