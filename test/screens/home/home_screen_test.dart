import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:pandabricks/screens/home/home_screen.dart';
import 'package:pandabricks/widgets/home/ambient_particles.dart';
import 'package:pandabricks/widgets/home/animated_background.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_audio_provider.dart';

Widget _buildApp(
  MockAudioProvider audio,
  LocaleProvider locale, {
  Widget? home,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AudioProvider>.value(value: audio),
      ChangeNotifierProvider<LocaleProvider>.value(value: locale),
    ],
    child: MaterialApp(
      locale: locale.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home ?? const HomeScreen(),
    ),
  );
}

Widget _buildRouterApp(
  MockAudioProvider audio,
  LocaleProvider locale,
  Widget gameScreen,
) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => gameScreen,
      ),
    ],
  );
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AudioProvider>.value(value: audio),
      ChangeNotifierProvider<LocaleProvider>.value(value: locale),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      locale: locale.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  group('Home Screen Tests', () {
    late MockAudioProvider mockAudioProvider;
    late LocaleProvider localeProvider;

    setUp(() {
      mockAudioProvider = MockAudioProvider();
      localeProvider = LocaleProvider();
    });

    testWidgets('Home screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp(mockAudioProvider, localeProvider));

      await tester.pump();

      expect(find.text('PANDA BRICKS'), findsOneWidget);
      expect(find.text('Game Modes'), findsOneWidget);
      expect(find.text('Classic Mode'), findsOneWidget);
      expect(find.text('Classic falling blocks.'), findsOneWidget);
      expect(find.text('Time Challenge'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.language_rounded), findsOneWidget);
    });

    testWidgets('Menu music plays on init', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp(mockAudioProvider, localeProvider));

      await tester.pump();

      expect(mockAudioProvider.currentlyPlaying, MockAudioProvider.menuTrack);
      expect(mockAudioProvider.isGameMusic, false);
    });

    testWidgets('Custom Game button opens custom game dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildApp(mockAudioProvider, localeProvider));

      await tester.pump();

      expect(find.text('Custom Mode'), findsOneWidget);
      await tester.tap(find.text('Custom Mode'));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('Classic Mode button navigates to game screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildRouterApp(
          mockAudioProvider,
          localeProvider,
          const Scaffold(body: Center(child: Text('Game Screen'))),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Classic Mode'));
      await tester.pumpAndSettle();

      expect(find.text('Game Screen'), findsOneWidget);
    });

    testWidgets('Time Challenge button navigates to game screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildRouterApp(
          mockAudioProvider,
          localeProvider,
          const Scaffold(body: Center(child: Text('Game Screen'))),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Time Challenge'));
      await tester.pumpAndSettle();

      expect(find.text('Game Screen'), findsOneWidget);
    });

    testWidgets('Blitz Mode button navigates to game screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _buildRouterApp(
          mockAudioProvider,
          localeProvider,
          const Scaffold(body: Center(child: Text('Game Screen'))),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Blitz Mode'));
      await tester.pumpAndSettle();

      expect(find.text('Game Screen'), findsOneWidget);
    });

    testWidgets('Help button opens help dialog', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp(mockAudioProvider, localeProvider));

      await tester.pump();

      await tester.tap(find.byIcon(Icons.help_outline_rounded));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Special Bricks'), findsOneWidget);
      expect(find.text('Panda Brick'), findsOneWidget);
    });

    testWidgets('Language button opens language selector dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildApp(mockAudioProvider, localeProvider));

      await tester.pump();

      await tester.tap(find.byIcon(Icons.language_rounded));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('Audio settings are visible', (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp(mockAudioProvider, localeProvider));

      await tester.pump();

      expect(find.text('Audio'), findsOneWidget);
      expect(find.byType(Switch), findsAtLeastNWidgets(1));
    });

    testWidgets('Game mode cards have proper styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildApp(mockAudioProvider, localeProvider));

      await tester.pump();

      expect(find.byType(GlassMorphismCard), findsWidgets);
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      expect(find.byIcon(Icons.timer_rounded), findsOneWidget);
      expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    });

    testWidgets('Screen has proper layout structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildApp(mockAudioProvider, localeProvider));

      await tester.pump();

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(AnimatedBackground), findsOneWidget);
      expect(find.byType(AmbientParticles), findsOneWidget);
    });

    testWidgets('Language selector has language options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildApp(mockAudioProvider, localeProvider));

      await tester.pump();

      await tester.tap(find.byIcon(Icons.language_rounded));
      await tester.pump();

      expect(find.text('English'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });
  });
}
