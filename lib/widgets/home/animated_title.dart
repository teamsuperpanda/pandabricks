
import 'package:flutter/material.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

class AnimatedTitle extends StatelessWidget {
  final Animation<double> floatingAnimation;

  const AnimatedTitle({super.key, required this.floatingAnimation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, floatingAnimation.value),
          child: Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.cyan.withAlpha((255 * 0.7).toInt()),
            period: const Duration(seconds: 5),
            child: Text(
              l10n.appTitle.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Fredoka',
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
