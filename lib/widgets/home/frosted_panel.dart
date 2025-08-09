import 'package:flutter/material.dart';
import 'dart:ui';

class FrostedPanel extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const FrostedPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
  });

  @override
  State<FrostedPanel> createState() => _FrostedPanelState();
}

class _FrostedPanelState extends State<FrostedPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _borderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              padding: widget.padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.04),
                  ],
                ),
                border: Border.all(
                  width: 1.5,
                  color: Colors.white.withValues(
                    alpha: 0.15 + (_borderAnimation.value * 0.1),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 64,
                    offset: const Offset(0, 32),
                  ),
                ],
              ),
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}
