import 'package:flutter/material.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/widgets/home/animated_background.dart';
import 'package:pandabricks/widgets/home/ambient_particles.dart';
import 'package:pandabricks/widgets/home/animated_title.dart';
import 'package:pandabricks/widgets/home/audio_settings.dart';
import 'package:pandabricks/widgets/home/glass_icon_button.dart';
import 'package:pandabricks/widgets/home/mode_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _floatingController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _floatingAnimation;
  late AudioProvider _audioProvider;

  @override
  void initState() {
    super.initState();

    _audioProvider = context.read<AudioProvider>();
    if (_audioProvider.musicEnabled.value) {
      _audioProvider.playMenuMusic();
    }
    _audioProvider.musicEnabled.addListener(_onMusicToggle);

    _gradientController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  void _onMusicToggle() {
    if (_audioProvider.musicEnabled.value) {
      _audioProvider.playMenuMusic();
    } else {
      _audioProvider.stopMusic();
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _floatingController.dispose();
    _audioProvider.musicEnabled.removeListener(_onMusicToggle);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(gradientAnimation: _gradientAnimation),
          const AmbientParticles(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Centered title
                  AnimatedTitle(floatingAnimation: _floatingAnimation),
                  const SizedBox(height: 16),
                  // Glass action buttons centered
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  // Modes section
                  _SectionHeader(title: 'Game Modes'),
                  const SizedBox(height: 12),
                  _ModeList(
                    onTapClassic: () => Navigator.of(context).pushNamed('/game'),
                    onTapTimed: () => Navigator.of(context).pushNamed('/game'),
                    onTapPlaceholder: () => _showComingSoon(context),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Audio'),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: AudioSettings(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GlassIconButton(
          icon: Icons.help_outline_rounded,
          onTap: () => _showHelp(context),
          tooltip: 'Help',
        ),
        const SizedBox(width: 16),
        GlassIconButton(
          icon: Icons.settings_rounded,
          onTap: () => _showSettings(context),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Coming Soon!',
          style: TextStyle(
            fontFamily: 'Fredoka',
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This game mode will be available in a future update.',
          style: TextStyle(
            fontFamily: 'Fredoka',
            color: Colors.white.withAlpha((255 * 0.8).toInt()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Fredoka',
                color: Colors.cyan,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    _showComingSoon(context);
  }

  void _showSettings(BuildContext context) {
    _showComingSoon(context);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.withAlpha(120),
                  Colors.cyan.withAlpha(0),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeList extends StatelessWidget {
  const _ModeList({
    required this.onTapClassic,
    required this.onTapTimed,
    required this.onTapPlaceholder,
  });
  final VoidCallback onTapClassic;
  final VoidCallback onTapTimed;
  final VoidCallback onTapPlaceholder;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ModeItem(
        title: 'Classic Mode',
        subtitle: 'Classic falling blocks.',
        icon: Icons.grid_view_rounded,
        color: Colors.cyan,
        onTap: onTapClassic,
      ),
      _ModeItem(
        title: 'Time Challenge',
        subtitle: 'Beat the clock. Go fast!',
        icon: Icons.timer_rounded,
        color: Colors.purpleAccent,
        onTap: onTapTimed,
      ),
      _ModeItem(
        title: 'Blitz Mode',
        subtitle: 'Chaos, special bricks and table flips!',
        icon: Icons.flash_on_rounded,
        color: Colors.orangeAccent,
        onTap: onTapPlaceholder,
      ),
    ];
    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < items.length - 1 ? 16 : 0),
            child: items[i].buildCard(),
          ),
      ],
    );
  }
}

class _ModeItem {
  _ModeItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  Widget buildCard() {
    return ModeCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      accentColor: color,
      onTap: onTap,
      enabled: true,
    );
  }
}