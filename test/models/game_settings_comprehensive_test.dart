import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/models/game_settings.dart';
import 'package:pandabricks/screens/game/game.dart';

void main() {
  group('GameSettings', () {
    test('classic mode creates correct settings', () {
      const settings = GameSettings.classic();
      
      expect(settings.mode, GameMode.classic);
      expect(settings.customConfig, isNull);
      expect(settings.boardWidth, 10);
      expect(settings.boardHeight, 20);
    });

    test('time challenge mode creates correct settings', () {
      const settings = GameSettings.timeChallenge();
      
      expect(settings.mode, GameMode.timeChallenge);
      expect(settings.customConfig, isNull);
      expect(settings.boardWidth, 10);
      expect(settings.boardHeight, 20);
    });

    test('blitz mode creates correct settings', () {
      const settings = GameSettings.blitz();
      
      expect(settings.mode, GameMode.blitz);
      expect(settings.customConfig, isNull);
      expect(settings.boardWidth, 10);
      expect(settings.boardHeight, 20);
    });

    test('custom mode requires config', () {
      const config = CustomGameConfig(
        timeLimit: Duration(minutes: 5),
        startingLevel: 3,
      );
      final settings = GameSettings.custom(config);
      
      expect(settings.mode, GameMode.custom);
      expect(settings.customConfig, config);
      expect(settings.boardWidth, 10);
      expect(settings.boardHeight, 20);
    });

    test('custom board dimensions work correctly', () {
      const config = CustomGameConfig(
        boardWidth: 12,
        boardHeight: 25,
      );
      final settings = GameSettings.custom(config);
      
      expect(settings.boardWidth, 12);
      expect(settings.boardHeight, 25);
    });

    test('equality works for same classic modes', () {
      const settings1 = GameSettings.classic();
      const settings2 = GameSettings.classic();
      
      expect(settings1, equals(settings2));
    });

    test('equality fails for different modes', () {
      const settings1 = GameSettings.classic();
      const settings2 = GameSettings.blitz();
      
      expect(settings1, isNot(equals(settings2)));
    });

    test('hashCode is consistent', () {
      const settings = GameSettings.classic();
      final hash1 = settings.hashCode;
      final hash2 = settings.hashCode;
      
      expect(hash1, equals(hash2));
    });

    test('equality works with custom configs', () {
      const config = CustomGameConfig(startingLevel: 5);
      final settings1 = GameSettings.custom(config);
      final settings2 = GameSettings.custom(config);
      
      expect(settings1, equals(settings2));
    });
  });
}
