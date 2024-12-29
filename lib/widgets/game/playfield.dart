import 'package:flutter/material.dart';
import 'package:pandabricks/constants/tetris_shapes.dart';
import 'package:pandabricks/logic/game_logic.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math' show Random;

class Playfield extends StatefulWidget {
  final List<List<int>> playfield;
  final TetrisPiece? activePiece;
  final List<int> flashingRows;
  final VoidCallback? onAnimationComplete;

  const Playfield({
    super.key,
    required this.playfield,
    this.activePiece,
    required this.flashingRows,
    this.onAnimationComplete,
  });

  @override
  State<Playfield> createState() => _PlayfieldState();
}

class _PlayfieldState extends State<Playfield>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
      } else if (status == AnimationStatus.dismissed) {
        if (widget.flashingRows.isNotEmpty) {
          widget.onAnimationComplete?.call();
        }
      }
    });

    _audioPlayer.setAsset('audio/sfx/laser-zap.mp3');
  }

  @override
  void dispose() {
    _flashController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  double _getRandomPitch() {
    return 0.8 + (_random.nextDouble() * 0.4);
  }

  void _playSound() async {
    if (widget.flashingRows.isNotEmpty) {
      // Dispose old player
      await _audioPlayer.dispose();

      // Create new player
      final player = AudioPlayer();
      await player.setAsset('audio/sfx/laser-zap.mp3');

      // Get and set random pitch
      double pitch = _getRandomPitch();
      player.setSpeed(pitch);

      await player.play();

      // Clean up after playing
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          player.dispose();
        }
      });
    }
  }

  @override
  void didUpdateWidget(Playfield oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flashingRows.isNotEmpty &&
        oldWidget.flashingRows != widget.flashingRows) {
      _flashController.forward(from: 0.0);
      _playSound();
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
                color: Colors.black.withAlpha(128),
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
                                  color: cellColor.withAlpha(128),
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
      ..color = TetrisShapes.colors[activePiece.colorIndex].withAlpha(230);

    for (int y = 0; y < activePiece.shape.length; y++) {
      for (int x = 0; x < activePiece.shape[y].length; x++) {
        if (activePiece.shape[y][x] != 0) {
          double posX = (activePiece.x + x) * cellSize;
          double posY = (activePiece.y + y) * cellSize;
          Rect rect = Rect.fromLTWH(posX, posY, cellSize, cellSize);
          RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
          canvas.drawRRect(rRect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
