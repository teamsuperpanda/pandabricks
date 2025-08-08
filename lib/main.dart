import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pandabricks/theme.dart';
import 'widgets/main/mode_card.dart';
import 'widgets/main/audio_toggles.dart';
import 'screens/game_screen.dart';
import 'models/mode_model.dart';
import 'logic/modes_logic.dart';
import 'services/audio_service.dart';
import 'widgets/main/help_dialog.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'package:pandabricks/services/language_service.dart';
import 'package:pandabricks/dialog/main/language_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AudioService().init();
  } catch (e) {
    debugPrint('Failed to initialize audio: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final locale = await LanguageService.getSelectedLocale();
    setState(() {
      _selectedLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Panda Bricks',
      theme: AppTheme.darkTheme,
      locale: _selectedLocale,
      supportedLocales: L10n.all,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AudioService _audioService = AudioService();
  bool _isBackgroundMusicEnabled = false;
  bool _isSoundEffectsEnabled = false;
  final _easyModeKey = GlobalKey<ModeCardState>();
  final _normalModeKey = GlobalKey<ModeCardState>();
  final _blitzModeKey = GlobalKey<ModeCardState>();

  @override
  void initState() {
    super.initState();
    _loadAudioPreferences();
    _setupBackgroundMusic();
  }

  Future<void> _loadAudioPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('backgroundMusic')) {
      await prefs.setBool('backgroundMusic', true);
    }
    if (!prefs.containsKey('soundEffects')) {
      await prefs.setBool('soundEffects', true);
    }

    setState(() {
      _isBackgroundMusicEnabled = prefs.getBool('backgroundMusic') ?? true;
      _isSoundEffectsEnabled = prefs.getBool('soundEffects') ?? true;
    });
  }

  Future<void> _setupBackgroundMusic() async {
    await _audioService.initMenuMusic();
    if (_isBackgroundMusicEnabled) {
      _audioService.playMenuMusic();
    }
  }

  Future<void> _toggleBackgroundMusic(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('backgroundMusic', value);

    setState(() {
      _isBackgroundMusicEnabled = value;
    });

    if (_isBackgroundMusicEnabled) {
      _audioService.playMenuMusic();
    } else {
      _audioService.pauseMenuMusic();
    }
  }

  Future<void> _toggleSoundEffects(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEffects', value);

    setState(() {
      _isSoundEffectsEnabled = value;
    });
  }

  void navigateToGameScreen(BuildContext context, ModeModel mode) {
    _audioService.pauseMenuMusic();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          mode: mode,
          isSoundEffectsEnabled: _isSoundEffectsEnabled,
          isBackgroundMusicEnabled: _isBackgroundMusicEnabled,
        ),
      ),
    ).then((_) {
      if (_isBackgroundMusicEnabled) {
        _audioService.playMenuMusic();
      }
      _easyModeKey.currentState?.refreshHighScore();
      _normalModeKey.currentState?.refreshHighScore();
      _blitzModeKey.currentState?.refreshHighScore();
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LanguageDialog(
        onLanguageChanged: (locale) {
          if (context.mounted) {
            setState(() {
              // This will trigger a rebuild of the MaterialApp
              context.findAncestorStateOfType<_MyAppState>()?.setState(() {
                context
                    .findAncestorStateOfType<_MyAppState>()
                    ?._selectedLocale = locale;
              });
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: Container(
                color: Colors.black.withAlpha(26),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.appTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Fredoka',
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Semantics(
                          label: AppLocalizations.of(context)!.help,
                          button: true,
                          child: IconButton(
                            icon: const Icon(
                              Icons.help_outline_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () => _showHelpDialog(context),
                          ),
                        ),
                        Semantics(
                          label: AppLocalizations.of(context)!.language,
                          button: true,
                          child: IconButton(
                            icon: const Icon(
                              Icons.language_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () => _showLanguageDialog(context),
                          ),
                        ),
                      ],
                    ),
                    ModeCard(
                      key: _easyModeKey,
                      modeModel: Modes.easy,
                      onTap: () => navigateToGameScreen(context, Modes.easy),
                    ),
                    ModeCard(
                      key: _normalModeKey,
                      modeModel: Modes.normal,
                      onTap: () => navigateToGameScreen(context, Modes.normal),
                    ),
                    ModeCard(
                      key: _blitzModeKey,
                      modeModel: Modes.bambooblitz,
                      onTap: () =>
                          navigateToGameScreen(context, Modes.bambooblitz),
                    ),
                    AudioToggles(
                      isBackgroundMusicEnabled: _isBackgroundMusicEnabled,
                      isSoundEffectsEnabled: _isSoundEffectsEnabled,
                      onBackgroundMusicChanged: _toggleBackgroundMusic,
                      onSoundEffectsChanged: _toggleSoundEffects,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HelpDialog(),
    );
  }
}
