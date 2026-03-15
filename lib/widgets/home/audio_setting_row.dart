import 'package:flutter/material.dart';

class AudioSettingRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const AudioSettingRow({
    super.key,
    required this.title,
    required this.icon,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!initialValue),
      child: Row(
        children: [
          Icon(
            initialValue ? icon : Icons.volume_off_rounded,
            color: initialValue ? Colors.cyan : Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
          Switch(
            value: initialValue,
            onChanged: onChanged,
            activeThumbColor: Colors.cyan,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withAlpha(128),
          ),
        ],
      ),
    );
  }
}
