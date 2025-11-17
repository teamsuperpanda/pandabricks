import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/dialogs/game/pause_dialog.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pandabricks/l10n/app_localizations.dart';

void main() {
  group('PauseDialog', () {
    late int resumeCallCount;
    late int restartCallCount;
    late int mainMenuCallCount;

    setUp(() {
      resumeCallCount = 0;
      restartCallCount = 0;
      mainMenuCallCount = 0;
    });

    Widget buildTestWidget() {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => PauseDialog(
                        onResume: () {
                          resumeCallCount++;
                          Navigator.of(context).pop(); // Close dialog
                        },
                        onRestart: () {
                          restartCallCount++;
                          Navigator.of(context).pop(); // Close dialog
                        },
                        onMainMenu: () {
                          mainMenuCallCount++;
                          Navigator.of(context).pop(); // Close dialog
                        },
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            );
          },
        ),
      );
    }

    testWidgets('should display pause dialog', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check that the dialog is displayed
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('should display pause icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check for the pause icon
      expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget);
    });

    testWidgets('should display resume button with icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check resume button icon
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('should display main menu button with icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check main menu button icon
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('should call onResume when resume button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Find and tap the resume button (by its icon since text might vary by locale)
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      // Check that callback was called
      expect(resumeCallCount, 1);
      expect(restartCallCount, 0);
      expect(mainMenuCallCount, 0);
    });

    testWidgets('should call onMainMenu when main menu button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Find and tap the main menu button (by its icon)
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();

      // Check that callback was called
      expect(resumeCallCount, 0);
      expect(restartCallCount, 0);
      expect(mainMenuCallCount, 1);
    });

    testWidgets('should close dialog when resume button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.byType(Dialog), findsOneWidget);

      // Tap resume button
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should close dialog when main menu button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.byType(Dialog), findsOneWidget);

      // Tap main menu button
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should have transparent dialog background', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check dialog background color
      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.backgroundColor, Colors.transparent);
    });

    testWidgets('should have proper button layout', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check that we have the expected number of buttons (resume and main menu)
      final buttonFinders = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(InkWell),
      );
      expect(buttonFinders, findsNWidgets(2));
    });
  });
}