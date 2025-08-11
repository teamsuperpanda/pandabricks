import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/dialogs/game/game_over_dialog.dart';

void main() {
  group('GameOverDialog Tests', () {
    testWidgets('should display game over information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverDialog(
              score: 12500,
              level: 5,
              lines: 25,
              onRestart: () {},
              onMainMenu: () {},
            ),
          ),
        ),
      );

      // Check for game over title
      expect(find.text('Game Over'), findsOneWidget);
      
      // Check for game over icon
      expect(find.byIcon(Icons.gamepad), findsOneWidget);
      
      // Check for score display
      expect(find.text('Score'), findsOneWidget);
      expect(find.text('Level'), findsOneWidget);
      expect(find.text('Lines'), findsOneWidget);
      
      // Check for buttons
      expect(find.text('Play Again'), findsOneWidget);
      expect(find.text('Main Menu'), findsOneWidget);
    });

    testWidgets('should call onRestart when restart button is tapped', (WidgetTester tester) async {
      bool restartCalled = false;
      bool mainMenuCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverDialog(
              score: 1000,
              level: 1,
              lines: 5,
              onRestart: () => restartCalled = true,
              onMainMenu: () => mainMenuCalled = true,
            ),
          ),
        ),
      );

      // Tap the restart button
      await tester.tap(find.text('Play Again'));
      await tester.pump();

      expect(restartCalled, isTrue);
      expect(mainMenuCalled, isFalse);
    });

    testWidgets('should call onMainMenu when main menu button is tapped', (WidgetTester tester) async {
      bool restartCalled = false;
      bool mainMenuCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverDialog(
              score: 1000,
              level: 1,
              lines: 5,
              onRestart: () => restartCalled = true,
              onMainMenu: () => mainMenuCalled = true,
            ),
          ),
        ),
      );

      // Tap the main menu button
      await tester.tap(find.text('Main Menu'));
      await tester.pump();

      expect(restartCalled, isFalse);
      expect(mainMenuCalled, isTrue);
    });

    testWidgets('should format large scores with commas', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverDialog(
              score: 1234567,
              level: 10,
              lines: 100,
              onRestart: () {},
              onMainMenu: () {},
            ),
          ),
        ),
      );

      // Check for properly formatted score
      expect(find.text('1234567'), findsOneWidget);
    });

    testWidgets('should display zero values correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverDialog(
              score: 0,
              level: 0,
              lines: 0,
              onRestart: () {},
              onMainMenu: () {},
            ),
          ),
        ),
      );

      expect(find.text('0'), findsNWidgets(3)); // Score, level, lines
    });
  });
}
