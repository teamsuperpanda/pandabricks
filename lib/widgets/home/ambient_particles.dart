import 'dart:math';
import 'package:flutter/material.dart';

class AmbientParticles extends StatefulWidget {
  const AmbientParticles({super.key});

  @override
  State<AmbientParticles> createState() => _AmbientParticlesState();
}

class _AmbientParticlesState extends State<AmbientParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final int _count = 24;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _particles = List.generate(_count, (i) => _Particle.random());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticlePainter(
              _particles,
              _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  late double x, y, r, speed, phase, opacity;
  late Color color;

  _Particle.random() {
    final rand = Random();
    x = rand.nextDouble();
    y = rand.nextDouble();
    r = rand.nextDouble() * 2.5 + 1.5;
    speed = rand.nextDouble() * 0.2 + 0.05;
    phase = rand.nextDouble() * 2 * pi;
    opacity = rand.nextDouble() * 0.3 + 0.2;
    final baseColor = [Colors.cyanAccent, Colors.white, Colors.purpleAccent, Colors.tealAccent][rand.nextInt(4)];
    color = baseColor.withAlpha((opacity * 255).toInt());
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;

  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dx = p.x * size.width + sin(t * 2 * pi * p.speed + p.phase) * 16;
      final dy = p.y * size.height + cos(t * 2 * pi * p.speed + p.phase) * 16;
      final paint = Paint()
        ..color = p.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(dx, dy), p.r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}