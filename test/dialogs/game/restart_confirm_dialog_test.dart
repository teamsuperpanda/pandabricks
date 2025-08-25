import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/dialogs/game/restart_confirm_dialog.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('RestartConfirmDialog Tests', () {
    late LocaleProvider localeProvider;

    setUp(() {
      localeProvider = LocaleProvider();
    });

    testWidgets('should display restart confirmation content correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: RestartConfirmDialog(
                onRestart: () {},
                onCancel: () {},
              ),
            ),
          ),
        ),
      );

      // Check for restart confirmation title and message
      expect(find.text('Restart Game?'), findsOneWidget);
      expect(find.text('Are you sure you want to restart?\nYour current progress will be lost.'),
          findsOneWidget);

      // Check for restart icon (appears in header and button)
      expect(find.byIcon(Icons.refresh_rounded), findsAtLeastNWidgets(1));

      // Check for buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);

      // Check for button icons
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('should call onCancel when cancel button is tapped', (WidgetTester tester) async {
      bool restartCalled = false;
      bool cancelCalled = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: RestartConfirmDialog(
                onRestart: () => restartCalled = true,
                onCancel: () => cancelCalled = true,
              ),
            ),
          ),
        ),
      );

      // Tap the cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(restartCalled, isFalse);
      expect(cancelCalled, isTrue);
    });

    testWidgets('should call onRestart when restart button is tapped', (WidgetTester tester) async {
      bool restartCalled = false;
      bool cancelCalled = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: RestartConfirmDialog(
                onRestart: () => restartCalled = true,
                onCancel: () => cancelCalled = true,
              ),
            ),
          ),
        ),
      );

      // Tap the restart button
      await tester.tap(find.text('Restart'));
      await tester.pump();

      expect(restartCalled, isTrue);
      expect(cancelCalled, isFalse);
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
              body: RestartConfirmDialog(
                onRestart: () {},
                onCancel: () {},
              ),
            ),
          ),
        ),
      );

      // Check that it's wrapped in a Dialog
      expect(find.byType(Dialog), findsOneWidget);

      // Check for InkWell buttons (should be tappable)
      expect(find.byType(InkWell), findsNWidgets(2)); // Cancel, Restart

      // Check for Row layout (buttons side by side)
      expect(find.byType(Row), findsAtLeastNWidgets(1));
    });

    testWidgets('should have cancel and restart buttons in correct order', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: RestartConfirmDialog(
                onRestart: () {},
                onCancel: () {},
              ),
            ),
          ),
        ),
      );

      // Find both buttons
      final cancelFinder = find.text('Cancel');
      final restartFinder = find.text('Restart');

      expect(cancelFinder, findsOneWidget);
      expect(restartFinder, findsOneWidget);

      // Get their positions
      final cancelPosition = tester.getCenter(cancelFinder);
      final restartPosition = tester.getCenter(restartFinder);

      // Cancel should be on the left (smaller x coordinate)
      expect(cancelPosition.dx, lessThan(restartPosition.dx));
    });

    testWidgets('should display warning message about progress loss', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: RestartConfirmDialog(
                onRestart: () {},
                onCancel: () {},
              ),
            ),
          ),
        ),
      );

      // Check for warning message
      expect(find.textContaining('progress will be lost'), findsOneWidget);
    });
  });
}
