import 'package:flutter/material.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/widgets/home/audio_setting_row.dart';
import 'package:pandabricks/widgets/home/glass_morphism_container.dart';
import 'package:provider/provider.dart';

class AudioSettings extends StatelessWidget {
  const AudioSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        return GlassMorphismContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: AudioSettingRow(
                    title: l10n.music,
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
                    title: l10n.sfx,
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
