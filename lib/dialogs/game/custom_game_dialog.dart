import 'package:flutter/material.dart';
import 'package:pandabricks/screens/game/game.dart';
import 'package:pandabricks/models/game_settings.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

class CustomGameDialog extends StatefulWidget {
  const CustomGameDialog({super.key});

  @override
  State<CustomGameDialog> createState() => _CustomGameDialogState();
}

class _CustomGameDialogState extends State<CustomGameDialog> {
  late CustomGameConfig config;

  @override
  void initState() {
    super.initState();
    config = const CustomGameConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassMorphismCard(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Custom Game',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildTimeLimitSection(),
              const SizedBox(height: 16),
              _buildDifficultySection(),
              const SizedBox(height: 16),
              _buildSpecialFeaturesSection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeLimitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Limit',
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _timeButton('1 min', const Duration(minutes: 1)),
            const SizedBox(width: 8),
            _timeButton('3 min', const Duration(minutes: 3)),
            const SizedBox(width: 8),
            _timeButton('5 min', const Duration(minutes: 5)),
            const SizedBox(width: 8),
            _timeButton('10 min', const Duration(minutes: 10)),
            const SizedBox(width: 8),
            _timeButton('Unlimited', null),
          ],
        ),
      ],
    );
  }

  Widget _timeButton(String label, Duration? duration) {
    final isSelected = config.timeLimit == duration;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            config = config.copyWith(timeLimit: duration);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.cyan.withAlpha(100) : Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.cyan : Colors.white.withAlpha(50),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 12,
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Starting Level',
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _levelButton('1', 1),
            const SizedBox(width: 8),
            _levelButton('5', 5),
            const SizedBox(width: 8),
            _levelButton('10', 10),
            const SizedBox(width: 8),
            _levelButton('15', 15),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Speed Multiplier',
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.cyan,
            thumbColor: Colors.cyan,
            inactiveTrackColor: Colors.white.withAlpha(50),
          ),
          child: Slider(
            value: config.speedMultiplier,
            min: 0.5,
            max: 2.0,
            divisions: 6,
            label: '${config.speedMultiplier.toStringAsFixed(1)}x',
            onChanged: (value) => setState(() => config = config.copyWith(speedMultiplier: value)),
          ),
        ),
      ],
    );
  }

  Widget _levelButton(String label, int level) {
    final isSelected = config.startingLevel == level;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => config = config.copyWith(startingLevel: level)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple.withAlpha(100) : Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.white.withAlpha(50),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 14,
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Features',
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _featureToggle('Special Bricks', config.enableSpecialBricks, (value) {
          setState(() => config = config.copyWith(enableSpecialBricks: value));
        }),
        const SizedBox(height: 8),
        Text(
          'Score Multiplier',
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.orange,
            thumbColor: Colors.orange,
            inactiveTrackColor: Colors.white.withAlpha(50),
          ),
          child: Slider(
            value: config.scoreMultiplier,
            min: 0.5,
            max: 3.0,
            divisions: 10,
            label: '${config.scoreMultiplier.toStringAsFixed(1)}x',
            onChanged: (value) => setState(() => config = config.copyWith(scoreMultiplier: value)),
          ),
        ),
      ],
    );
  }

  Widget _featureToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.cyan;
            }
            return Colors.white.withAlpha(150);
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.cyan.withAlpha(100);
            }
            return Colors.white.withAlpha(50);
          }),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GlassMorphismCard(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.cyan, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    '/game', 
                    arguments: GameSettings.custom(config),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text(
                    'Start Game',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}