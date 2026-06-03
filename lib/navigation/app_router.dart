import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandabricks/screens/game/screen.dart';
import 'package:pandabricks/screens/home/home_screen.dart';

class AppRouter {
  AppRouter({List<NavigatorObserver>? navigatorObservers}) : router = GoRouter(
    initialLocation: '/',
    observers: navigatorObservers ?? [],
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameScreen(),
      ),
    ],
  );

  final GoRouter router;
}
