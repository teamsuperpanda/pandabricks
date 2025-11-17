import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/screens/game/game.dart';
import '../../mocks/mock_audio_provider.dart';

void main() {
  group('Game Advanced Functionality', () {
    late Game game;
    late MockAudioProvider mockAudio;

    setUp(() {
      mockAudio = MockAudioProvider();
      game = Game(audioProvider: mockAudio);
    });

    group('Speed and Timing', () {
      test('currentSpeed returns correct initial speed', () {
        final speed = game.currentSpeed();
        expect(speed.inMilliseconds, Game.baseSpeedMs);
      });

      test('currentSpeed decreases with level', () {
        game.level = 5;
        final speed = game.currentSpeed();
        expect(speed.inMilliseconds, lessThan(Game.baseSpeedMs));
      });

      test('currentSpeed respects minimum speed limit', () {
        game.level = 100; // Very high level
        final speed = game.currentSpeed();
        expect(speed.inMilliseconds, greaterThanOrEqualTo(Game.minSpeedMs));
      });

      test('currentSpeed applies custom speed multiplier', () {
        final customGame = Game(
          audioProvider: mockAudio,
          customConfig: const CustomGameConfig(speedMultiplier: 2.0),
        );
        final normalSpeed = game.currentSpeed();
        final fastSpeed = customGame.currentSpeed();
        expect(fastSpeed.inMilliseconds, lessThan(normalSpeed.inMilliseconds));
      });
    });

    group('Pause Functionality', () {
      test('togglePause changes pause state', () {
        expect(game.isPaused, false);
        game.togglePause();
        expect(game.isPaused, true);
        game.togglePause();
        expect(game.isPaused, false);
      });

      test('tick does not move piece when paused', () {
        game.togglePause();
        final initialY = game.current?.position.y;
        game.tick();
        expect(game.current?.position.y, initialY);
      });

      test('tick does not progress when game is over', () {
        game.isGameOver = true;
        final initialScore = game.score;
        game.tick();
        expect(game.score, initialScore);
      });
    });

    group('Ghost Piece Calculation', () {
      test('ghost piece is rendered on the board', () {
        final ghostCells = game.filledCellsWithGhost().where((c) => c[2] < 0);
        expect(ghostCells, isNotEmpty);
      });

      test('ghost piece is below current piece', () {
        final currentY = game.current?.position.y ?? 0;
        final ghostY = game.filledCellsWithGhost().where((c) => c[2] < 0).map((c) => c[1]).reduce(min);
        expect(ghostY, greaterThanOrEqualTo(currentY));
      });

      test('ghost piece stays same when piece cannot fall', () {
        // Move piece to bottom
        while (game.softDrop()) {}
        final currentY = game.current?.position.y ?? 0;
        final ghostY = game.filledCellsWithGhost().where((c) => c[2] < 0).map((c) => c[1]).reduce(min);
        expect(ghostY, currentY);
      });
    });

    group('Collision Detection', () {
      test('moving into a valid position succeeds', () {
        final initialX = game.current!.position.x;
        game.moveRight();
        expect(game.current!.position.x, initialX + 1);
      });

      test('moving out of bounds fails', () {
        // Move piece to far left
        while(game.moveLeft()) {}
        final initialX = game.current!.position.x;
        game.moveLeft();
        expect(game.current!.position.x, initialX);
      });

      test('moving into an occupied cell fails', () {
        // Fill bottom row
        for (int x = 0; x < game.width; x++) {
          game.board[game.height - 1][x] = 0;
        }
        
        // Move piece to bottom
        while(game.softDrop()) {}

        final initialY = game.current!.position.y;
        game.softDrop();
        expect(game.current!.position.y, initialY);
      });
    });

    group('Board State', () {
      test('board is empty initially', () {
        var isEmpty = true;
        for (var row in game.board) {
          for (var cell in row) {
            if (cell != null) {
              isEmpty = false;
              break;
            }
          }
        }
        expect(isEmpty, true);
      });

      test('board has correct dimensions', () {
        expect(game.board.length, game.height);
        expect(game.board[0].length, game.width);
      });

      test('custom board dimensions work', () {
        final customGame = Game(
          audioProvider: mockAudio,
          width: 12,
          height: 25,
        );
        expect(customGame.board.length, 25);
        expect(customGame.board[0].length, 12);
      });
    });

    group('Scoring System', () {
      test('score starts at 0', () {
        expect(game.score, 0);
      });

      test('hard drop adds score', () {
        final initialScore = game.score;
        game.hardDrop();
        expect(game.score, greaterThan(initialScore));
      });

      test('custom score multiplier increases score', () {
        final normalGame = Game(audioProvider: mockAudio);
        final bonusGame = Game(
          audioProvider: mockAudio,
          customConfig: const CustomGameConfig(scoreMultiplier: 2.0),
        );

        normalGame.hardDrop();
        bonusGame.hardDrop();

        expect(bonusGame.score, greaterThanOrEqualTo(normalGame.score * 1.5));
      });
    });

    group('Level System', () {
      test('level starts at 1 by default', () {
        expect(game.level, 1);
      });

      test('custom starting level works', () {
        final customGame = Game(
          audioProvider: mockAudio,
          customConfig: const CustomGameConfig(startingLevel: 5),
        );
        expect(customGame.level, 5);
      });

      test('linesCleared tracks cleared lines', () {
        expect(game.linesCleared, 0);
      });
    });

    group('Game Modes', () {
      test('classic mode initializes correctly', () {
        final classicGame = Game(
          audioProvider: mockAudio,
          gameMode: GameMode.classic,
        );
        expect(classicGame.gameMode, GameMode.classic);
        expect(classicGame.timeRemaining, isNull);
      });

      test('time challenge mode has time limit', () {
        final timeGame = Game(
          audioProvider: mockAudio,
          gameMode: GameMode.timeChallenge,
        );
        expect(timeGame.gameMode, GameMode.timeChallenge);
        expect(timeGame.timeRemaining, isNotNull);
      });

      test('blitz mode initializes correctly', () {
        final blitzGame = Game(
          audioProvider: mockAudio,
          gameMode: GameMode.blitz,
        );
        expect(blitzGame.gameMode, GameMode.blitz);
      });

      test('custom mode uses config', () {
        const config = CustomGameConfig(
          timeLimit: Duration(minutes: 10),
          startingLevel: 3,
        );
        final customGame = Game(
          audioProvider: mockAudio,
          gameMode: GameMode.custom,
          customConfig: config,
        );
        expect(customGame.gameMode, GameMode.custom);
        expect(customGame.level, 3);
      });
    });

    group('Next Piece', () {
      test('next piece is generated', () {
        expect(game.next, isNotNull);
      });

      test('next piece is one of valid types', () {
        expect(FallingBlock.values, contains(game.next));
      });

      test('spawning sets next as current', () {
        final nextPiece = game.next;
        game.hardDrop(); // This will cause a new piece to spawn
        expect(game.current?.type, nextPiece);
      });
    });

    group('Effects System', () {
      test('effects are empty initially', () {
        expect(game.currentEffects(), isEmpty);
      });

      
    });

    group('Color Mapping', () {
      test('colorFor returns valid color index', () {
        final colorIndex = Game.colorFor[FallingBlock.I];
        expect(colorIndex, isNotNull);
        expect(colorIndex, greaterThanOrEqualTo(0));
      });

      test('all block types have color mappings', () {
        for (var block in FallingBlock.values) {
          final colorIndex = Game.colorFor[block];
          expect(colorIndex, isNotNull);
          expect(colorIndex, greaterThanOrEqualTo(0));
        }
      });
    });

    group('Game State', () {
      test('isGameOver starts as false', () {
        expect(game.isGameOver, false);
      });

      test('game can be reset after game over', () {
        game.isGameOver = true;
        game.score = 1000;
        game.level = 5;

        // Create new game to simulate reset
        final newGame = Game(audioProvider: mockAudio);
        expect(newGame.isGameOver, false);
        expect(newGame.score, 0);
        expect(newGame.level, 1);
      });
    });

    group('Board Manipulation', () {
      test('can fill specific cells', () {
        game.board[0][0] = 5;
        expect(game.board[0][0], 5);
      });

      test('can clear specific cells', () {
        game.board[0][0] = 5;
        game.board[0][0] = null;
        expect(game.board[0][0], isNull);
      });
    });

    group('Piece Shapes', () {
      test('all piece types have shape definitions', () {
        for (var block in [
          FallingBlock.I,
          FallingBlock.O,
          FallingBlock.T,
          FallingBlock.S,
          FallingBlock.Z,
          FallingBlock.J,
          FallingBlock.L,
        ]) {
          // Should not crash when getting shape
          final shape = Game.shapes[block];
          expect(shape, isNotNull);
          expect(shape, isNotEmpty);
        }
      });
    });

    group('Movement Validation', () {
      test('moveLeft within bounds succeeds', () {
        // Move piece to middle
        game.current = game.current!.copyWith(position: const PointInt(5, 0));
        final initialX = game.current!.position.x;
        game.moveLeft();
        expect(game.current!.position.x, initialX - 1);
      });

      test('moveRight within bounds succeeds', () {
        game.current = game.current!.copyWith(position: const PointInt(2, 0));
        final initialX = game.current!.position.x;
        game.moveRight();
        expect(game.current!.position.x, initialX + 1);
      });

      test('rotation cycles through all 4 states', () {
        final rotations = <Rotation>{};
        for (var i = 0; i < 4; i++) {
          rotations.add(game.current!.rotation);
          game.rotateCW();
        }
        expect(rotations.length, 4);
      });
    });
  });
}
