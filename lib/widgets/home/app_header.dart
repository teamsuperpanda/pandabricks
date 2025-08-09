import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo + Title with subtle shimmer effect
        AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [
                    (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                    (_shimmerAnimation.value).clamp(0.0, 1.0),
                    (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                  ],
                  colors: [
                    AppColors.onSurface,
                    Colors.white,
                    AppColors.onSurface,
                  ],
                ).createShader(bounds);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Pandabricks',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.w700,
                      fontSize: 48,
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.black54,
                          offset: Offset(0, 4),
                        ),
                        Shadow(
                          blurRadius: 40,
                          color: AppColors.primary,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

      ],
    );
  }
}
