import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'widgets/main/mode_card.dart';
import 'widgets/main/audio_toggles.dart';
import 'screens/game_screen.dart';
import 'models/mode_model.dart';
import 'constants/modes.dart';

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
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  bool _isBackgroundMusicEnabled = false;

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

    setState(() {
      _isBackgroundMusicEnabled = prefs.getBool('backgroundMusic') ?? true;
    });
  }

  Future<void> _setupBackgroundMusic() async {
    await _backgroundMusicPlayer.setAsset('audio/music/menu.mp3');
    await _backgroundMusicPlayer.setLoopMode(LoopMode.all);

    if (_isBackgroundMusicEnabled) {
      _backgroundMusicPlayer.play();
    }
  }

  Future<void> _toggleBackgroundMusic(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('backgroundMusic', value);

    setState(() {
      _isBackgroundMusicEnabled = value;
    });

    if (_isBackgroundMusicEnabled) {
      _backgroundMusicPlayer.play();
    } else {
      _backgroundMusicPlayer.pause();
    }
  }

  @override
  void dispose() {
    _backgroundMusicPlayer.dispose();
    super.dispose();
  }

  void navigateToGameScreen(BuildContext context, ModeModel mode) {
    _backgroundMusicPlayer.pause();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(mode: mode)),
    ).then((_) {
      // Resume music when returning to main menu if it's enabled
      if (_isBackgroundMusicEnabled) {
        _backgroundMusicPlayer.play();
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
                      onBackgroundMusicChanged: _toggleBackgroundMusic,
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
