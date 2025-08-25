import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pandabricks/screens/home/home_screen.dart';
import 'package:pandabricks/providers/audio_provider.dart';
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
      expect(find.text('Chaos, special bricks and table flips!'), findsOneWidget);

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
  });
}
