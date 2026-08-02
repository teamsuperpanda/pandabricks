import 'package:flutter/material.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class DialogButton extends StatelessWidget {
  const DialogButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
    this.shrinkWrap = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;
  final bool shrinkWrap;

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
            borderRadius: BorderRadius.circular(shrinkWrap ? 20 : 16),
            child: Padding(
              padding: shrinkWrap
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                  : EdgeInsets.symmetric(vertical: compact ? 12 : 14),
              child: Row(
                mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white),
                  SizedBox(width: shrinkWrap ? 6 : 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: shrinkWrap || compact ? null : 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (shrinkWrap) {
      return button;
    }
    if (compact) {
      return Expanded(child: button);
    }
    return SizedBox(width: double.infinity, child: button);
  }
}
