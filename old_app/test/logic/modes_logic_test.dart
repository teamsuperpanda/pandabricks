import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/logic/modes_logic.dart';

void main() {
  group('Modes Tests', () {
    test('should have correct settings for Easy mode', () {
      final easyMode = Modes.easy;

      expect(easyMode.name, 'Easy');
      expect(easyMode.initialSpeed, 100);
      expect(easyMode.speedIncrease, 0);
      expect(easyMode.scoreThreshold, 0);
      expect(easyMode.pandabrickSpawnPercentage, 10);
      expect(easyMode.specialBlocksSpawnPercentage, 0);
    });

    test('should have correct settings for Normal mode', () {
      final normalMode = Modes.normal;

      expect(normalMode.name, 'Normal');
      expect(normalMode.initialSpeed, 100);
      expect(normalMode.speedIncrease, 10);
      expect(normalMode.scoreThreshold, 1000);
      expect(normalMode.pandabrickSpawnPercentage, 5);
      expect(normalMode.specialBlocksSpawnPercentage, 0);
    });

    test('should have correct settings for Bambooblitz mode', () {
      final blitzMode = Modes.bambooblitz;

      expect(blitzMode.name, 'Bamboo Blitz');
      expect(blitzMode.initialSpeed, 100);
      expect(blitzMode.speedIncrease, 30);
      expect(blitzMode.scoreThreshold, 500);
      expect(blitzMode.pandabrickSpawnPercentage, 5);
      expect(blitzMode.specialBlocksSpawnPercentage, 10);
      expect(blitzMode.flipThreshold, 3000);
    });

    test('should get correct mode names', () {
      expect(Modes.getModeName(Modes.easy), 'Easy');
      expect(Modes.getModeName(Modes.normal), 'Normal');
      expect(Modes.getModeName(Modes.bambooblitz), 'Bamboo Blitz');
    });
  });
}
