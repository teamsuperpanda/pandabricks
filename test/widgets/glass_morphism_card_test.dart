import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/home/glass_morphism_card.dart';

void main() {
  group('GlassMorphismCard', () {
    testWidgets('renders child widget correctly', (tester) async {
      const testText = 'Test Content';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassMorphismCard(
              child: Text(testText),
            ),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('applies blur effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassMorphismCard(
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Verify BackdropFilter is present
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('uses ClipRRect for rounded corners', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassMorphismCard(
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('wraps content in Container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassMorphismCard(
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });
  });
}
