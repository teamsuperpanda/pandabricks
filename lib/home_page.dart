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
            constraints: const BoxConstraints(maxWidth: 580),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App header with logo and title
                const AppHeader(),
                const SizedBox(height: 20),
                
                // Top utility icons
                const TopIconRow(),
                const SizedBox(height: 32),

                // Game modes panel
                FrostedPanel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                        description: 'Beat the clock with spicy specials.',
                        color: AppColors.blitzMode,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                // Audio controls panel
                FrostedPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

