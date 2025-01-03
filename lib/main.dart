import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/main/mode_card.dart';
import 'widgets/main/audio_toggles.dart';
import 'screens/game_screen.dart';
import 'models/mode_model.dart';
import 'logic/modes_logic.dart';
import 'services/audio_service.dart';
import 'services/games_services.dart';
import 'widgets/dialog/glowing_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final gamesServices = GamesServicesController();
  await gamesServices.initialize();

  try {
    // Initialize the Audio Service
    await AudioService().init();
  } catch (e) {
    debugPrint('Failed to initialize audio: $e');
    // Continue app initialization even if audio fails
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panda Bricks',
      theme: ThemeData(
        useMaterial3: true,
      ),
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
  final GamesServicesController _gamesServices = GamesServicesController();
  bool _isBackgroundMusicEnabled = false;
  bool _isSoundEffectsEnabled = false;

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

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
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
    });
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
                    const Center(
                      child: Text(
                        'Panda Bricks',
                        style: TextStyle(
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
                        IconButton(
                          icon: const Icon(
                            Icons.leaderboard_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => _showLeaderboardDialog(context),
                        ),
                      ],
                    ),
                    ModeCard(
                      mode: 'Easy',
                      onTap: () => navigateToGameScreen(context, Modes.easy),
                    ),
                    ModeCard(
                      mode: 'Normal',
                      onTap: () => navigateToGameScreen(context, Modes.normal),
                    ),
                    ModeCard(
                      mode: 'Bamboo Blitz',
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

  void _showLeaderboardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C3E50), Color(0xFF1A1A2E)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAlpha((0.1 * 255).round()),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Leaderboards',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GlowingButton(
                    onPressed: () => _gamesServices.showLeaderboard('Easy'),
                    color: const Color(0xFF2ECC71),
                    text: 'EASY',
                  ),
                  GlowingButton(
                    onPressed: () => _gamesServices.showLeaderboard('Normal'),
                    color: const Color(0xFF3498DB),
                    text: 'NORMAL',
                  ),
                  GlowingButton(
                    onPressed: () =>
                        _gamesServices.showLeaderboard('BambooBlitz'),
                    color: const Color(0xFFE74C3C),
                    text: 'BLITZ',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
