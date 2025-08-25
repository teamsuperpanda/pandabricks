import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/screens/game/game.dart';
import '../../mocks/mock_audio_provider.dart';

void main() {
  group('Special Bricks and Sparkle Effects', () {
    late MockAudioProvider mockAudio;

    setUp(() {
      mockAudio = MockAudioProvider();
    });

    test('Panda clears its column and triggers column effects', () {
      final game = Game(audioProvider: mockAudio, gameMode: GameMode.blitz);

      // Fill column 3 with dummy values
      for (int y = 0; y < game.height; y++) {
        game.board[y][3] = 2;
      }

      // Spawn a panda at column 3 on the bottom so it locks immediately
      game.current = ActivePiece(
        type: FallingBlock.pandaBrick,
        rotation: Rotation.up,
        position: PointInt(3, game.height - 1),
        isSpecialBlock: true,
      );

      game.hardDrop();

      // Column should be cleared
      for (int y = 0; y < game.height; y++) {
        expect(game.board[y][3], isNull);
      }

      // Effects should contain column (type == 0) entries for x == 3
      final effects = game.currentEffects().toList();
      expect(effects.where((e) => e[2] == 0 && e[0] == 3), isNotEmpty);
    });

    test('Bomb clears its row and column and triggers both effects', () {
      final game = Game(audioProvider: mockAudio, gameMode: GameMode.blitz);

      final targetX = 4;
      final targetY = game.height - 1;

      // Fill the target row and column with dummy values
      for (int x = 0; x < game.width; x++) {
        game.board[targetY][x] = 3;
      }
      for (int y = 0; y < game.height; y++) {
        game.board[y][targetX] = 3;
      }

      game.current = ActivePiece(
        type: FallingBlock.bombBrick,
        rotation: Rotation.up,
        position: PointInt(targetX, targetY),
        isSpecialBlock: true,
      );

      game.hardDrop();

      // Row should be cleared
      for (int x = 0; x < game.width; x++) {
        expect(game.board[targetY][x], isNull);
      }

      // Column should be cleared
      for (int y = 0; y < game.height; y++) {
        expect(game.board[y][targetX], isNull);
      }

      final effects = game.currentEffects().toList();
      // Look for at least one column effect for targetX and one row effect for targetY
      expect(effects.where((e) => e[2] == 0 && e[0] == targetX), isNotEmpty);
      expect(effects.where((e) => e[2] == 1 && e[1] == targetY), isNotEmpty);
    });

    test('Ghost brick reverses left/right controls', () {
      final game = Game(audioProvider: mockAudio, gameMode: GameMode.blitz);

      // Place ghost in middle
      game.current = ActivePiece(
        type: FallingBlock.ghostBrick,
        rotation: Rotation.up,
        position: PointInt(5, 5),
        isSpecialBlock: true,
      );

      // moveLeft should actually move it right by +1
      final moved = game.moveLeft();
      expect(moved, isTrue);
      expect(game.current!.position.x, equals(6));

      // moveRight should move it left by -1
      final moved2 = game.moveRight();
      expect(moved2, isTrue);
      expect(game.current!.position.x, equals(5));
    });

    test('Cat brick updates lastMoveY on tick (autonomous movement bookkeeping)', () {
      final game = Game(audioProvider: mockAudio, gameMode: GameMode.blitz);

      game.current = ActivePiece(
        type: FallingBlock.catBrick,
        rotation: Rotation.up,
        position: PointInt(5, 1),
        isSpecialBlock: true,
        lastMoveY: -1,
      );

      game.tick();

      // After tick, lastMoveY should be set to the current y
      expect(game.current!.lastMoveY, equals(1));
    });

    test('Tornado auto-rotates on tick', () {
      final game = Game(audioProvider: mockAudio, gameMode: GameMode.blitz);

      game.current = ActivePiece(
        type: FallingBlock.tornadoBrick,
        rotation: Rotation.up,
        position: PointInt(5, 1),
        isSpecialBlock: true,
        lastMoveY: -1,
      );

      game.tick();

      // Tornado should have rotated clockwise once
      expect(game.current!.rotation, equals(Rotation.right));
    });

    test('Regular line clear triggers sparkle row effects', () {
      final game = Game(audioProvider: mockAudio, gameMode: GameMode.classic);

      final targetY = game.height - 1;

      // Fill bottom row completely to force a line clear
      for (int x = 0; x < game.width; x++) {
        game.board[targetY][x] = 4;
      }

      // Force a line clear by calling tick() which will process the full line
      // First make sure there's no current piece to avoid complications
      game.current = null;
      
      // Manually trigger line clearing by placing any piece and locking it
      // Place an O piece above the filled line
      game.current = ActivePiece(
        type: FallingBlock.O,
        rotation: Rotation.up,
        position: PointInt(1, targetY - 2),
        isSpecialBlock: false,
      );

      // Lock the piece to trigger line clearing
      game.hardDrop();

      // The bottom row should have been cleared
      final hasNullsInBottomRow = game.board[targetY].any((cell) => cell == null);
      expect(hasNullsInBottomRow, isTrue, 
        reason: 'Bottom row should have been cleared');

      // Effects should contain row clear sparkles
      final effects = game.currentEffects().toList();
      expect(effects.where((e) => e[2] == 1), isNotEmpty, 
        reason: 'Should have row clear effects after line clear');
    });
  });
}
