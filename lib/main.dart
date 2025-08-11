import 'package:flutter/material.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/screens/home/home_screen.dart';
import 'package:pandabricks/screens/game/screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AudioProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panda Bricks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Fredoka',
        scaffoldBackgroundColor: const Color(0x00000000),
      ),
      home: const HomeScreen(),
      routes: {
  '/game': (_) => const GameScreen(),
      },
    );
  }
}
