import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/dialogs/game/main_menu_confirm_dialog.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('MainMenuConfirmDialog Tests', () {
    late LocaleProvider localeProvider;

    setUp(() {
      localeProvider = LocaleProvider();
    });

    testWidgets('should display main menu confirmation content correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MainMenuConfirmDialog(
                onConfirm: () {},
                onCancel: () {},
              ),
            ),
          ),
        ),
      );

      // Check for main menu confirmation title and message
      expect(find.text('Return to Main Menu?'), findsOneWidget);
      expect(find.text('Your current game progress will be lost.'), findsOneWidget);

      // Check for home icon (appears in header and button)
      expect(find.byIcon(Icons.home_rounded), findsAtLeastNWidgets(1));

      // Check for buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Main Menu'), findsOneWidget);

      // Check for button icons
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('should call onCancel when cancel button is tapped',
        (WidgetTester tester) async {
      bool confirmCalled = false;
      bool cancelCalled = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MainMenuConfirmDialog(
                onConfirm: () => confirmCalled = true,
                onCancel: () => cancelCalled = true,
              ),
            ),
          ),
        ),
      );

      // Tap the cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(confirmCalled, isFalse);
      expect(cancelCalled, isTrue);
    });

    testWidgets('should call onConfirm when confirm button is tapped',
        (WidgetTester tester) async {
      bool confirmCalled = false;
      bool cancelCalled = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MainMenuConfirmDialog(
                onConfirm: () => confirmCalled = true,
                onCancel: () => cancelCalled = true,
              ),
            ),
          ),
        ),
      );

      // Tap the confirm button
      await tester.tap(find.text('Main Menu'));
      await tester.pump();

      expect(confirmCalled, isTrue);
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
              body: MainMenuConfirmDialog(
                onConfirm: () {},
                onCancel: () {},
              ),
            ),
          ),
        ),
      );

      // Check that it's wrapped in a Dialog
      expect(find.byType(Dialog), findsOneWidget);

      // Check for InkWell buttons (should be tappable)
      expect(find.byType(InkWell), findsNWidgets(2)); // Cancel, Confirm

      // Check for Row layout (buttons side by side)
      expect(find.byType(Row), findsAtLeastNWidgets(1));
    });

    testWidgets('should have cancel and confirm buttons in correct order',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MainMenuConfirmDialog(
                onConfirm: () {},
                onCancel: () {},
              ),
            ),
          ),
        ),
      );

      // Find both buttons
      final cancelFinder = find.text('Cancel');
      final confirmFinder = find.text('Main Menu');

      expect(cancelFinder, findsOneWidget);
      expect(confirmFinder, findsAtLeastNWidgets(1)); // May appear multiple times

      // Get their positions
      final cancelPosition = tester.getCenter(cancelFinder);
      final confirmPosition = tester.getCenter(confirmFinder.first);

      // Cancel should be on the left (smaller x coordinate)
      expect(cancelPosition.dx, lessThan(confirmPosition.dx));
    });

    testWidgets('should display warning message about progress loss',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MainMenuConfirmDialog(
                onConfirm: () {},
                onCancel: () {},
              ),
            ),
          ),
        ),
      );

      // Check for warning message
      expect(find.textContaining('progress will be lost'), findsOneWidget);
    });

    testWidgets('should use different action text than restart dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: MainMenuConfirmDialog(
                onConfirm: () {},
                onCancel: () {},
              ),
            ),
          ),
        ),
      );

      // Should use "Main Menu" instead of "Restart"
      expect(find.text('Main Menu'), findsAtLeastNWidgets(1));
      expect(find.text('Restart'), findsNothing);

      // Should ask about returning to main menu, not restarting
      expect(find.textContaining('Return to Main Menu'), findsOneWidget);
    });
  });
}
