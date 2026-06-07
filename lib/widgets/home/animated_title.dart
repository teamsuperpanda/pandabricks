import 'package:flutter/material.dart';
import 'package:pandabricks/l10n/app_localizations.dart';

class AnimatedTitle extends StatelessWidget {
  const AnimatedTitle({required this.floatingAnimation, super.key});
  final Animation<double> floatingAnimation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, floatingAnimation.value),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.white,
                Colors.cyan.withValues(alpha: 0.7),
                Colors.white,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              l10n.appTitle.toUpperCase(),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Color.fromRGBO(0, 255, 255, 0.5),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
