import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TopIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const TopIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  State<TopIconButton> createState() => _TopIconButtonState();
}

class _TopIconButtonState extends State<TopIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.elasticOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => _onHoverChanged(true),
        onExit: (_) => _onHoverChanged(false),
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.12 + (_glowAnimation.value * 0.08)),
                      Colors.white.withValues(alpha: 0.06 + (_glowAnimation.value * 0.04)),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15 + (_glowAnimation.value * 0.15)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _glowAnimation.value * 0.3),
                      blurRadius: 20,
                      spreadRadius: _glowAnimation.value * 2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: widget.onPressed,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        widget.icon,
                        color: AppColors.onSurface,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TopIconRow extends StatelessWidget {
  const TopIconRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        TopIconButton(
          icon: Icons.help_outline_rounded,
          tooltip: 'Help & Tutorial',
        ),
        SizedBox(width: 16),
        TopIconButton(
          icon: Icons.language_rounded,
          tooltip: 'Change Language',
        ),
        SizedBox(width: 16),
        TopIconButton(
          icon: Icons.settings_rounded,
          tooltip: 'Settings',
        ),
      ],
    );
  }
}
