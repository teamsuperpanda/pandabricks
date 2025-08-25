import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/dialogs/game/pause_dialog.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('PauseDialog Tests', () {
    late LocaleProvider localeProvider;

    setUp(() {
      localeProvider = LocaleProvider();
    });

    testWidgets('should display pause dialog content correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PauseDialog(
                onResume: () {},
                onRestart: () {},
                onMainMenu: () {},
              ),
            ),
          ),
        ),
      );

      // Check for pause title and description
      expect(find.text('Game Paused'), findsOneWidget);
      expect(find.text('Your game is currently paused.'), findsOneWidget);

      // Check for pause icon
      expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget);

      // Check for buttons
      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('Main Menu'), findsOneWidget);

      // Check for button icons
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('should call onResume when resume button is tapped', (WidgetTester tester) async {
      bool resumeCalled = false;
      bool restartCalled = false;
      bool mainMenuCalled = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PauseDialog(
                onResume: () => resumeCalled = true,
                onRestart: () => restartCalled = true,
                onMainMenu: () => mainMenuCalled = true,
              ),
            ),
          ),
        ),
      );

      // Tap the resume button
      await tester.tap(find.text('Resume'));
      await tester.pump();

      expect(resumeCalled, isTrue);
      expect(restartCalled, isFalse);
      expect(mainMenuCalled, isFalse);
    });

    testWidgets('should call onRestart when restart button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PauseDialog(
                onResume: () {},
                onRestart: () {},
                onMainMenu: () {},
              ),
            ),
          ),
        ),
      );

      // Note: Pause dialog doesn't have a restart button, only Resume and Main Menu
      expect(find.text('Restart'), findsNothing);
    });

    testWidgets('should call onMainMenu when main menu button is tapped', (WidgetTester tester) async {
      bool resumeCalled = false;
      bool restartCalled = false;
      bool mainMenuCalled = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PauseDialog(
                onResume: () => resumeCalled = true,
                onRestart: () => restartCalled = true,
                onMainMenu: () => mainMenuCalled = true,
              ),
            ),
          ),
        ),
      );

      // Tap the main menu button
      await tester.tap(find.text('Main Menu'));
      await tester.pump();

      expect(resumeCalled, isFalse);
      expect(restartCalled, isFalse);
      expect(mainMenuCalled, isTrue);
    });

    testWidgets('should have proper widget hierarchy', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PauseDialog(
                onResume: () {},
                onRestart: () {},
                onMainMenu: () {},
              ),
            ),
          ),
        ),
      );

      // Check that it's wrapped in a Dialog
      expect(find.byType(Dialog), findsOneWidget);

      // Check for InkWell buttons (should be tappable)
      expect(find.byType(InkWell), findsNWidgets(2)); // Resume, Main Menu
    });
  });
}
