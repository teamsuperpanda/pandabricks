import 'package:flutter/material.dart';
import 'dart:ui';
import '../../theme/app_colors.dart';

class AppBackground extends StatefulWidget {
  final Widget child;
  
  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _parallaxAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _parallaxAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Animated subtle parallax overlay
            AnimatedBuilder(
              animation: _parallaxAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [
                        0.0 + (_parallaxAnimation.value * 0.1),
                        0.3 + (_parallaxAnimation.value * 0.1),
                        0.7 + (_parallaxAnimation.value * 0.1),
                        1.0,
                      ],
                      colors: [
                        AppColors.primary.withValues(alpha: 0.08),
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.surface.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Global blur and tint
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.25),
                    ],
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}
