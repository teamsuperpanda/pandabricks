import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pandabricks/screens/home/home_screen.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';
import 'package:pandabricks/widgets/home/animated_background.dart';
import 'package:pandabricks/widgets/home/ambient_particles.dart';
import '../../mocks/mock_audio_provider.dart';

void main() {
  group('Home Screen Tests', () {
    late MockAudioProvider mockAudioProvider;
    late LocaleProvider localeProvider;

    setUp(() {
      mockAudioProvider = MockAudioProvider();
      localeProvider = LocaleProvider();
    });

    testWidgets('Home screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>.value(value: mockAudioProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );

      // Wait for initial animations to settle, but with timeout
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify the main title exists (matches actual widget text)
      expect(find.text('PANDA BRICKS'), findsOneWidget);

      // Verify the game modes section exists
      expect(find.text('Game Modes'), findsOneWidget);

      // Verify Classic Mode card exists
      expect(find.text('Classic Mode'), findsOneWidget);
      expect(find.text('Classic falling blocks.'), findsOneWidget);

      // Verify Time Challenge card exists
      expect(find.text('Time Challenge'), findsOneWidget);
      expect(find.text('Beat the clock. Go fast!'), findsOneWidget);

      // Verify Blitz Mode card exists
      expect(find.text('Blitz Mode'), findsOneWidget);
      // Test for both possible descriptions (depending on locale loading)
      final blitzDescriptions = [
        'Chaos and special bricks',
        'Chaos with special bricks'
      ];
      bool foundBlitzDescription = false;
      for (String description in blitzDescriptions) {
        if (find.text(description).evaluate().isNotEmpty) {
          foundBlitzDescription = true;
          break;
        }
      }
      expect(foundBlitzDescription, isTrue, 
        reason: 'Should find one of the expected Blitz Mode descriptions');

      // Verify Audio section exists
      expect(find.text('Audio'), findsOneWidget);

      // Verify action buttons exist
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.language_rounded), findsOneWidget);
    });

    testWidgets('Menu music plays on init', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>.value(value: mockAudioProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify menu music started playing
      expect(mockAudioProvider.currentlyPlaying, MockAudioProvider.menuTrack);
      expect(mockAudioProvider.isGameMusic, false);
    });

    testWidgets('Custom Game button opens custom game dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>.value(value: mockAudioProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Find and tap the Custom Mode button
      expect(find.text('Custom Mode'), findsOneWidget);
      await tester.tap(find.text('Custom Mode'));
      await tester.pump();

      // Verify custom game dialog appears
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('Classic Mode button navigates to game screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>.value(value: mockAudioProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
            routes: {
              '/game': (context) => const Scaffold(body: Center(child: Text('Game Screen'))),
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Tap Classic Mode button
      await tester.tap(find.text('Classic Mode'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.text('Game Screen'), findsOneWidget);
    });

    testWidgets('Time Challenge button navigates to game screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>.value(value: mockAudioProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
            routes: {
              '/game': (context) => const Scaffold(body: Center(child: Text('Game Screen'))),
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Tap Time Challenge button
      await tester.tap(find.text('Time Challenge'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.text('Game Screen'), findsOneWidget);
    });

    testWidgets('Blitz Mode button navigates to game screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>.value(value: mockAudioProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
            routes: {
              '/game': (context) => const Scaffold(body: Center(child: Text('Game Screen'))),
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Tap Blitz Mode button
      await tester.tap(find.text('Blitz Mode'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.text('Game Screen'), findsOneWidget);
    });

    testWidgets('Help button exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>.value(value: mockAudioProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify help button exists
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    });

    testWidgets('Language button exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>.value(value: mockAudioProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify language button exists
      expect(find.byIcon(Icons.language_rounded), findsOneWidget);
    });

    testWidgets('Audio settings are visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>.value(value: mockAudioProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify Audio section exists
      expect(find.text('Audio'), findsOneWidget);

      // Verify switches are present (should have at least music and SFX toggles)
      expect(find.byType(Switch), findsAtLeastNWidgets(1));
    });

    testWidgets('Game mode cards have proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>.value(value: mockAudioProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify game mode cards exist and are styled
      expect(find.byType(GlassMorphismCard), findsWidgets);

      // Verify each game mode has an icon
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget); // Classic
      expect(find.byIcon(Icons.timer_rounded), findsOneWidget); // Time Challenge
      expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget); // Blitz
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget); // Custom
    });

    testWidgets('Screen has proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AudioProvider>.value(value: mockAudioProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify main layout components
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(AnimatedBackground), findsOneWidget);
      expect(find.byType(AmbientParticles), findsOneWidget);
    });
  });
}