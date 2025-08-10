import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({
    required this.child,
    required this.onPressed,
    super.key,
  });

  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(51),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          splashColor: theme.colorScheme.primary.withAlpha(76),
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withAlpha(230),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
