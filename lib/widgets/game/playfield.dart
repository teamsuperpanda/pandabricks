import 'package:flutter/material.dart';
import 'package:pandabricks/logic/bricks_logic.dart';
import 'package:pandabricks/logic/game_logic.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math' show Random, pi;
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
  final bool isFlipping;
  final double flipProgress;
  final Function(Playfield)? ref;

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
    this.isFlipping = false,
    this.flipProgress = 0.0,
    this.ref,
  });

  @override
  State<Playfield> createState() => PlayfieldState();
}

class PlayfieldState extends State<Playfield> with TickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();
  Timer? _flashingTimer;
  List<ExplosionParticle> _particles = [];
  Timer? _explosionTimer;

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

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    );

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flipController.reset();
      }
    });

    // Register the bomb explode callback
    // Assuming you have access to GameLogic instance
    // Replace `gameLogicInstance` with your actual instance
    // gameLogicInstance.onBombExplode = startExplosion;

    widget.ref?.call(widget);
  }

  @override
  void dispose() {
    _flashController.dispose();
    _flipController.dispose();
    _audioPlayer.dispose();
    _flashingTimer?.cancel();
    _explosionTimer?.cancel();
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

  void startExplosion(double startX, double startY) {
    // Create more particles for a bigger explosion
    _particles = List.generate(
      50, // Increased from 30 to 50 particles
      (_) => ExplosionParticle(startX, startY),
    );

    // Start animation timer
    _explosionTimer?.cancel();
    _explosionTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) {
        setState(() {
          _particles.removeWhere((particle) => !particle.update());
          if (_particles.isEmpty) {
            timer.cancel();
          }
        });
      },
    );
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

    // Start flip animation when isFlipping changes
    if (widget.isFlipping && !oldWidget.isFlipping) {
      _flipController.forward();
    } else if (!widget.isFlipping && oldWidget.isFlipping) {
      _flipController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flashAnimation, _flipAnimation]),
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_flipAnimation.value * pi),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: widget.onTap,
            onLongPressStart: (_) => widget.onSoftDropStart?.call(),
            onLongPressEnd: (_) => widget.onSoftDropEnd?.call(),
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! > 0) {
                  widget.onSwipeRight?.call();
                } else if (details.primaryVelocity! < 0) {
                  widget.onSwipeLeft?.call();
                }
              }
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! > 1000) {
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
                child: CustomPaint(
                  painter: PlayfieldPainter(
                    playfield: widget.playfield,
                    activePiece: widget.activePiece,
                    flashingRows: widget.flashingRows,
                    flashValue: _flashAnimation.value,
                    particles: _particles,
                  ),
                ),
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

          Rect rect = Rect.fromLTWH(posX, posY, cellSize, cellSize);
          RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

          // Add glow effect for special bricks
          if (BrickShapes.isSpecialBrick(activePiece.colorIndex)) {
            List<Color> glowColors =
                BrickShapes.getGlowColors(activePiece.colorIndex);

            // Draw single glow layer
            Paint glowPaint = Paint()
              ..color = glowColors[0]
              ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3.0);
            canvas.drawRRect(rRect, glowPaint);
          }

          // Draw the base brick
          Paint paint = Paint()
            ..color = BrickShapes.colors[activePiece.colorIndex]
            ..style = PaintingStyle.fill;
          canvas.drawRRect(rRect, paint);

          // Draw emoji if it's a special brick
          if (BrickShapes.isSpecialBrick(activePiece.colorIndex)) {
            String? emoji =
                BrickShapes.specialBrickEmojis[activePiece.colorIndex];
            if (emoji != null) {
              TextPainter textPainter = TextPainter(
                text: TextSpan(
                  text: emoji,
                  style: const TextStyle(fontSize: 24),
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
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PlayfieldExplosionPainter extends CustomPainter {
  final List<ExplosionParticle> particles;

  PlayfieldExplosionPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withAlpha((particle.opacity * 255).round())
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PlayfieldPainter extends CustomPainter {
  final List<List<int>> playfield;
  final TetrisPiece? activePiece;
  final List<int> flashingRows;
  final double flashValue;
  final List<ExplosionParticle> particles;

  PlayfieldPainter({
    required this.playfield,
    required this.activePiece,
    required this.flashingRows,
    required this.flashValue,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cols = playfield[0].length;
    final rows = playfield.length;
    final cellSize = size.width / cols;

    // Draw grid background
    final gridPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final rect = Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize);
        canvas.drawRect(rect, gridPaint);
      }
    }

    // Draw placed bricks
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final v = playfield[y][x];
        if (v == 0) continue;
        Color cellColor = BrickShapes.colors[v - 1];
        if (flashingRows.contains(y)) {
          cellColor = Color.lerp(cellColor, Colors.white, flashValue)!;
        }
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(x * cellSize + 1, y * cellSize + 1, cellSize - 2, cellSize - 2),
          const Radius.circular(2),
        );
        final paint = Paint()..color = cellColor;
        canvas.drawRRect(r, paint);
        // Simple glow
        final glow = Paint()
          ..color = cellColor.withAlpha(128)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);
        canvas.drawRRect(r, glow);
      }
    }

    // Draw active piece
    if (activePiece != null) {
      final ap = activePiece!;
      for (int y = 0; y < ap.shape.length; y++) {
        for (int x = 0; x < ap.shape[y].length; x++) {
          if (ap.shape[y][x] == 0) continue;
          final posX = (ap.x + x) * cellSize;
          final posY = (ap.y + y) * cellSize;
          final r = RRect.fromRectAndRadius(
            Rect.fromLTWH(posX, posY, cellSize, cellSize),
            const Radius.circular(4),
          );
          final c = BrickShapes.colors[ap.colorIndex];
          final base = Paint()..color = c;
          canvas.drawRRect(r, base);
          // Emoji for special bricks
          if (BrickShapes.isSpecialBrick(ap.colorIndex)) {
            final emoji = BrickShapes.specialBrickEmojis[ap.colorIndex];
            if (emoji != null) {
              final tp = TextPainter(
                text: TextSpan(text: emoji, style: const TextStyle(fontSize: 24)),
                textDirection: TextDirection.ltr,
              )..layout();
              tp.paint(
                canvas,
                Offset(posX + (cellSize - tp.width) / 2, posY + (cellSize - tp.height) / 2),
              );
            }
          }
        }
      }
    }

    // Draw particles on top
    for (var p in particles) {
      final paint = Paint()
        ..color = p.color.withAlpha((p.opacity * 255).round())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PlayfieldPainter oldDelegate) {
    return oldDelegate.playfield != playfield ||
        oldDelegate.activePiece != activePiece ||
        oldDelegate.flashValue != flashValue ||
        oldDelegate.flashingRows != flashingRows ||
        oldDelegate.particles != particles;
  }
}
