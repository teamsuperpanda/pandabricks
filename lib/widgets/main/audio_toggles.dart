import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GestureDetector(
                  onTap: () {
                    onBackgroundMusicChanged(!isBackgroundMusicEnabled);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Background Music',
                        style: TextStyle(
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GestureDetector(
                  onTap: () {
                    onSoundEffectsChanged(!isSoundEffectsEnabled);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sound Effects',
                        style: TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }
}
