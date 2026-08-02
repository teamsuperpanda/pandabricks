import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandabricks/dialogs/game/game_dialog_wrapper.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/models/game_settings.dart';
import 'package:pandabricks/widgets/game/dialog_button.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return GameDialogWrapper(
      icon: const Icon(Icons.tune_rounded, size: 64, color: Colors.white),
      title: l10n.customGame,
      actions: [_buildActionButtons(l10n)],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeLimitSection(l10n),
          const SizedBox(height: 16),
          _buildDifficultySection(l10n),
          const SizedBox(height: 16),
          _buildBoardSizeSection(l10n),
          const SizedBox(height: 16),
          _buildSpecialFeaturesSection(l10n),
        ],
      ),
    );
  }

  Widget _buildTimeLimitSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.timeLimit),
        const SizedBox(height: 8),
        Row(
          children: [
            _timeChip(l10n.oneMin, const Duration(minutes: 1)),
            const SizedBox(width: 8),
            _timeChip(l10n.threeMin, const Duration(minutes: 3)),
            const SizedBox(width: 8),
            _timeChip(l10n.fiveMin, const Duration(minutes: 5)),
            const SizedBox(width: 8),
            _timeChip(l10n.tenMin, const Duration(minutes: 10)),
            const SizedBox(width: 8),
            _timeChip(l10n.unlimited, null),
          ],
        ),
      ],
    );
  }

  Widget _timeChip(String label, Duration? duration) {
    return _optionChip(
      label,
      config.timeLimit == duration,
      Colors.cyan,
      () => setState(() => config = config.copyWith(timeLimit: duration)),
      labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
    );
  }

  Widget _buildDifficultySection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.startingLevel),
        const SizedBox(height: 8),
        Row(
          children: [
            _optionChip(
              '1',
              config.startingLevel == 1,
              Colors.purple,
              () => setState(() => config = config.copyWith(startingLevel: 1)),
            ),
            const SizedBox(width: 8),
            _optionChip(
              '5',
              config.startingLevel == 5,
              Colors.purple,
              () => setState(() => config = config.copyWith(startingLevel: 5)),
            ),
            const SizedBox(width: 8),
            _optionChip(
              '10',
              config.startingLevel == 10,
              Colors.purple,
              () => setState(
                () => config = config.copyWith(startingLevel: 10),
              ),
            ),
            const SizedBox(width: 8),
            _optionChip(
              '15',
              config.startingLevel == 15,
              Colors.purple,
              () => setState(
                () => config = config.copyWith(startingLevel: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionTitle(l10n.speedMultiplier, small: true),
        const SizedBox(height: 8),
        _buildSlider(
          color: Colors.cyan,
          value: config.speedMultiplier,
          min: 0.5,
          max: 2,
          divisions: 6,
          onChanged: (value) => setState(
            () => config = config.copyWith(speedMultiplier: value),
          ),
        ),
      ],
    );
  }

  Widget _buildBoardSizeSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.boardWidth),
        const SizedBox(height: 8),
        Row(
          children: [8, 10, 12, 15, 20]
              .map(
                (w) => _optionChip(
                  '$w',
                  config.boardWidth == w,
                  Colors.cyan,
                  () => setState(() => config = config.copyWith(boardWidth: w)),
                  outerPadding: const EdgeInsetsDirectional.only(end: 8),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        _sectionTitle(l10n.boardHeight),
        const SizedBox(height: 8),
        Row(
          children: [10, 15, 20, 30, 40]
              .map(
                (h) => _optionChip(
                  '$h',
                  config.boardHeight == h,
                  Colors.purple,
                  () => setState(
                    () => config = config.copyWith(boardHeight: h),
                  ),
                  outerPadding: const EdgeInsetsDirectional.only(end: 8),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSpecialFeaturesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.specialFeatures),
        const SizedBox(height: 12),
        _featureToggle(l10n.specialBricksToggle, config.enableSpecialBricks, (
          value,
        ) {
          setState(() => config = config.copyWith(enableSpecialBricks: value));
        }),
        const SizedBox(height: 8),
        _sectionTitle(l10n.scoreMultiplier, small: true),
        const SizedBox(height: 8),
        _buildSlider(
          color: Colors.orange,
          value: config.scoreMultiplier,
          min: 0.5,
          max: 3,
          divisions: 10,
          onChanged: (value) => setState(
            () => config = config.copyWith(scoreMultiplier: value),
          ),
        ),
      ],
    );
  }

  Widget _optionChip(
    String label,
    bool selected,
    Color selectedColor,
    VoidCallback onTap, {
    TextStyle? labelStyle,
    EdgeInsetsGeometry? outerPadding,
  }) {
    final style =
        (labelStyle ?? const TextStyle(fontSize: 14, color: Colors.white))
            .copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500);
    return Expanded(
      child: Padding(
        padding: outerPadding ?? EdgeInsets.zero,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? selectedColor.withValues(alpha: 100 / 255.0)
                  : Colors.white.withValues(alpha: 20 / 255.0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? selectedColor
                    : Colors.white.withValues(alpha: 50 / 255.0),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required Color color,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required void Function(double) onChanged,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: color,
        thumbColor: color,
        inactiveTrackColor: Colors.white.withValues(alpha: 50 / 255.0),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: '${value.toStringAsFixed(1)}x',
        onChanged: onChanged,
      ),
    );
  }

  Widget _sectionTitle(String text, {bool small = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: small ? 16 : 18,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _featureToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
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
            return Colors.white.withValues(alpha: 150 / 255.0);
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.cyan.withValues(alpha: 100 / 255.0);
            }
            return Colors.white.withValues(alpha: 50 / 255.0);
          }),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        DialogButton(
          icon: Icons.close_rounded,
          label: l10n.cancel,
          onTap: () => Navigator.of(context).pop(),
          compact: true,
        ),
        const SizedBox(width: 12),
        DialogButton(
          icon: Icons.play_arrow_rounded,
          label: l10n.startGame,
          onTap: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            unawaited(router.push('/game', extra: GameSettings.custom(config)));
          },
          compact: true,
        ),
      ],
    );
  }
}
