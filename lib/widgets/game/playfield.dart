import 'package:flutter/material.dart';
import 'package:pandabricks/constants/tetris_shapes.dart';
import 'package:pandabricks/logic/game_logic.dart';

class Playfield extends StatefulWidget {
  final List<List<int>> playfield;
  final TetrisPiece? activePiece;
  final List<int> flashingRows;

  const Playfield({
    super.key,
    required this.playfield,
    this.activePiece,
    required this.flashingRows,
  });

  @override
  State<Playfield> createState() => _PlayfieldState();
}

class _PlayfieldState extends State<Playfield>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeInOut,
    ));

    _flashController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flashController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Playfield oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flashingRows.isNotEmpty) {
      _flashController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 0.5,
            child: Stack(
              children: [
                // Grid background
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount:
                      widget.playfield.length * widget.playfield[0].length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white10,
                          width: 0.5,
                        ),
                      ),
                    );
                  },
                ),
                // Pieces
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount:
                      widget.playfield.length * widget.playfield[0].length,
                  itemBuilder: (context, index) {
                    int x = index % widget.playfield[0].length;
                    int y = index ~/ widget.playfield[0].length;
                    Color cellColor = Colors.transparent;

                    if (widget.playfield[y][x] != 0) {
                      cellColor =
                          TetrisShapes.colors[widget.playfield[y][x] - 1];
                    }

                    // Add flash effect for clearing rows
                    if (widget.flashingRows.contains(y)) {
                      cellColor = Color.lerp(
                        cellColor,
                        Colors.white,
                        _flashAnimation.value,
                      )!;
                    }

                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: cellColor != Colors.transparent
                            ? [
                                BoxShadow(
                                  color: cellColor.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    );
                  },
                ),
                if (widget.activePiece != null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ActivePiecePainter(widget.activePiece!),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ActivePiecePainter extends CustomPainter {
  final TetrisPiece activePiece;

  ActivePiecePainter(this.activePiece);

  @override
  void paint(Canvas canvas, Size size) {
    double cellSize = size.width / 10;
    Paint paint = Paint()
      ..color = TetrisShapes.colors[activePiece.colorIndex].withOpacity(0.9);

    // Remove or comment out grid lines for a cleaner look
    /*
    Paint gridPaint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 1;

    for (int i = 0; i <= 10; i++) {
      canvas.drawLine(
          Offset(i * cellSize, 0), Offset(i * cellSize, size.height), gridPaint);
      canvas.drawLine(
          Offset(0, i * cellSize), Offset(size.width, i * cellSize), gridPaint);
    }
    */

    // Draw the active piece with rounded corners and shadows
    for (int y = 0; y < activePiece.shape.length; y++) {
      for (int x = 0; x < activePiece.shape[y].length; x++) {
        if (activePiece.shape[y][x] != 0) {
          double posX = (activePiece.x + x) * cellSize;
          double posY = (activePiece.y + y) * cellSize;
          Rect rect = Rect.fromLTWH(posX, posY, cellSize, cellSize);
          RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
          canvas.drawRRect(rRect, paint);

          // Optional: Remove shadows for consistent appearance
          // Uncomment below to keep shadows
          /*
          canvas.drawRRect(
            rRect.shift(Offset(2, 2)),
            Paint()
              ..color = Colors.black26
              ..style = PaintingStyle.fill,
          );
          */
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
