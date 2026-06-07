import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/home/glass_icon_button.dart';

void main() {
  group('GlassIconButton', () {
    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassIconButton(
              icon: Icons.help_outline_rounded,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    });

    testWidgets('renders with tooltip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassIconButton(
              icon: Icons.language_rounded,
              onTap: () {},
              tooltip: 'Language',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.language_rounded), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassIconButton(
              icon: Icons.help_outline_rounded,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.help_outline_rounded));
      expect(tapped, isTrue);
    });
  });
}
