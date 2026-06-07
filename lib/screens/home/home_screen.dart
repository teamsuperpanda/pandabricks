import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pandabricks/dialogs/game/custom_game_dialog.dart';
import 'package:pandabricks/dialogs/home/help_dialog.dart';
import 'package:pandabricks/dialogs/home/language_selector_dialog.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/models/game_settings.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/widgets/home/ambient_particles.dart';
import 'package:pandabricks/widgets/home/animated_background.dart';
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
  static const _showCustomDialogArg = Object();

  late AnimationController _gradientController;
  late AnimationController _floatingController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _floatingAnimation;
  AudioProvider? _audioProvider;
  bool _audioInitialized = false;
  bool _customDialogShown = false;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    unawaited(_gradientController.repeat(reverse: true));

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    unawaited(_floatingController.repeat(reverse: true));

    _gradientAnimation =
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _gradientController,
            curve: Curves.easeInOut,
          ),
        );

    _floatingAnimation =
        Tween<double>(
          begin: -8,
          end: 8,
        ).animate(
          CurvedAnimation(
            parent: _floatingController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_audioInitialized) {
      _audioProvider = context.read<AudioProvider>();
      if (_audioProvider!.musicEnabled) {
        unawaited(_audioProvider!.playMenuMusic());
      }
      _audioInitialized = true;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (identical(args, _showCustomDialogArg) && !_customDialogShown) {
      _customDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCustomGameDialog(context);
      });
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Semantics(
          label: 'Home screen',
          child: Stack(
            children: [
              Semantics(
                label: 'Background animation',
                child: AnimatedBackground(
                  gradientAnimation: _gradientAnimation,
                ),
              ),
              Semantics(
                label: 'Ambient particles',
                child: const AmbientParticles(),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Semantics(
                        header: true,
                        label: l10n!.appTitle,
                        child: AnimatedTitle(
                          floatingAnimation: _floatingAnimation,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        label: 'Action buttons',
                        child: _buildActionButtons(l10n),
                      ),
                      const SizedBox(height: 24),
                      Semantics(
                        header: true,
                        label: l10n.gameModes,
                        child: _SectionHeader(title: l10n.gameModes),
                      ),
                      const SizedBox(height: 12),
                      Semantics(
                        label: 'Game mode selection',
                        child: _ModeList(
                          onTapClassic: () => context.push(
                            '/game',
                            extra: const GameSettings.classic(),
                          ),
                          onTapTimed: () => context.push(
                            '/game',
                            extra: const GameSettings.timeChallenge(),
                          ),
                          onTapBlitz: () => context.push(
                            '/game',
                            extra: const GameSettings.blitz(),
                          ),
                          onTapCustom: () => _showCustomGameDialog(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Semantics(
                        header: true,
                        label: l10n.audio,
                        child: _SectionHeader(title: l10n.audio),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: 'Audio settings',
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: AudioSettings(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Semantics(
      label: 'Action buttons',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            button: true,
            label: l10n.help,
            child: GlassIconButton(
              icon: Icons.help_outline_rounded,
              onTap: () => _showHelp(context),
              tooltip: l10n.help,
            ),
          ),
          const SizedBox(width: 16),
          Semantics(
            button: true,
            label: l10n.language,
            child: GlassIconButton(
              icon: Icons.language_rounded,
              onTap: () => _showLanguageSelector(context),
              tooltip: l10n.language,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    unawaited(showDialog(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    ));
  }

  void _showHelp(BuildContext context) {
    unawaited(showDialog(
      context: context,
      builder: (context) => const HelpDialog(),
    ));
  }

  void _showCustomGameDialog(BuildContext context) {
    unawaited(showDialog(
      context: context,
      builder: (context) => const CustomGameDialog(),
    ));
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
                  Colors.cyan.withValues(alpha: 120 / 255.0),
                  Colors.cyan.withValues(alpha: 0 / 255.0),
                ],
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
    required this.onTapBlitz,
    required this.onTapCustom,
  });
  final VoidCallback onTapClassic;
  final VoidCallback onTapTimed;
  final VoidCallback onTapBlitz;
  final VoidCallback onTapCustom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        ModeCard(
          title: l10n.classicMode,
          subtitle: l10n.classicModeDescription,
          icon: Icons.grid_view_rounded,
          onTap: onTapClassic,
        ),
        const SizedBox(height: 16),
        ModeCard(
          title: l10n.timeChallenge,
          subtitle: l10n.timeChallengeDescription,
          icon: Icons.timer_rounded,
          accentColor: Colors.purpleAccent,
          onTap: onTapTimed,
        ),
        const SizedBox(height: 16),
        ModeCard(
          title: l10n.blitzMode,
          subtitle: l10n.blitzModeDescription,
          icon: Icons.flash_on_rounded,
          accentColor: Colors.orangeAccent,
          onTap: onTapBlitz,
        ),
        const SizedBox(height: 16),
        ModeCard(
          title: l10n.customMode,
          subtitle: l10n.customModeDescription,
          icon: Icons.settings_rounded,
          accentColor: Colors.greenAccent,
          onTap: onTapCustom,
        ),
      ],
    );
  }
}
