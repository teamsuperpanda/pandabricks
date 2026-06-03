import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class GameDialogWrapper extends StatelessWidget {
  const GameDialogWrapper({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.child,
    super.key,
  });

  final Widget icon;
  final String title;
  final String? subtitle;
  final Widget? child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassMorphismCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
              if (child != null) ...[
                const SizedBox(height: 20),
                child!,
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...actions,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
