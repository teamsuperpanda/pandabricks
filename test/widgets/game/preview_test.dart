import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/screens/game/game.dart' as game;
import 'package:pandabricks/widgets/game/preview.dart';

void main() {
  group('PiecePreview', () {
    testWidgets('renders with a piece', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PiecePreview(next: game.FallingBlock.T),
          ),
        ),
      );

      expect(find.byType(PiecePreview), findsOneWidget);
    });

    testWidgets('renders with null piece', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PiecePreview(next: null),
          ),
        ),
      );

      expect(find.byType(PiecePreview), findsOneWidget);
    });

    testWidgets('renders special block piece', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PiecePreview(next: game.FallingBlock.PANDA),
          ),
        ),
      );

      expect(find.byType(PiecePreview), findsOneWidget);
    });

    testWidgets('renders multiple piece types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Wrap(
                children: const [
                  PiecePreview(next: game.FallingBlock.I),
                  PiecePreview(next: game.FallingBlock.O),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PiecePreview), findsNWidgets(2));
    });
  });
}
