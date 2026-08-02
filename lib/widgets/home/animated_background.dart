import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({required this.gradientAnimation, super.key});
  final Animation<double> gradientAnimation;

  static const Color _start1 = Color(0xFF1a1a2e);
  static const Color _end1 = Color(0xFF16213e);
  static const Color _start2 = Color(0xFF0f3460);
  static const Color _end2 = Color(0xFF533483);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gradientAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(_start1, _end1, gradientAnimation.value)!,
                Color.lerp(_start2, _end2, gradientAnimation.value)!,
              ],
            ),
          ),
        );
      },
    );
  }
}
