
import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {

  const AnimatedBackground({required this.gradientAnimation, super.key});
  final Animation<double> gradientAnimation;

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
                Color.lerp(
                  const Color(0xFF1a1a2e),
                  const Color(0xFF16213e),
                  gradientAnimation.value,
                )!,
                Color.lerp(
                  const Color(0xFF0f3460),
                  const Color(0xFF533483),
                  gradientAnimation.value,
                )!,
              ],
            ),
          ),
        );
      },
    );
  }
}
