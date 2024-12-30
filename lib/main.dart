import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/main/mode_card.dart';
import 'widgets/main/audio_toggles.dart';
import 'screens/game_screen.dart';
import 'models/mode_model.dart';
import 'constants/modes.dart';
import 'services/audio_service.dart';

void main() {
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
}
