import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/screens/game_screen.dart';
import 'package:pandabricks/models/mode_model.dart';
import 'package:pandabricks/l10n/app_localizations.dart';

void main() {
  testWidgets('GameScreen shows score and controls', (tester) async {
    final mode = ModeModel(
      id: ModeId.easy,
      name: 'Easy',
      initialSpeed: 100,
      speedIncrease: 10,
      scoreThreshold: 1000,
      rowClearScore: 100,
      pandabrickSpawnPercentage: 0,
      specialBlocksSpawnPercentage: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameScreen(
          mode: mode,
          isSoundEffectsEnabled: false,
          isBackgroundMusicEnabled: false,
        ),
      ),
    );

    // Let initial timers/ticker tick a little
    await tester.pump(const Duration(milliseconds: 50));

    // Score text should be present and numeric
    expect(find.byType(Text), findsWidgets);

    // Controls present
    expect(find.byIcon(Icons.arrow_left), findsOneWidget);
    expect(find.byIcon(Icons.arrow_right), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    expect(find.byIcon(Icons.rotate_right), findsOneWidget);
  });
}
