import 'dart:ui';

import 'package:flutter/material.dart';

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: theme.colorScheme.primary.withAlpha(36),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            splashColor: theme.colorScheme.primary.withAlpha(76),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(76),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(36),
                    blurRadius: 10,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
