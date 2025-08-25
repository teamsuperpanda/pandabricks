import 'package:flutter/material.dart';
import 'package:pandabricks/l10n/app_localizations.dart';

class AudioToggles extends StatelessWidget {
  final bool isBackgroundMusicEnabled;
  final bool isSoundEffectsEnabled;
  final ValueChanged<bool> onBackgroundMusicChanged;
  final ValueChanged<bool> onSoundEffectsChanged;

  const AudioToggles({
    super.key,
    required this.isBackgroundMusicEnabled,
    required this.isSoundEffectsEnabled,
    required this.onBackgroundMusicChanged,
    required this.onSoundEffectsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Card(
            color: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.backgroundMusic,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Fredoka',
                      color: Colors.white,
                    ),
                  ),
                  Switch(
                    value: isBackgroundMusicEnabled,
                    onChanged: onBackgroundMusicChanged,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.soundEffects,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Fredoka',
                      color: Colors.white,
                    ),
                  ),
                  Switch(
                    value: isSoundEffectsEnabled,
                    onChanged: onSoundEffectsChanged,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
