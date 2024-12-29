import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Controls extends StatelessWidget {
  final VoidCallback onLeft;
  final VoidCallback onDown;
  final VoidCallback onRight;
  final VoidCallback onRotate;

  const Controls({
    super.key,
    required this.onLeft,
    required this.onDown,
    required this.onRight,
    required this.onRotate,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowLeft:
              onLeft();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowRight:
              onRight();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowDown:
              onDown();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowUp:
              onRotate();
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ControlButton(icon: Icons.arrow_left, onTap: onLeft),
            ControlButton(icon: Icons.arrow_drop_down, onTap: onDown),
            ControlButton(icon: Icons.arrow_right, onTap: onRight),
            ControlButton(icon: Icons.rotate_right, onTap: onRotate),
          ],
        ),
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ControlButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[800]!,
            width: 2,
          ),
          gradient: RadialGradient(
            colors: [
              Colors.grey[800]!,
              Colors.grey[900]!,
            ],
            center: Alignment.topLeft,
            radius: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 24,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
