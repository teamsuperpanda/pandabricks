import 'package:flutter/material.dart';
import 'package:pandabricks/constants/tetris_shapes.dart';
import 'package:pandabricks/logic/game_logic.dart';

class Playfield extends StatelessWidget {
  final List<List<int>> playfield;
  final TetrisPiece? activePiece;

  const Playfield({super.key, required this.playfield, this.activePiece});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10, // Number of columns
              childAspectRatio: 1, // Square cells
            ),
            itemCount: playfield.length * playfield[0].length,
            itemBuilder: (context, index) {
              int x = index % playfield[0].length; // Column index
              int y = index ~/ playfield[0].length; // Row index
              Color cellColor;

              if (playfield[y][x] == 0) {
                cellColor = Colors.black; // Empty cell
              } else {
                cellColor = TetrisShapes
                    .colors[playfield[y][x] - 1]; // Use color from TetrisShapes
              }

              return Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  border: Border.all(
                      color: Colors
                          .grey), // Optional: Add borders for better visibility
                ),
              );
            },
          ),
          if (activePiece != null)
            Positioned.fill(
              child: CustomPaint(
                painter: ActivePiecePainter(activePiece!),
              ),
            ),
        ],
      ),
    );
  }
}

class ActivePiecePainter extends CustomPainter {
  final TetrisPiece activePiece;

  ActivePiecePainter(this.activePiece);

  @override
  void paint(Canvas canvas, Size size) {
    double cellSize = size.width / 10; // Assuming 10 columns
    Paint paint = Paint()..color = TetrisShapes.colors[activePiece.colorIndex];

    for (var block in activePiece.shape) {
      // Iterate through the shape's matrix to find filled cells
      for (int y = 0; y < activePiece.shape.length; y++) {
        for (int x = 0; x < activePiece.shape[y].length; x++) {
          if (activePiece.shape[y][x] != 0) {
            double posX = (activePiece.x + x) * cellSize;
            double posY = (activePiece.y + y) * cellSize;
            Rect rect = Rect.fromLTWH(posX, posY, cellSize, cellSize);
            canvas.drawRect(rect, paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
