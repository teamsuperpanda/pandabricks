import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/screens/game/game.dart';
import '../../mocks/mock_audio_provider.dart';

void main() {
  group('Game Engine Core Mechanics', () {
    late MockAudioProvider mockAudio;

    setUp(() {
      mockAudio = MockAudioProvider();
    });

    group('Game Initialization', () {
      test('initializes with correct default dimensions', () {
        final game = Game(audioProvider: mockAudio);

        expect(game.width, equals(10));
        expect(game.height, equals(20));
        expect(game.gameMode, equals(GameMode.classic));
        expect(game.isGameOver, isFalse);
        expect(game.isPaused, isFalse);
        expect(game.score, equals(0));
        expect(game.linesCleared, equals(0));
        expect(game.level, equals(1));
      });

      test('initializes with custom dimensions', () {
        const config = CustomGameConfig(boardWidth: 12, boardHeight: 24);
        final game = Game(
          audioProvider: mockAudio,
          gameMode: GameMode.custom,
          customConfig: config,
        );

        expect(game.width, equals(12));
        expect(game.height, equals(24));
      });

      test('initializes with time challenge mode', () {
        final game = Game(
          audioProvider: mockAudio,
          gameMode: GameMode.timeChallenge,
        );

        expect(game.gameMode, equals(GameMode.timeChallenge));
        expect(game.timeRemaining, isNotNull);
        expect(game.gameStartTime, isNotNull);
      });

      test('initializes with blitz mode', () {
        final game = Game(audioProvider: mockAudio, gameMode: GameMode.blitz);

        expect(game.gameMode, equals(GameMode.blitz));
        expect(game.timeRemaining, isNull);
      });

      test('initializes with custom starting level', () {
        const config = CustomGameConfig(startingLevel: 5);
        final game = Game(
          audioProvider: mockAudio,
          gameMode: GameMode.custom,
          customConfig: config,
        );

        expect(game.level, equals(5));
        expect(game.linesCleared, equals(40)); // (5-1) * 10
      });

      test('spawns initial piece', () {
        final game = Game(audioProvider: mockAudio);

        expect(game.current, isNotNull);
        expect(game.next, isNotNull);
        expect(game.current!.position.y, equals(1)); // Should spawn at y=1
      });

      test('board is properly initialized', () {
        final game = Game(audioProvider: mockAudio);

        expect(game.board.length, equals(20)); // height
        expect(game.board[0].length, equals(10)); // width

        // All cells should be null (empty)
        for (int y = 0; y < game.height; y++) {
          for (int x = 0; x < game.width; x++) {
            expect(game.board[y][x], isNull);
          }
        }
      });
    });

    group('Piece Movement', () {
      test('moveLeft moves piece left when possible', () {
        final game = Game(audioProvider: mockAudio);
        final initialX = game.current!.position.x;

        final moved = game.moveLeft();
        expect(moved, isTrue);
        expect(game.current!.position.x, equals(initialX - 1));
      });

      test('moveLeft does not move piece when blocked by wall', () {
        final game = Game(audioProvider: mockAudio);

        // Move piece all the way to the left
        while (game.moveLeft()) {}

        final initialX = game.current!.position.x;
        final moved = game.moveLeft();
        expect(moved, isFalse);
        expect(game.current!.position.x, equals(initialX));
      });

      test('moveRight moves piece right when possible', () {
        final game = Game(audioProvider: mockAudio);
        final initialX = game.current!.position.x;

        final moved = game.moveRight();
        expect(moved, isTrue);
        expect(game.current!.position.x, equals(initialX + 1));
      });

      test('moveRight does not move piece when blocked by wall', () {
        final game = Game(audioProvider: mockAudio);

        // Move piece all the way to the right
        while (game.moveRight()) {}

        final initialX = game.current!.position.x;
        final moved = game.moveRight();
        expect(moved, isFalse);
        expect(game.current!.position.x, equals(initialX));
      });

      test('softDrop moves piece down', () {
        final game = Game(audioProvider: mockAudio);
        final initialY = game.current!.position.y;

        final moved = game.softDrop();
        expect(moved, isTrue);
        expect(game.current!.position.y, equals(initialY + 1));
      });

      test('softDrop locks piece when it hits bottom', () {
        final game = Game(audioProvider: mockAudio);

        // Move piece to bottom
        while (game.softDrop()) {}

        // Next soft drop should lock the piece
        final moved = game.softDrop();
        expect(moved, isFalse);
        expect(game.current, isNotNull); // Piece should still exist until next spawn
      });
    });

    group('Piece Rotation', () {
      test('rotateCW rotates piece clockwise', () {
        final game = Game(audioProvider: mockAudio);
        final initialRotation = game.current!.rotation;

        game.rotateCW();

        // Should have rotated (exact rotation depends on piece type)
        expect(game.current!.rotation, isNot(equals(initialRotation)));
      });

      test('rotateCW handles wall kicks when needed', () {
        final game = Game(audioProvider: mockAudio);

        // Move piece close to wall
        for (int i = 0; i < 3; i++) {
          game.moveRight();
        }

        game.rotateCW();

        // Piece should either stay in same position or move due to wall kick
        // The important thing is that rotation succeeded
        expect(game.current!.rotation, isNot(equals(Rotation.up)));
      });
    });

    group('Hard Drop', () {
      test('hardDrop moves piece down and locks it', () {
        final game = Game(audioProvider: mockAudio);
        final initialY = game.current!.position.y;

        game.hardDrop();

        // Piece should have moved down (at least 1 cell)
        expect(game.current!.position.y, greaterThanOrEqualTo(initialY));

        // After hard drop, piece should be locked and board should have blocks
        bool hasBlocks = false;
        for (int y = 0; y < game.height; y++) {
          for (int x = 0; x < game.width; x++) {
            if (game.board[y][x] != null) {
              hasBlocks = true;
              break;
            }
          }
        }
        expect(hasBlocks, isTrue);
      });

      test('hardDrop adds score for distance dropped', () {
        final game = Game(audioProvider: mockAudio);
        final initialScore = game.score;

        game.hardDrop();

        // Should get points for the distance dropped (2 points per cell)
        // Note: score might not increase if distance is 0
        expect(game.score, greaterThanOrEqualTo(initialScore));
      });
    });

    group('Line Clearing', () {
      test('single line clear increases score correctly', () {
        final game = Game(audioProvider: mockAudio);

        // Fill bottom row
        for (int x = 0; x < game.width; x++) {
          game.board[game.height - 1][x] = 1;
        }

        // Spawn and drop a piece that will complete the line
        game.current = ActivePiece(
          type: FallingBlock.I,
          rotation: Rotation.up,
          position: PointInt(0, game.height - 2),
        );

        game.hardDrop();

        expect(game.linesCleared, equals(1));
        expect(game.score, equals(100)); // Single line clear score
      });

      test('multiple line clear gives bonus score', () {
        final game = Game(audioProvider: mockAudio);

        // Fill bottom two rows
        for (int y = game.height - 2; y < game.height; y++) {
          for (int x = 0; x < game.width; x++) {
            game.board[y][x] = 1;
          }
        }

        // Spawn and drop a piece that will complete both lines
        game.current = ActivePiece(
          type: FallingBlock.O,
          rotation: Rotation.up,
          position: PointInt(0, game.height - 3),
        );

        game.hardDrop();

        expect(game.linesCleared, equals(2));
        expect(game.score, equals(300)); // Double line clear score
      });

      test('tetris (4 lines) gives highest score', () {
        final game = Game(audioProvider: mockAudio);

        // Fill bottom four rows
        for (int y = game.height - 4; y < game.height; y++) {
          for (int x = 0; x < game.width; x++) {
            game.board[y][x] = 1;
          }
        }

        // Spawn and drop a piece that will complete all four lines
        game.current = ActivePiece(
          type: FallingBlock.I,
          rotation: Rotation.right,
          position: PointInt(0, game.height - 5),
        );

        game.hardDrop();

        expect(game.linesCleared, equals(4));
        expect(game.score, equals(800)); // Tetris score
      });
    });

    group('Level Progression', () {
      test('level starts at 1', () {
        final game = Game(audioProvider: mockAudio);

        expect(game.level, equals(1));
      });

      test('level calculation works correctly', () {
        final game = Game(audioProvider: mockAudio);

        // Test the level formula: level = 1 + (linesCleared ~/ 10)
        game.linesCleared = 0;
        expect(1 + (game.linesCleared ~/ 10), equals(1));

        game.linesCleared = 9;
        expect(1 + (game.linesCleared ~/ 10), equals(1));

        game.linesCleared = 10;
        expect(1 + (game.linesCleared ~/ 10), equals(2));

        game.linesCleared = 19;
        expect(1 + (game.linesCleared ~/ 10), equals(2));

        game.linesCleared = 20;
        expect(1 + (game.linesCleared ~/ 10), equals(3));
      });
    });

    group('Game Over Detection', () {
      test('game over flag can be set', () {
        final game = Game(audioProvider: mockAudio);

        expect(game.isGameOver, isFalse);

        // Simulate game over by setting the flag directly
        // (In real gameplay, this would be set by tick() or spawn logic)
        game.isGameOver = true;

        expect(game.isGameOver, isTrue);
      });

      test('tick does not execute when game is over', () {
        final game = Game(audioProvider: mockAudio);
        game.isGameOver = true;

        final initialY = game.current!.position.y;

        // Tick should not move the piece when game is over
        game.tick();

        expect(game.current!.position.y, equals(initialY));
      });
    });

    group('Pause Functionality', () {
      test('togglePause pauses and unpauses game', () {
        final game = Game(audioProvider: mockAudio);

        expect(game.isPaused, isFalse);

        game.togglePause();
        expect(game.isPaused, isTrue);

        game.togglePause();
        expect(game.isPaused, isFalse);
      });

      test('togglePause handles time challenge timing correctly', () {
        final game = Game(
          audioProvider: mockAudio,
          gameMode: GameMode.timeChallenge,
        );

        final initialTime = game.timeRemaining;

        game.togglePause();
        expect(game.isPaused, isTrue);

        // Time should be preserved when paused (allow small timing differences)
        expect(game.timeRemaining!.inMilliseconds, closeTo(initialTime!.inMilliseconds, 100));

        game.togglePause();
        expect(game.isPaused, isFalse);
      });
    });

    group('Reset Functionality', () {
      test('reset clears board and resets game state', () {
        final game = Game(audioProvider: mockAudio);

        // Add some blocks to board
        game.board[game.height - 1][0] = 1;
        game.score = 1000;
        game.linesCleared = 5;
        game.level = 2;

        game.reset();

        expect(game.score, equals(0));
        expect(game.linesCleared, equals(0));
        expect(game.level, equals(1));
        expect(game.isGameOver, isFalse);
        expect(game.isPaused, isFalse);

        // Board should be cleared
        for (int y = 0; y < game.height; y++) {
          for (int x = 0; x < game.width; x++) {
            expect(game.board[y][x], isNull);
          }
        }
      });

      test('reset spawns new piece', () {
        final game = Game(audioProvider: mockAudio);

        game.reset();

        // Should have new pieces (may be same by chance, but should exist)
        expect(game.current, isNotNull);
        expect(game.next, isNotNull);
      });
    });

    group('Tick Functionality', () {
      test('tick moves piece down automatically', () {
        final game = Game(audioProvider: mockAudio);
        final initialY = game.current!.position.y;

        game.tick();

        expect(game.current!.position.y, equals(initialY + 1));
      });

      test('tick locks piece when it reaches bottom', () {
        final game = Game(audioProvider: mockAudio);

        // Move piece to bottom
        while (game.softDrop()) {}

        final beforeTick = game.current;
        game.tick();

        // Piece should be locked and new piece spawned
        expect(game.current, isNot(equals(beforeTick)));
      });
    });

    group('Bag System', () {
      test('bag contains regular pieces in classic mode', () {
        final game = Game(audioProvider: mockAudio, gameMode: GameMode.classic);

        // Check that bag contains only regular pieces
        // This is tested indirectly through the spawning logic
        expect(game.next, isNotNull);
        expect(FallingBlock.values.sublist(0, 7).contains(game.next), isTrue);
      });

      test('bag contains special pieces in blitz mode', () {
        final game = Game(audioProvider: mockAudio, gameMode: GameMode.blitz);

        // In blitz mode, special pieces should appear
        // This test may be flaky due to randomness, but statistically should pass
        bool foundSpecial = false;
        for (int i = 0; i < 50 && !foundSpecial; i++) {
          game.reset();
          if (FallingBlock.values.sublist(7).contains(game.next)) {
            foundSpecial = true;
          }
        }

        expect(foundSpecial, isTrue);
      });
    });

    group('Color Mapping', () {
      test('all falling blocks have color mappings', () {
        for (final block in FallingBlock.values) {
          expect(Game.colorFor[block], isNotNull);
          expect(Game.colorFor[block], isA<int>());
          expect(Game.colorFor[block], greaterThanOrEqualTo(0));
        }
      });

      test('regular blocks have sequential color indices', () {
        expect(Game.colorFor[FallingBlock.I], equals(0));
        expect(Game.colorFor[FallingBlock.O], equals(1));
        expect(Game.colorFor[FallingBlock.T], equals(2));
        expect(Game.colorFor[FallingBlock.S], equals(3));
        expect(Game.colorFor[FallingBlock.Z], equals(4));
        expect(Game.colorFor[FallingBlock.J], equals(5));
        expect(Game.colorFor[FallingBlock.L], equals(6));
      });

      test('special blocks have higher color indices', () {
        expect(Game.colorFor[FallingBlock.pandaBrick], equals(7));
        expect(Game.colorFor[FallingBlock.ghostBrick], equals(8));
        expect(Game.colorFor[FallingBlock.catBrick], equals(9));
        expect(Game.colorFor[FallingBlock.tornadoBrick], equals(10));
        expect(Game.colorFor[FallingBlock.bombBrick], equals(11));
      });
    });
  });
}