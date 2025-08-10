import 'package:flutter/material.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/widgets/home/audio_setting_row.dart';
import 'package:pandabricks/widgets/home/glass_morphism_container.dart';
import 'package:provider/provider.dart';

class AudioSettings extends StatelessWidget {
  const AudioSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        return GlassMorphismContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                const Text(
                  'Audio Settings',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: AudioSettingRow(
                    title: 'Music',
                    icon: Icons.music_note,
                    initialValue: audioProvider.musicEnabled.value,
                    onChanged: (value) {
                      audioProvider.toggleMusic();
                    },
                  ),
                ),
                const Divider(height: 8, color: Colors.white24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: AudioSettingRow(
                    title: 'Sound Effects',
                    icon: Icons.volume_up,
                    initialValue: audioProvider.sfxEnabled.value,
                    onChanged: (value) {
                      audioProvider.toggleSfx();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}