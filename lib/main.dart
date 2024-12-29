import 'dart:ui';
import 'package:flutter/material.dart';
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  void navigateToGameScreen(BuildContext context, ModeModel mode) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(mode: mode)),
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
                    const AudioToggles(),
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
