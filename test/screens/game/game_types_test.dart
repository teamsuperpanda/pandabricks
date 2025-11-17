import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/screens/game/game.dart';

void main() {
  group('GameMode', () {
    test('has correct enum values', () {
      expect(GameMode.values.length, 4);
      expect(GameMode.values, contains(GameMode.classic));
      expect(GameMode.values, contains(GameMode.timeChallenge));
      expect(GameMode.values, contains(GameMode.blitz));
      expect(GameMode.values, contains(GameMode.custom));
    });
  });

  group('Rotation', () {
    test('has correct enum values', () {
      expect(Rotation.values.length, 4);
      expect(Rotation.values, contains(Rotation.up));
      expect(Rotation.values, contains(Rotation.right));
      expect(Rotation.values, contains(Rotation.down));
      expect(Rotation.values, contains(Rotation.left));
    });
  });

  group('FallingBlock', () {
    test('has standard tetromino types', () {
      expect(FallingBlock.values, contains(FallingBlock.I));
      expect(FallingBlock.values, contains(FallingBlock.O));
      expect(FallingBlock.values, contains(FallingBlock.T));
      expect(FallingBlock.values, contains(FallingBlock.S));
      expect(FallingBlock.values, contains(FallingBlock.Z));
      expect(FallingBlock.values, contains(FallingBlock.J));
      expect(FallingBlock.values, contains(FallingBlock.L));
    });

    test('has special brick types', () {
      expect(FallingBlock.values, contains(FallingBlock.pandaBrick));
      expect(FallingBlock.values, contains(FallingBlock.ghostBrick));
      expect(FallingBlock.values, contains(FallingBlock.catBrick));
      expect(FallingBlock.values, contains(FallingBlock.tornadoBrick));
      expect(FallingBlock.values, contains(FallingBlock.bombBrick));
    });
  });

  group('PointInt', () {
    test('creates point with x and y coordinates', () {
      const point = PointInt(5, 10);
      expect(point.x, 5);
      expect(point.y, 10);
    });

    test('adds two points correctly', () {
      const point1 = PointInt(3, 4);
      const point2 = PointInt(2, 5);
      final result = point1 + point2;
      
      expect(result.x, 5);
      expect(result.y, 9);
    });

    test('handles negative coordinates', () {
      const point1 = PointInt(5, 3);
      const point2 = PointInt(-2, -1);
      final result = point1 + point2;
      
      expect(result.x, 3);
      expect(result.y, 2);
    });
  });

  group('ActivePiece', () {
    test('creates active piece with required fields', () {
      const piece = ActivePiece(
        type: FallingBlock.T,
        rotation: Rotation.up,
        position: PointInt(5, 10),
      );

      expect(piece.type, FallingBlock.T);
      expect(piece.rotation, Rotation.up);
      expect(piece.position.x, 5);
      expect(piece.position.y, 10);
      expect(piece.isSpecialBlock, false);
      expect(piece.lastMoveY, -1);
    });

    test('creates special block piece', () {
      const piece = ActivePiece(
        type: FallingBlock.pandaBrick,
        rotation: Rotation.up,
        position: PointInt(0, 0),
        isSpecialBlock: true,
      );

      expect(piece.isSpecialBlock, true);
    });

    test('copyWith updates only specified fields', () {
      const original = ActivePiece(
        type: FallingBlock.I,
        rotation: Rotation.up,
        position: PointInt(5, 10),
      );

      final updated = original.copyWith(
        rotation: Rotation.right,
        position: const PointInt(6, 10),
      );

      expect(updated.type, FallingBlock.I);
      expect(updated.rotation, Rotation.right);
      expect(updated.position.x, 6);
      expect(updated.position.y, 10);
    });

    test('copyWith preserves special block status', () {
      const original = ActivePiece(
        type: FallingBlock.ghostBrick,
        rotation: Rotation.up,
        position: PointInt(0, 0),
        isSpecialBlock: true,
      );

      final updated = original.copyWith(position: const PointInt(1, 0));

      expect(updated.isSpecialBlock, true);
    });
  });

  group('Game colorFor map', () {
    test('maps all standard blocks to colors', () {
      expect(Game.colorFor[FallingBlock.I], 0);
      expect(Game.colorFor[FallingBlock.O], 1);
      expect(Game.colorFor[FallingBlock.T], 2);
      expect(Game.colorFor[FallingBlock.S], 3);
      expect(Game.colorFor[FallingBlock.Z], 4);
      expect(Game.colorFor[FallingBlock.J], 5);
      expect(Game.colorFor[FallingBlock.L], 6);
    });

    test('maps all special blocks to colors', () {
      expect(Game.colorFor[FallingBlock.pandaBrick], 7);
      expect(Game.colorFor[FallingBlock.ghostBrick], 8);
      expect(Game.colorFor[FallingBlock.catBrick], 9);
      expect(Game.colorFor[FallingBlock.tornadoBrick], 10);
      expect(Game.colorFor[FallingBlock.bombBrick], 11);
    });
  });

  group('Game constants', () {
    test('has correct timing constants', () {
      expect(Game.effectDurationMs, 500);
      expect(Game.baseSpeedMs, 800);
      expect(Game.speedLevelDecrement, 50);
      expect(Game.minSpeedMs, 50);
      expect(Game.maxSpeedMs, 2000);
    });

    test('has correct scoring constants', () {
      expect(Game.lineClearScores.length, 5);
      expect(Game.lineClearScores[0], 0);
      expect(Game.lineClearScores[1], 100);
      expect(Game.lineClearScores[2], 300);
      expect(Game.lineClearScores[3], 500);
      expect(Game.lineClearScores[4], 800);
      expect(Game.pandaBrickBonus, 200);
      expect(Game.bombBrickBonus, 500);
    });
  });
}
