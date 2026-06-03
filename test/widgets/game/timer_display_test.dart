import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/game/timer_display.dart';

void main() {
  group('TimerDisplay', () {
    testWidgets('displays time in MM:SS format', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerDisplay(
              timeRemaining: Duration(minutes: 5, seconds: 30),
            ),
          ),
        ),
      );

      expect(find.text('05:30'), findsOneWidget);
    });

    testWidgets('displays zero-padded minutes and seconds', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerDisplay(timeRemaining: Duration(minutes: 1, seconds: 5)),
          ),
        ),
      );

      expect(find.text('01:05'), findsOneWidget);
    });

    testWidgets('shows timer icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerDisplay(timeRemaining: Duration(minutes: 3)),
          ),
        ),
      );

      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('displays zero time correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerDisplay(timeRemaining: Duration.zero),
          ),
        ),
      );

      expect(find.text('00:00'), findsOneWidget);
    });
  });
}
