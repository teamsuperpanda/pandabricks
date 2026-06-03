import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/home/mode_card.dart';

void main() {
  group('ModeCard', () {
    testWidgets('displays title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModeCard(
              title: 'Classic Mode',
              subtitle: 'Classic falling blocks.',
              icon: Icons.grid_view_rounded,
            ),
          ),
        ),
      );

      expect(find.text('Classic Mode'), findsOneWidget);
      expect(find.text('Classic falling blocks.'), findsOneWidget);
    });

    testWidgets('displays icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModeCard(
              title: 'Time Challenge',
              subtitle: 'Beat the clock.',
              icon: Icons.timer_rounded,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.timer_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModeCard(
              title: 'Classic',
              subtitle: 'Description',
              icon: Icons.grid_view_rounded,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Classic'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
