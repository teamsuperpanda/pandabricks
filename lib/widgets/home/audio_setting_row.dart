
import 'package:flutter/material.dart';

class AudioSettingRow extends StatefulWidget {
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
  State<AudioSettingRow> createState() => _AudioSettingRowState();
}

class _AudioSettingRowState extends State<AudioSettingRow> {
  late bool _isToggled;

  @override
  void initState() {
    super.initState();
    _isToggled = widget.initialValue;
  }

  void _toggle() {
    setState(() {
      _isToggled = !_isToggled;
      widget.onChanged(_isToggled);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Row(
        children: [
          Icon(
            _isToggled ? widget.icon : Icons.volume_off_rounded,
            color: _isToggled ? Colors.cyan : Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Switch(
            value: _isToggled,
            onChanged: (value) => _toggle(),
            activeThumbColor: Colors.cyan,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withAlpha((255 * 0.5).toInt()),
          ),
        ],
      ),
    );
  }
}
