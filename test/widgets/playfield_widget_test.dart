import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/game/playfield.dart';
import 'package:pandabricks/logic/bricks_logic.dart';
import 'package:pandabricks/logic/game_logic.dart';

void main() {
  testWidgets('Playfield renders grid and active piece', (tester) async {
    final playfield = List.generate(20, (i) => List.filled(10, 0));
    final piece = TetrisPiece(
      BrickShapes.shapes[0].map((r) => List<int>.from(r)).toList(),
      4,
      0,
      0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 600,
            child: Playfield(
              playfield: playfield,
              activePiece: piece,
              flashingRows: const [],
              isSoundEffectsEnabled: false,
              isFlashing: false,
            ),
          ),
        ),
      ),
    );

    // pump a frame to allow AnimatedBuilder to build
    await tester.pump();

  // Expect at least one CustomPaint is present
  expect(find.byType(CustomPaint), findsWidgets);
  });
}
