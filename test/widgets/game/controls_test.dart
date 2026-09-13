import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/models/game_input_callbacks.dart';
import 'package:pandabricks/widgets/game/controls.dart';

void _void() {}

void main() {
  group('GameControls', () {
    testWidgets('renders all control buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GameControls(
              callbacks: const GameInputCallbacks(
                onMoveLeft: _void,
                onMoveRight: _void,
                onRotate: _void,
                onSoftDrop: _void,
                onHardDrop: _void,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.rotate_90_degrees_cw_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.vertical_align_bottom_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('calls callbacks when buttons are tapped', (tester) async {
      var rotateCalled = false;
      var softDropCalled = false;
      var hardDropCalled = false;
      final heldDirections = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GameControls(
              callbacks: GameInputCallbacks(
                onMoveLeft: _void,
                onMoveRight: _void,
                onRotate: () => rotateCalled = true,
                onSoftDrop: () => softDropCalled = true,
                onHardDrop: () => hardDropCalled = true,
                onHoldDirection: heldDirections.add,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.rotate_90_degrees_cw_rounded));
      expect(rotateCalled, isTrue);

      await tester.tap(find.byIcon(Icons.arrow_downward_rounded));
      expect(softDropCalled, isTrue);

      await tester.tap(find.byIcon(Icons.vertical_align_bottom_rounded));
      expect(hardDropCalled, isTrue);

      // Left/right buttons drive DAS/ARR via hold-direction: press starts the
      // direction, release cancels it. A quick tap still moves once.
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      expect(heldDirections, contains(-1));

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      expect(heldDirections, contains(1));

      // Releasing cancels the held direction.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.chevron_right_rounded)),
      );
      await gesture.up();
      expect(heldDirections.last, 0);
    });

    testWidgets('has proper structure with columns and rows', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GameControls(
              callbacks: const GameInputCallbacks(
                onMoveLeft: _void,
                onMoveRight: _void,
                onRotate: _void,
                onSoftDrop: _void,
                onHardDrop: _void,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Row), findsAtLeastNWidgets(2));
    });
  });
}
