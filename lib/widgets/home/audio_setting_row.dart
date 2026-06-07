import 'package:flutter/material.dart';

class AudioSettingRow extends StatelessWidget {
  const AudioSettingRow({
    required this.title,
    required this.icon,
    required this.initialValue,
    required this.onChanged,
    super.key,
  });
  final String title;
  final IconData icon;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title ${initialValue ? 'enabled' : 'disabled'}',
      child: GestureDetector(
        onTap: () => onChanged(!initialValue),
        child: Row(
          children: [
            Semantics(
              label: initialValue ? 'Sound on' : 'Sound off',
              child: Icon(
                initialValue ? icon : Icons.volume_off_rounded,
                color: initialValue ? Colors.cyan : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Semantics(
              label: '$title toggle',
              child: Switch(
                value: initialValue,
                onChanged: onChanged,
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return Colors.cyan;
                  return Colors.grey;
                }),
                inactiveTrackColor: Colors.grey.withValues(alpha: 128 / 255.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
