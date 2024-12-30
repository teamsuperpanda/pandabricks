import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/logic/modes_logic.dart';

void main() {
  group('Modes', () {
    test('game modes are correctly configured', () {
      // Test Easy mode configuration
      expect(Modes.easy.name, 'Easy');
      expect(Modes.easy.speed, 100);
      expect(Modes.easy.speedIncrease, 0);
      expect(Modes.easy.pandabrickSpawnPercentage, 20);

      // Test Normal mode configuration
      expect(Modes.normal.name, 'Normal');
      expect(Modes.normal.speedIncrease, 5);
      expect(Modes.normal.scoreThreshold, 2000);
      expect(Modes.normal.pandabrickSpawnPercentage, 5);

      // Test BambooBlitz mode configuration
      expect(Modes.bambooblitz.name, 'Bambooblitz');
      expect(Modes.bambooblitz.speedIncrease, 10);
      expect(Modes.bambooblitz.scoreThreshold, 1500);
      expect(Modes.bambooblitz.rowClearScore, 2);
    });

    test('getModeName returns correct mode names', () {
      expect(Modes.getModeName(Modes.easy), 'Easy');
      expect(Modes.getModeName(Modes.normal), 'Normal');
      expect(Modes.getModeName(Modes.bambooblitz), 'Bambooblitz');
    });
  });
}
