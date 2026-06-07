import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class DialogButton extends StatelessWidget {
  const DialogButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: GlassMorphismCard(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 12 : 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? null : 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (compact) {
      return Expanded(child: button);
    }
    return SizedBox(width: double.infinity, child: button);
  }
}
