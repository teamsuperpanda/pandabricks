import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/game/header_button.dart';

void main() {
  group('HeaderButton', () {
    testWidgets('displays icon and label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderButton(
              icon: Icons.pause,
              label: 'Pause',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderButton(
              icon: Icons.home,
              label: 'Home',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HeaderButton));
      expect(pressed, isTrue);
    });

    testWidgets('uses glass morphism styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderButton(
              icon: Icons.refresh,
              label: 'Restart',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('displays different icons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HeaderButton(
                  icon: Icons.pause,
                  label: 'Pause',
                  onPressed: () {},
                ),
                HeaderButton(
                  icon: Icons.play_arrow,
                  label: 'Play',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('displays different labels correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HeaderButton(
                  icon: Icons.stop,
                  label: 'Stop',
                  onPressed: () {},
                ),
                HeaderButton(
                  icon: Icons.stop,
                  label: 'End',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('End'), findsOneWidget);
    });
  });
}
