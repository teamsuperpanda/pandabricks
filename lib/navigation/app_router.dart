import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandabricks/models/game_settings.dart';
import 'package:pandabricks/screens/game/screen.dart';
import 'package:pandabricks/screens/home/home_screen.dart';

class AppRouter {
  AppRouter()
    : router = GoRouter(
        initialLocation: '/',
        observers: const <NavigatorObserver>[],
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/game',
            builder: (context, state) => GameScreen(
              settings: state.extra is GameSettings
                  ? state.extra! as GameSettings
                  : const GameSettings.classic(),
            ),
          ),
        ],
      );

  final GoRouter router;
}
