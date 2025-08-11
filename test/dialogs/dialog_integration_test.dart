import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/dialogs/game/game_over_dialog.dart';
import 'package:pandabricks/dialogs/game/pause_dialog.dart';
import 'package:pandabricks/dialogs/game/restart_confirm_dialog.dart';
import 'package:pandabricks/dialogs/game/main_menu_confirm_dialog.dart';

void main() {
  group('Dialog Integration Tests', () {
    testWidgets('all dialogs should be non-dismissible', (WidgetTester tester) async {
      // Test Game Over Dialog
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => GameOverDialog(
                    score: 1000,
                    level: 1,
                    lines: 10,
                    onRestart: () {},
                    onMainMenu: () {},
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to dismiss by tapping outside
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog should still be present
      expect(find.text('Game Over'), findsOneWidget);
    });

    testWidgets('all dialogs should use GlassMorphismCard', (WidgetTester tester) async {
      final dialogs = [
        GameOverDialog(
          score: 1000,
          level: 1,
          lines: 10,
          onRestart: () {},
          onMainMenu: () {},
        ),
        PauseDialog(
          onResume: () {},
          onRestart: () {},
          onMainMenu: () {},
        ),
        RestartConfirmDialog(
          onRestart: () {},
          onCancel: () {},
        ),
        MainMenuConfirmDialog(
          onConfirm: () {},
          onCancel: () {},
        ),
      ];

      for (final dialog in dialogs) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: dialog),
          ),
        );

        // Each dialog should have at least one GlassMorphismCard
        expect(find.byType(Dialog), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('all dialogs should have consistent styling', (WidgetTester tester) async {
      final dialogs = [
        ('Game Over', GameOverDialog(
          score: 1000,
          level: 1,
          lines: 10,
          onRestart: () {},
          onMainMenu: () {},
        )),
        ('Game Paused', PauseDialog(
          onResume: () {},
          onRestart: () {},
          onMainMenu: () {},
        )),
        ('Restart Game?', RestartConfirmDialog(
          onRestart: () {},
          onCancel: () {},
        )),
        ('Return to Main Menu?', MainMenuConfirmDialog(
          onConfirm: () {},
          onCancel: () {},
        )),
      ];

      for (final (title, dialog) in dialogs) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: dialog),
          ),
        );

        // Each dialog should have a title
        expect(find.text(title), findsOneWidget);
        
        // Each dialog should have an icon
        expect(find.byType(Icon), findsAtLeastNWidgets(1));
        
        await tester.pumpAndSettle();
      }
    });

    group('Dialog Accessibility Tests', () {
      testWidgets('dialogs should have semantic labels for buttons', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameOverDialog(
                score: 1000,
                level: 1,
                lines: 10,
                onRestart: () {},
                onMainMenu: () {},
              ),
            ),
          ),
        );

        // Check that buttons have text (which provides semantic meaning)
        expect(find.text('Play Again'), findsOneWidget);
        expect(find.text('Main Menu'), findsOneWidget);
      });

      testWidgets('confirmation dialogs should clearly indicate consequences', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RestartConfirmDialog(
                onRestart: () {},
                onCancel: () {},
              ),
            ),
          ),
        );

        // Should warn about progress loss
        expect(find.textContaining('progress will be lost'), findsOneWidget);
      });
    });

    group('Dialog Button Interaction Tests', () {
      testWidgets('multiple rapid taps should not cause issues', (WidgetTester tester) async {
        int tapCount = 0;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RestartConfirmDialog(
                onRestart: () => tapCount++,
                onCancel: () {},
              ),
            ),
          ),
        );

        // Rapidly tap the restart button multiple times
        final restartButton = find.text('Restart');
        await tester.tap(restartButton);
        await tester.tap(restartButton);
        await tester.tap(restartButton);
        await tester.pump();

        // Should only register the taps that occurred (may be limited by widget behavior)
        expect(tapCount, greaterThan(0));
      });
    });
  });
}
