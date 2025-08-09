import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AudioToggle extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AudioToggle({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<AudioToggle> createState() => _AudioToggleState();
}

class _AudioToggleState extends State<AudioToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: widget.value 
                    ? [
                        AppColors.primary.withValues(alpha: 0.9),
                        AppColors.primary.withValues(alpha: 0.7),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                ),
                border: Border.all(
                  color: widget.value 
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: widget.value 
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4 + (_glowAnimation.value * 0.2)),
                        blurRadius: 12 + (_glowAnimation.value * 8),
                        spreadRadius: 1 + (_glowAnimation.value * 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedRotation(
                    turns: widget.value ? 0.0 : 0.25,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AudioTogglesPanel extends StatelessWidget {
  final bool musicEnabled;
  final bool sfxEnabled;
  final ValueChanged<bool> onMusicChanged;
  final ValueChanged<bool> onSfxChanged;

  const AudioTogglesPanel({
    super.key,
    required this.musicEnabled,
    required this.sfxEnabled,
    required this.onMusicChanged,
    required this.onSfxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AudioToggle(
          icon: Icons.music_note_rounded,
          label: 'Music',
          value: musicEnabled,
          onChanged: onMusicChanged,
        ),
        const SizedBox(width: 16),
        AudioToggle(
          icon: Icons.graphic_eq_rounded,
          label: 'SFX',
          value: sfxEnabled,
          onChanged: onSfxChanged,
        ),
      ],
    );
  }
}
