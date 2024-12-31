import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/logic/modes_logic.dart';

void main() {
  group('Modes Tests', () {
    test('should have correct settings for Easy mode', () {
      final easyMode = Modes.easy;

      expect(easyMode.name, 'Easy');
      expect(easyMode.speed, 100);
      expect(easyMode.speedIncrease, 0);
      expect(easyMode.scoreThreshold, 0);
      expect(easyMode.pandabrickSpawnPercentage, 20);
      expect(easyMode.specialBlocksSpawnPercentage, 0);
    });

    test('should have correct settings for Normal mode', () {
      final normalMode = Modes.normal;

      expect(normalMode.name, 'Normal');
      expect(normalMode.speed, 100);
      expect(normalMode.speedIncrease, 10);
      expect(normalMode.scoreThreshold, 1000);
      expect(normalMode.pandabrickSpawnPercentage, 5);
      expect(normalMode.specialBlocksSpawnPercentage, 0);
    });

    test('should have correct settings for Bambooblitz mode', () {
      final blitzMode = Modes.bambooblitz;

      expect(blitzMode.name, 'Bambooblitz');
      expect(blitzMode.speed, 100);
      expect(blitzMode.speedIncrease, 20);
      expect(blitzMode.scoreThreshold, 500);
      expect(blitzMode.pandabrickSpawnPercentage, 5);
      expect(blitzMode.specialBlocksSpawnPercentage, 10);
      expect(blitzMode.flipThreshold, 3000);
    });

    test('should get correct mode names', () {
      expect(Modes.getModeName(Modes.easy), 'Easy');
      expect(Modes.getModeName(Modes.normal), 'Normal');
      expect(Modes.getModeName(Modes.bambooblitz), 'Bambooblitz');
    });
  });
}
