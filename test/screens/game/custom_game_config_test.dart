import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/screens/game/game.dart';

void main() {
  group('CustomGameConfig', () {
    group('copyWith', () {
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

      test('copyWith updates every field independently', () {
        const original = CustomGameConfig(
          timeLimit: Duration(minutes: 3),
          startingLevel: 1,
          speedMultiplier: 1.0,
          scoreMultiplier: 1.0,
          enableSpecialBricks: true,
          boardWidth: 10,
          boardHeight: 20,
        );

        final updated = original.copyWith(
          startingLevel: 5,
          speedMultiplier: 2.0,
          scoreMultiplier: 1.5,
          enableSpecialBricks: false,
          boardWidth: 12,
          boardHeight: 24,
        );

        expect(updated.timeLimit, const Duration(minutes: 3)); // unchanged
        expect(updated.startingLevel, 5);
        expect(updated.speedMultiplier, 2.0);
        expect(updated.scoreMultiplier, 1.5);
        expect(updated.enableSpecialBricks, false);
        expect(updated.boardWidth, 12);
        expect(updated.boardHeight, 24);
      });

      test('copyWith with no arguments returns equivalent config', () {
        const original = CustomGameConfig(
          timeLimit: Duration(seconds: 90),
          startingLevel: 3,
          speedMultiplier: 1.5,
          scoreMultiplier: 2.0,
          enableSpecialBricks: false,
          boardWidth: 8,
          boardHeight: 18,
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('Equality (==)', () {
      test('identical configs are equal', () {
        const a = CustomGameConfig(
          startingLevel: 3,
          speedMultiplier: 1.5,
          boardWidth: 12,
          boardHeight: 22,
        );
        const b = CustomGameConfig(
          startingLevel: 3,
          speedMultiplier: 1.5,
          boardWidth: 12,
          boardHeight: 22,
        );

        expect(a, equals(b));
      });

      test('default configs are equal', () {
        const a = CustomGameConfig();
        const b = CustomGameConfig();
        expect(a, equals(b));
      });

      test('configs with different startingLevel are not equal', () {
        const a = CustomGameConfig(startingLevel: 1);
        const b = CustomGameConfig(startingLevel: 5);
        expect(a, isNot(equals(b)));
      });

      test('configs with different boardWidth are not equal', () {
        const a = CustomGameConfig(boardWidth: 10);
        const b = CustomGameConfig(boardWidth: 12);
        expect(a, isNot(equals(b)));
      });

      test('configs with different timeLimit are not equal', () {
        const a = CustomGameConfig(timeLimit: Duration(minutes: 3));
        const b = CustomGameConfig(timeLimit: Duration(minutes: 5));
        expect(a, isNot(equals(b)));
      });

      test('config with null timeLimit vs set timeLimit are not equal', () {
        const a = CustomGameConfig();
        const b = CustomGameConfig(timeLimit: Duration(minutes: 5));
        expect(a, isNot(equals(b)));
      });

      test('identical object equals itself', () {
        const config = CustomGameConfig(startingLevel: 2);
        expect(config, equals(config));
      });
    });

    group('hashCode', () {
      test('equal configs have the same hashCode', () {
        const a = CustomGameConfig(startingLevel: 3, boardWidth: 12);
        const b = CustomGameConfig(startingLevel: 3, boardWidth: 12);
        expect(a.hashCode, equals(b.hashCode));
      });

      test('hashCode is stable across multiple calls', () {
        const config = CustomGameConfig(speedMultiplier: 2.0);
        final hash1 = config.hashCode;
        final hash2 = config.hashCode;
        expect(hash1, equals(hash2));
      });
    });

    group('toString', () {
      test('includes all field values', () {
        const config = CustomGameConfig(
          startingLevel: 3,
          speedMultiplier: 1.5,
          boardWidth: 8,
          boardHeight: 18,
          enableSpecialBricks: false,
        );
        final str = config.toString();

        expect(str, contains('startingLevel'));
        expect(str, contains('3'));
        expect(str, contains('speedMultiplier'));
        expect(str, contains('1.5'));
        expect(str, contains('boardWidth'));
        expect(str, contains('8'));
        expect(str, contains('boardHeight'));
        expect(str, contains('18'));
        expect(str, contains('enableSpecialBricks'));
        expect(str, contains('false'));
        expect(str, contains('CustomGameConfig'));
      });

      test('includes timeLimit when set', () {
        const config = CustomGameConfig(timeLimit: Duration(minutes: 5));
        final str = config.toString();
        expect(str, contains('timeLimit'));
        expect(str, contains('0:05:00.000000'));
      });
    });

    group('Default values', () {
      test('default startingLevel is 1', () {
        const config = CustomGameConfig();
        expect(config.startingLevel, 1);
      });

      test('default speedMultiplier is 1.0', () {
        const config = CustomGameConfig();
        expect(config.speedMultiplier, 1.0);
      });

      test('default scoreMultiplier is 1.0', () {
        const config = CustomGameConfig();
        expect(config.scoreMultiplier, 1.0);
      });

      test('default enableSpecialBricks is true', () {
        const config = CustomGameConfig();
        expect(config.enableSpecialBricks, isTrue);
      });

      test('default boardWidth is 10', () {
        const config = CustomGameConfig();
        expect(config.boardWidth, 10);
      });

      test('default boardHeight is 20', () {
        const config = CustomGameConfig();
        expect(config.boardHeight, 20);
      });

      test('default timeLimit is null', () {
        const config = CustomGameConfig();
        expect(config.timeLimit, isNull);
      });
    });
  });
}
