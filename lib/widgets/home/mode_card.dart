import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class ModeCard extends StatelessWidget {
  const ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
    this.accentColor = Colors.cyan,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  void _handleTap() {
    unawaited(HapticFeedback.lightImpact());
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;

    return Semantics(
      button: true,
      label: '$title: $subtitle',
      child: GlassMorphismCard(
        child: Tooltip(
          message: subtitle,
          child: InkWell(
            onTap: _handleTap,
            splashColor: accentColor.withValues(alpha: 64 / 255.0),
            highlightColor: accentColor.withValues(alpha: 32 / 255.0),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: 220 / 255.0),
                          accentColor.withValues(alpha: 140 / 255.0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 90 / 255.0),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.grey[200],
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,

                            color: textColor.withValues(alpha: 200 / 255.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 220 / 255.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
