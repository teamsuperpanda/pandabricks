import 'package:flutter/material.dart';
import 'widgets/home/app_background.dart';
import 'widgets/home/app_header.dart';
import 'widgets/home/top_icon_row.dart';
import 'widgets/home/frosted_panel.dart';
import 'widgets/home/mode_card.dart';
import 'widgets/home/audio_toggles.dart';
import 'theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App header with logo and title
                const AppHeader(),
                const SizedBox(height: 16),

                // Top utility icons
                const TopIconRow(),
                const SizedBox(height: 28),

                // Game modes inside a frosted panel for cohesion
                const FrostedPanel(
                  title: 'Choose your mode',
                  leadingIcon: Icons.rocket_launch_rounded,
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: _ModeList(),
                ),

                // Audio controls, same visual language
                FrostedPanel(
                  title: 'Audio Settings',
                  leadingIcon: Icons.graphic_eq_rounded,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  child: AudioTogglesPanel(
                    musicEnabled: _musicEnabled,
                    sfxEnabled: _sfxEnabled,
                    onMusicChanged: (value) => setState(() => _musicEnabled = value),
                    onSfxChanged: (value) => setState(() => _sfxEnabled = value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeList extends StatelessWidget {
  const _ModeList();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        ModeCard(
          title: 'Easy',
          description: 'Relaxed play with a gentle pace.',
          color: AppColors.easyMode,
        ),
        ModeCard(
          title: 'Normal',
          description: 'Classic challenge. Balanced and fun.',
          color: AppColors.normalMode,
        ),
        ModeCard(
          title: 'Bamboo Blitz',
          description: 'Special bricks and board flips.',
          color: const Color(0xFFFF5E57), // Vibrant fun red-orange
        ),
      ],
    );
  }
}

