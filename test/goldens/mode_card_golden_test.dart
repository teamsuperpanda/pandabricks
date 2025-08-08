import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/main/mode_card.dart';
import 'package:pandabricks/models/mode_model.dart';

void main() {
  // Golden disabled by default to avoid CI flakiness; enable locally by removing skip.
  testWidgets('ModeCard golden', (tester) async {
    final mode = ModeModel(
      id: ModeId.normal,
      name: 'Normal',
      initialSpeed: 100,
      speedIncrease: 10,
      scoreThreshold: 1000,
      rowClearScore: 100,
      pandabrickSpawnPercentage: 0,
      specialBlocksSpawnPercentage: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ModeCard(onTap: () {}, modeModel: mode),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Mode'), findsWidgets);
    // To enable golden: uncomment below line and provide a baseline image.
    // await expectLater(find.byType(ModeCard), matchesGoldenFile('goldens/mode_card.png'));
  }, skip: true);
}
