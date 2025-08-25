import 'package:flutter/material.dart';

class GlowingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final String text;

  const GlowingButton({
    super.key,
    required this.onPressed,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((0.4 * 255).round()),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
