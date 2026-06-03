import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/dialogs/game/pause_dialog.dart';
import 'package:pandabricks/l10n/app_localizations.dart';

Widget buildPauseDialog({
  VoidCallback? onResume,
  VoidCallback? onRestart,
  VoidCallback? onMainMenu,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: PauseDialog(
        onResume: onResume ?? () {},
        onRestart: onRestart ?? () {},
        onMainMenu: onMainMenu ?? () {},
      ),
    ),
  );
}

void main() {
  group('PauseDialog', () {
    testWidgets('displays pause icon', (WidgetTester tester) async {
      await tester.pumpWidget(buildPauseDialog());
      expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget);
    });

    testWidgets('displays resume and main menu buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildPauseDialog());
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('calls onResume when resume tapped', (
      WidgetTester tester,
    ) async {
      var called = false;
      await tester.pumpWidget(buildPauseDialog(onResume: () => called = true));
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('calls onMainMenu when main menu tapped', (
      WidgetTester tester,
    ) async {
      var called = false;
      await tester.pumpWidget(
        buildPauseDialog(onMainMenu: () => called = true),
      );
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('is wrapped in Dialog', (WidgetTester tester) async {
      await tester.pumpWidget(buildPauseDialog());
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('has two InkWell buttons', (WidgetTester tester) async {
      await tester.pumpWidget(buildPauseDialog());
      expect(find.byType(InkWell), findsNWidgets(2));
    });
  });
}
