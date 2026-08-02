import 'dart:ui';

import 'package:flutter/material.dart';

class GlassMorphismCard extends StatelessWidget {
  const GlassMorphismCard({
    required this.child,
    this.showShadow = true,
    this.blur = false,
    super.key,
  });

  final Widget child;
  final bool showShadow;

  /// Whether to apply a real `BackdropFilter` blur behind the card.
  ///
  /// Defaults to `false`, which paints a faux-glass look (translucent fill,
  /// gradient and border) without the per-frame offscreen render pass a blur
  /// costs. Enable only where a genuine frosted backdrop matters, such as
  /// modal dialogs over the game board.
  final bool blur;

  static final Map<(Color, bool), BoxDecoration> _decorationCache = {};

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final card = Container(
      decoration: _decorationCache.putIfAbsent(
        (primary, showShadow),
        () => BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary.withValues(alpha: 76 / 255.0),
              primary.withValues(alpha: 38 / 255.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primary.withValues(alpha: 51 / 255.0),
            width: 1.5,
          ),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: primary.withValues(
                      alpha: 25 / 255.0,
                    ),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ]
              : null,
        ),
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: blur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: card,
            )
          : card,
    );
  }
}
