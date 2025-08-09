import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/models/mode_model.dart';

void main() {
  group('ModeModel', () {
    test('should correctly identify if it has special blocks', () {
      final modeWithSpecialBlocks = ModeModel(
        name: 'Test Mode',
        initialSpeed: 100,
        speedIncrease: 10,
        scoreThreshold: 1000,
        rowClearScore: 1,
        pandabrickSpawnPercentage: 0,
        specialBlocksSpawnPercentage: 10,
      );
      expect(modeWithSpecialBlocks.hasSpecialBlocks, isTrue);

      final modeWithoutSpecialBlocks = ModeModel(
        name: 'Test Mode',
        initialSpeed: 100,
        speedIncrease: 10,
        scoreThreshold: 1000,
        rowClearScore: 1,
        pandabrickSpawnPercentage: 0,
        specialBlocksSpawnPercentage: 0,
      );
      expect(modeWithoutSpecialBlocks.hasSpecialBlocks, isFalse);
    });

    test('should correctly identify if it has panda blocks', () {
      final modeWithPandaBlocks = ModeModel(
        name: 'Test Mode',
        initialSpeed: 100,
        speedIncrease: 10,
        scoreThreshold: 1000,
        rowClearScore: 1,
        pandabrickSpawnPercentage: 10,
        specialBlocksSpawnPercentage: 0,
      );
      expect(modeWithPandaBlocks.hasPandaBlocks, isTrue);

      final modeWithoutPandaBlocks = ModeModel(
        name: 'Test Mode',
        initialSpeed: 100,
        speedIncrease: 10,
        scoreThreshold: 1000,
        rowClearScore: 1,
        pandabrickSpawnPercentage: 0,
        specialBlocksSpawnPercentage: 0,
      );
      expect(modeWithoutPandaBlocks.hasPandaBlocks, isFalse);
    });

    test('should correctly identify if it has flip feature', () {
      final modeWithFlip = ModeModel(
        name: 'Test Mode',
        initialSpeed: 100,
        speedIncrease: 10,
        scoreThreshold: 1000,
        rowClearScore: 1,
        pandabrickSpawnPercentage: 0,
        specialBlocksSpawnPercentage: 0,
        flipThreshold: 500,
      );
      expect(modeWithFlip.hasFlipFeature, isTrue);

      final modeWithoutFlip = ModeModel(
        name: 'Test Mode',
        initialSpeed: 100,
        speedIncrease: 10,
        scoreThreshold: 1000,
        rowClearScore: 1,
        pandabrickSpawnPercentage: 0,
        specialBlocksSpawnPercentage: 0,
        flipThreshold: null,
      );
      expect(modeWithoutFlip.hasFlipFeature, isFalse);
    });
  });
}
