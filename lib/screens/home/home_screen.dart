import 'package:pandabricks/providers/locale_provider.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/widgets/home/animated_background.dart';
import 'package:pandabricks/widgets/home/ambient_particles.dart';
import 'package:pandabricks/widgets/home/animated_title.dart';
import 'package:pandabricks/widgets/home/audio_settings.dart';
import 'package:pandabricks/widgets/home/glass_icon_button.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';
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
  AudioProvider? _audioProvider;
  bool _audioInitialized = false;

  @override
  void initState() {
    super.initState();

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_audioInitialized) {
      _audioProvider = context.read<AudioProvider>();
      if (_audioProvider!.musicEnabled.value) {
        _audioProvider!.playMenuMusic();
      }
      _audioProvider!.musicEnabled.addListener(_onMusicToggle);
      _audioInitialized = true;
    }
  }

  void _onMusicToggle() {
    if (_audioProvider?.musicEnabled.value == true) {
      _audioProvider!.playMenuMusic();
    } else {
      _audioProvider?.stopMusic();
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _floatingController.dispose();
    _audioProvider?.musicEnabled.removeListener(_onMusicToggle);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  _buildActionButtons(l10n!),
                  const SizedBox(height: 24),
                  // Modes section
                  _SectionHeader(title: l10n.gameModes),
                  const SizedBox(height: 12),
                  _ModeList(
                    onTapClassic: () => Navigator.of(context).pushNamed('/game', arguments: 'classic'),
                    onTapTimed: () => Navigator.of(context).pushNamed('/game', arguments: 'timeChallenge'),
                    onTapPlaceholder: () => Navigator.of(context).pushNamed('/game', arguments: 'blitz'),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: l10n.audio),
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

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GlassIconButton(
          icon: Icons.help_outline_rounded,
          onTap: () => _showHelp(context, l10n),
          tooltip: l10n.help,
        ),
        const SizedBox(width: 16),
        GlassIconButton(
          icon: Icons.language_rounded,
          onTap: () => _showLanguageSelector(context, l10n),
          tooltip: l10n.language,
        ),
      ],
    );
  }

  void _showLanguageSelector(BuildContext context, AppLocalizations l10n) {
    final localeProvider = context.read<LocaleProvider>();
    final supportedLocales = AppLocalizations.supportedLocales;
    final languageNames = {
      'en': 'English',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'ko': '한국어',
      'ja': '日本語',
      'zh': '中文',
      'hi': 'हिन्दी',
      'ar': 'العربية',
      'bn': 'বাংলা',
      'ru': 'Русский',
      'ur': 'اردو',
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassMorphismCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.language,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: supportedLocales.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _LanguageCard(
                          languageName: 'System',
                          onTap: () {
                            localeProvider.setLocale(null);
                            Navigator.of(context).pop();
                          },
                        );
                      }
                      final locale = supportedLocales[index - 1];
                      final languageName = languageNames[locale.languageCode] ?? locale.languageCode;
                      return _LanguageCard(
                        languageName: languageName,
                        onTap: () {
                          localeProvider.setLocale(locale);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelp(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassMorphismCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  size: 48,
                  color: Colors.cyanAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.specialBricks,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                // List of special bricks with emoji icons
                _helpRow('🐼', l10n.pandaBrick, l10n.pandaBrickDescription),
                const SizedBox(height: 12),
                _helpRow('👻', l10n.ghostBrick, l10n.ghostBrickDescription),
                const SizedBox(height: 12),
                _helpRow('🐱', l10n.catBrick, l10n.catBrickDescription),
                const SizedBox(height: 12),
                _helpRow('🌪️', l10n.tornadoBrick, l10n.tornadoBrickDescription),
                const SizedBox(height: 12),
                _helpRow('💣', l10n.bombBrick, l10n.bombBrickDescription),
                const SizedBox(height: 24),
                GlassMorphismCard(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Text(
                          l10n.close,
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 16,
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _helpRow(String emoji, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 13,
                  color: Colors.white.withAlpha(180),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
    final l10n = AppLocalizations.of(context)!;
    final items = [
      _ModeItem(
        title: l10n.classicMode,
        subtitle: l10n.classicModeDescription,
        icon: Icons.grid_view_rounded,
        color: Colors.cyan,
        onTap: onTapClassic,
      ),
      _ModeItem(
        title: l10n.timeChallenge,
        subtitle: l10n.timeChallengeDescription,
        icon: Icons.timer_rounded,
        color: Colors.purpleAccent,
        onTap: onTapTimed,
      ),
      _ModeItem(
        title: l10n.blitzMode,
        subtitle: l10n.blitzModeDescription,
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

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.languageName,
    required this.onTap,
  });

  final String languageName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassMorphismCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            languageName,
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
    );
  }
}