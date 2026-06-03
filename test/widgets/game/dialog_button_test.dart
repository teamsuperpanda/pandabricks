import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/game/dialog_button.dart';

void main() {
  group('DialogButton', () {
    testWidgets('displays icon and label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialogButton(
              icon: Icons.play_arrow_rounded,
              label: 'Resume',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialogButton(
              icon: Icons.home_rounded,
              label: 'Main Menu',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Main Menu'));
      expect(tapped, isTrue);
    });

    testWidgets('is full width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialogButton(
              icon: Icons.refresh,
              label: 'Restart',
              onTap: () {},
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, double.infinity);
    });
  });

  group('DialogButton compact', () {
    testWidgets('displays icon and label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                DialogButton(
                  icon: Icons.close_rounded,
                  label: 'Cancel',
                  onTap: () {},
                  compact: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                DialogButton(
                  icon: Icons.refresh_rounded,
                  label: 'Restart',
                  onTap: () => tapped = true,
                  compact: true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Restart'));
      expect(tapped, isTrue);
    });
  });
}
