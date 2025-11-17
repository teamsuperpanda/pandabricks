import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/screens/game/game.dart';

void main() {
  group('CustomGameConfig.copyWith', () {
    test('allows clearing the time limit by passing null', () {
      const config = CustomGameConfig(timeLimit: Duration(minutes: 3));

      final updated = config.copyWith(timeLimit: null);

      expect(updated.timeLimit, isNull);
    });

    test('preserves the existing time limit when not specified', () {
      const config = CustomGameConfig(timeLimit: Duration(minutes: 5));

      final updated = config.copyWith(startingLevel: 5);

      expect(updated.timeLimit, equals(const Duration(minutes: 5)));
      expect(updated.startingLevel, equals(5));
    });
  });
}
