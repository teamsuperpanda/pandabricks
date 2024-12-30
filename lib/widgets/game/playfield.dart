import 'package:flutter/material.dart';
import 'package:pandabricks/logic/bricks_logic.dart';
import 'package:pandabricks/logic/game_logic.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math' show Random;
import 'dart:async' show Timer;

class Playfield extends StatefulWidget {
  final List<List<int>> playfield;
  final TetrisPiece? activePiece;
  final List<int> flashingRows;
  final VoidCallback? onAnimationComplete;
  final bool isSoundEffectsEnabled;
  final bool isFlashing;
  final VoidCallback? onTap;
  final VoidCallback? onSwipeDown;
  final VoidCallback? onSoftDropStart;
  final VoidCallback? onSoftDropEnd;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  const Playfield({
    super.key,
    required this.playfield,
    this.activePiece,
    required this.flashingRows,
    this.onAnimationComplete,
    required this.isSoundEffectsEnabled,
    this.isFlashing = false,
    this.onTap,
    this.onSwipeDown,
    this.onSoftDropStart,
    this.onSoftDropEnd,
    this.onSwipeLeft,
    this.onSwipeRight,
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
  Timer? _flashingTimer;

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

    _audioPlayer.setAsset('assets/audio/sfx/row_clear.mp3');
  }

  @override
  void dispose() {
    _flashController.dispose();
    _audioPlayer.dispose();
    _flashingTimer?.cancel();
    super.dispose();
  }

  double _getRandomPitch() {
    return 0.8 + (_random.nextDouble() * 0.4);
  }

  void _playSound() async {
    if (widget.flashingRows.isNotEmpty && widget.isSoundEffectsEnabled) {
      // Dispose old player
      await _audioPlayer.dispose();

      // Create new player
      final player = AudioPlayer();
      await player.setAsset('assets/audio/sfx/row_clear.mp3');

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

    // Start timer when flashing starts
    if (widget.isFlashing && !oldWidget.isFlashing) {
      _flashingTimer?.cancel();
      _flashingTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (mounted) setState(() {});
      });
    }

    // Stop timer when flashing ends
    if (!widget.isFlashing && oldWidget.isFlashing) {
      _flashingTimer?.cancel();
      _flashingTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          onLongPressStart: (_) => widget.onSoftDropStart?.call(),
          onLongPressEnd: (_) => widget.onSoftDropEnd?.call(),
          onHorizontalDragEnd: (details) {
            // Move one column based on swipe direction
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! > 0) {
                widget.onSwipeRight?.call();
              } else if (details.primaryVelocity! < 0) {
                widget.onSwipeLeft?.call();
              }
            }
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 1000) {
              widget.onSwipeDown?.call();
            }
          },
          child: Container(
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                            BrickShapes.colors[widget.playfield[y][x] - 1];
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
                        painter: ActivePiecePainter(
                          widget.activePiece!,
                          isFlashing: widget.isFlashing,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ActivePiecePainter extends CustomPainter {
  final TetrisPiece activePiece;
  final bool isFlashing;

  ActivePiecePainter(this.activePiece, {this.isFlashing = false});

  @override
  void paint(Canvas canvas, Size size) {
    double cellSize = size.width / 10;

    for (int y = 0; y < activePiece.shape.length; y++) {
      for (int x = 0; x < activePiece.shape[y].length; x++) {
        if (activePiece.shape[y][x] != 0) {
          double posX = (activePiece.x + x) * cellSize;
          double posY = (activePiece.y + y) * cellSize;

          if (activePiece.shape[y][x] == 8) {
            // For panda brick
            Rect rect = Rect.fromLTWH(posX, posY, cellSize, cellSize);
            RRect rRect =
                RRect.fromRectAndRadius(rect, const Radius.circular(4));

            if (isFlashing) {
              // Draw glow effects first (behind the brick)
              double glowIntensity =
                  (DateTime.now().millisecondsSinceEpoch % 750) / 750.0;
              double glowSize = 12.0 + (glowIntensity * 8.0);

              // Multiple outer glows with vibrant colors
              List<Color> glowColors = [
                Colors.pink.shade300.withAlpha(
                    (0.6 * glowIntensity * 255).round()), // Furthest back
                Colors.purple.shade300
                    .withAlpha((0.7 * glowIntensity * 255).round()), // Middle
                Colors.blue.shade400.withAlpha(
                    ((0.8 * (1.0 - glowIntensity)) * 255)
                        .round()), // Closest to brick
              ];

              // Draw glow layers from back to front
              for (int i = 0; i < glowColors.length; i++) {
                Paint glowPaint = Paint()
                  ..color = glowColors[i]
                  ..maskFilter = MaskFilter.blur(
                    BlurStyle.normal, // Changed from outer to normal
                    glowSize + (i * 4.0),
                  );
                canvas.drawRRect(rRect, glowPaint);
              }
            }

            // Draw solid white background on top of glow
            Paint bgPaint = Paint()
              ..color = Colors.white; // Removed transparency
            canvas.drawRRect(rRect, bgPaint);

            // Draw panda emoji on very top
            TextPainter textPainter = TextPainter(
              text: const TextSpan(
                text: '🐼',
                style: TextStyle(fontSize: 24),
              ),
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            textPainter.paint(
              canvas,
              Offset(
                posX + (cellSize - textPainter.width) / 2,
                posY + (cellSize - textPainter.height) / 2,
              ),
            );
          } else {
            // Normal brick
            Paint paint = Paint()
              ..color =
                  BrickShapes.colors[activePiece.colorIndex].withAlpha(230);
            Rect rect = Rect.fromLTWH(posX, posY, cellSize, cellSize);
            RRect rRect =
                RRect.fromRectAndRadius(rect, const Radius.circular(4));
            canvas.drawRRect(rRect, paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
