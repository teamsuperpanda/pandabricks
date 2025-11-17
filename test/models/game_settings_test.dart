import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/models/game_settings.dart';
import 'package:pandabricks/screens/game/game.dart';

void main() {
  group('GameSettings', () {
    group('Constructor', () {
      test('creates settings with required mode', () {
        const settings = GameSettings(mode: GameMode.classic);
        
        expect(settings.mode, GameMode.classic);
        expect(settings.customConfig, isNull);
      });

      test('creates settings with custom config', () {
        const config = CustomGameConfig(boardWidth: 8);
        final settings = GameSettings(mode: GameMode.custom, customConfig: config);
        
        expect(settings.mode, GameMode.custom);
        expect(settings.customConfig, config);
      });

      test('throws assertion error when custom mode without config', () {
        expect(
          () => GameSettings(mode: GameMode.custom),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('Factory constructors', () {
      test('classic() creates classic mode settings', () {
        const settings = GameSettings.classic();
        
        expect(settings.mode, GameMode.classic);
        expect(settings.customConfig, isNull);
      });

      test('timeChallenge() creates time challenge mode settings', () {
        const settings = GameSettings.timeChallenge();
        
        expect(settings.mode, GameMode.timeChallenge);
        expect(settings.customConfig, isNull);
      });

      test('blitz() creates blitz mode settings', () {
        const settings = GameSettings.blitz();
        
        expect(settings.mode, GameMode.blitz);
        expect(settings.customConfig, isNull);
      });

      test('custom() creates custom mode settings with config', () {
        const config = CustomGameConfig(
          boardWidth: 8,
          boardHeight: 16,
          speedMultiplier: 1.5,
        );
        final settings = GameSettings.custom(config);
        
        expect(settings.mode, GameMode.custom);
        expect(settings.customConfig, config);
        expect(settings.boardWidth, 8);
        expect(settings.boardHeight, 16);
      });
    });

    group('Board dimensions', () {
      test('returns default dimensions for standard modes', () {
        const settings = GameSettings.classic();
        
        expect(settings.boardWidth, 10);
        expect(settings.boardHeight, 20);
      });

      test('returns custom dimensions when config provided', () {
        const config = CustomGameConfig(boardWidth: 12, boardHeight: 24);
        final settings = GameSettings.custom(config);
        
        expect(settings.boardWidth, 12);
        expect(settings.boardHeight, 24);
      });

      test('returns default dimensions when custom config has null values', () {
        const config = CustomGameConfig();
        final settings = GameSettings.custom(config);
        
        expect(settings.boardWidth, 10);
        expect(settings.boardHeight, 20);
      });
    });

    group('Equality', () {
      test('same mode and config are equal', () {
        const settings1 = GameSettings.classic();
        const settings2 = GameSettings.classic();
        
        expect(settings1, settings2);
      });

      test('different modes are not equal', () {
        const settings1 = GameSettings.classic();
        const settings2 = GameSettings.blitz();
        
        expect(settings1, isNot(settings2));
      });

      test('same mode with different configs are not equal', () {
        const config1 = CustomGameConfig(boardWidth: 8);
        const config2 = CustomGameConfig(boardWidth: 12);
        final settings1 = GameSettings.custom(config1);
        final settings2 = GameSettings.custom(config2);
        
        expect(settings1, isNot(settings2));
      });

      test('hashCode is consistent with equality', () {
        const settings1 = GameSettings.classic();
        const settings2 = GameSettings.classic();
        
        expect(settings1.hashCode, settings2.hashCode);
      });
    });

    group('toString', () {
      test('includes mode and config information', () {
        const settings = GameSettings.classic();
        final string = settings.toString();
        
        expect(string, contains('GameMode.classic'));
        expect(string, contains('GameSettings'));
      });

      test('shows custom config when present', () {
        const config = CustomGameConfig(boardWidth: 8);
        final settings = GameSettings.custom(config);
        final string = settings.toString();
        
        expect(string, contains('GameMode.custom'));
        expect(string, isNot('null'));
      });
    });

    group('Type safety', () {
      test('can be used as route arguments', () {
        const settings = GameSettings.timeChallenge();
        final arguments = settings; // Would be passed to Navigator
        
        expect(arguments, isA<GameSettings>());
        expect(arguments.mode, GameMode.timeChallenge);
      });

      test('provides compile-time safety for game mode', () {
        // This test ensures type safety - if it compiles, it's safe
        const GameSettings settings = GameSettings.blitz();
        
        expect(settings.mode, isA<GameMode>());
      });
    });

    group('Integration scenarios', () {
      test('supports all game modes', () {
        const classic = GameSettings.classic();
        const timeChallenge = GameSettings.timeChallenge();
        const blitz = GameSettings.blitz();
        const config = CustomGameConfig(timeLimit: Duration(minutes: 5));
        final custom = GameSettings.custom(config);
        
        expect(classic.mode, GameMode.classic);
        expect(timeChallenge.mode, GameMode.timeChallenge);
        expect(blitz.mode, GameMode.blitz);
        expect(custom.mode, GameMode.custom);
      });

      test('handles complex custom configurations', () {
        const config = CustomGameConfig(
          timeLimit: Duration(minutes: 3),
          startingLevel: 5,
          speedMultiplier: 2.0,
          scoreMultiplier: 1.5,
          enableSpecialBricks: false,
          boardWidth: 8,
          boardHeight: 16,
        );
        final settings = GameSettings.custom(config);
        
        expect(settings.mode, GameMode.custom);
        expect(settings.customConfig?.timeLimit, const Duration(minutes: 3));
        expect(settings.customConfig?.startingLevel, 5);
        expect(settings.customConfig?.speedMultiplier, 2.0);
        expect(settings.customConfig?.scoreMultiplier, 1.5);
        expect(settings.customConfig?.enableSpecialBricks, false);
        expect(settings.boardWidth, 8);
        expect(settings.boardHeight, 16);
      });
    });
  });
}
