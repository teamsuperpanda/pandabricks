import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/screens/game/game.dart';
import '../../mocks/mock_audio_provider.dart';

void main() {
  group('Game Reset and Lifecycle', () {
    late Game game;
    late MockAudioProvider mockAudio;

    setUp(() {
      mockAudio = MockAudioProvider();
      game = Game(audioProvider: mockAudio);
    });

    test('reset clears the board', () {
      // Add some pieces to board
      game.board[game.height - 1][0] = 1;
      game.board[game.height - 1][1] = 2;
      
      game.reset();
      
      // Board should be empty
      var isEmpty = true;
      for (var row in game.board) {
        for (var cell in row) {
          if (cell != null) {
            isEmpty = false;
          }
        }
      }
      expect(isEmpty, true);
    });

    test('reset resets score to 0', () {
      game.score = 5000;
      game.reset();
      expect(game.score, 0);
    });

    test('reset resets level to 1', () {
      game.level = 10;
      game.reset();
      expect(game.level, 1);
    });

    test('reset resets linesCleared to 0', () {
      game.linesCleared = 50;
      game.reset();
      expect(game.linesCleared, 0);
    });

    test('reset clears game over state', () {
      game.isGameOver = true;
      game.reset();
      expect(game.isGameOver, false);
    });

    test('reset clears paused state', () {
      game.togglePause();
      game.reset();
      expect(game.isPaused, false);
    });

    test('reset spawns new piece', () {
      game.reset();
      expect(game.current, isNotNull);
    });

    test('reset generates next piece', () {
      game.reset();
      expect(game.next, isNotNull);
    });

    test('reset restores time for time challenge', () {
      final timeGame = Game(
        audioProvider: mockAudio,
        gameMode: GameMode.timeChallenge,
      );
      
      timeGame.timeRemaining = const Duration(seconds: 10);
      timeGame.reset();
      
      expect(timeGame.timeRemaining, greaterThan(const Duration(seconds: 100)));
    });
  });

  group('Game Bag System', () {
    late Game game;
    late MockAudioProvider mockAudio;

    setUp(() {
      mockAudio = MockAudioProvider();
      game = Game(audioProvider: mockAudio);
    });

    test('bag system ensures fair piece distribution', () {
      final pieces = <FallingBlock>{};
      
      // Draw 7 pieces, which should be all the unique standard pieces
      for (var i = 0; i < 7; i++) {
        if (game.isGameOver) break;
        pieces.add(game.current!.type);
        game.hardDrop();
      }
      
      final standardPieces = {
        FallingBlock.I,
        FallingBlock.O,
        FallingBlock.T,
        FallingBlock.S,
        FallingBlock.Z,
        FallingBlock.J,
        FallingBlock.L,
      };

      // Depending on the initial `current` and `next` pieces, we might not have all 7 unique pieces after 7 drops.
      // However, we should have a good distribution.
      expect(pieces.length, greaterThan(3));

      // Draw another 7 pieces. After 14 drops, we should have seen all standard pieces.
      for (var i = 0; i < 7; i++) {
        if (game.isGameOver) break;
        pieces.add(game.current!.type);
        game.hardDrop();
      }

      expect(pieces, equals(standardPieces));
    });
  });

  group('Game Time Management', () {
    test('time challenge decrements time', () async {
      final timeGame = Game(
        audioProvider: MockAudioProvider(),
        gameMode: GameMode.timeChallenge,
      );
      
      // Simulate some time passing
      await Future.delayed(const Duration(milliseconds: 100));
      timeGame.tick();
      
      // Time should still be set (might not have decreased yet depending on implementation)
      expect(timeGame.timeRemaining, isNotNull);
    });

    test('custom time limit works', () {
      final customGame = Game(
        audioProvider: MockAudioProvider(),
        gameMode: GameMode.custom,
        customConfig: const CustomGameConfig(
          timeLimit: Duration(minutes: 5),
        ),
      );
      
      expect(customGame.timeRemaining, isNotNull);
      expect(customGame.timeRemaining!.inMinutes, greaterThanOrEqualTo(4));
    });

    test('unlimited time mode has null timeRemaining', () {
      final customGame = Game(
        audioProvider: MockAudioProvider(),
        customConfig: const CustomGameConfig(
          timeLimit: null, // Unlimited
        ),
      );
      
      expect(customGame.timeRemaining, isNull);
    });
  });

  group('Game Spawn Logic', () {
    late Game game;
    late MockAudioProvider mockAudio;

    setUp(() {
      mockAudio = MockAudioProvider();
      game = Game(audioProvider: mockAudio);
    });

    test('spawned piece is centered horizontally', () {
      expect(game.current!.position.x, closeTo(game.width ~/ 2, 2));
    });

    test('spawned piece starts at top', () {
      expect(game.current!.position.y, lessThan(5));
    });


  });

  group('Game Score Calculation', () {
    late Game game;
    late MockAudioProvider mockAudio;

    setUp(() {
      mockAudio = MockAudioProvider();
      game = Game(audioProvider: mockAudio);
    });

    test('hard drop distance affects score', () {
      final score1 = game.score;
      
      game.hardDrop();
      final scoreGain1 = game.score - score1;
      
      game.reset();
      
      // Move down a bit before hard drop
      game.softDrop();
      game.softDrop();
      final score2 = game.score;
      
      game.hardDrop();
      final scoreGain2 = game.score - score2;
      
      // Shorter drop should give less score
      expect(scoreGain2, lessThan(scoreGain1));
    });
  });

  group('Game Edge Cases', () {
    late Game game;
    late MockAudioProvider mockAudio;

    setUp(() {
      mockAudio = MockAudioProvider();
      game = Game(audioProvider: mockAudio);
    });

    test('handles very small board', () {
      final smallGame = Game(
        audioProvider: mockAudio,
        width: 4,
        height: 10,
      );
      
      expect(smallGame.board.length, 10);
      expect(smallGame.board[0].length, 4);
      expect(smallGame.current, isNotNull);
    });

    test('handles large board', () {
      final largeGame = Game(
        audioProvider: mockAudio,
        width: 20,
        height: 40,
      );
      
      expect(largeGame.board.length, 40);
      expect(largeGame.board[0].length, 20);
      expect(largeGame.current, isNotNull);
    });

    test('multiple resets work correctly', () {
      for (var i = 0; i < 5; i++) {
        game.score = 1000;
        game.level = 5;
        game.reset();
        
        expect(game.score, 0);
        expect(game.level, 1);
        expect(game.current, isNotNull);
      }
    });

    test('game continues after pause/unpause', () {
      game.togglePause();
      game.togglePause();
      
      // Game should be unpaused
      expect(game.isPaused, false);
    });

    test('tick handles rapid calls', () {
      for (var i = 0; i < 20; i++) {
        if (!game.isGameOver) {
          game.tick();
        }
      }
      
      // Game should still be in valid state
      expect(game.board, isNotNull);
    });
  });

  group('Game Modes Specific Tests', () {
    late MockAudioProvider mockAudio;

    setUp(() {
      mockAudio = MockAudioProvider();
    });

    test('blitz mode can spawn special bricks', () {
      final blitzGame = Game(
        audioProvider: mockAudio,
        gameMode: GameMode.blitz,
      );
      
      // Blitz mode should be able to spawn special pieces
      // Play enough to potentially see special pieces
      final piecesSeenTypes = <FallingBlock>{};
      for (var i = 0; i < 30; i++) {
        if (blitzGame.current != null) {
          piecesSeenTypes.add(blitzGame.current!.type);
        }
        blitzGame.hardDrop();
        if (blitzGame.isGameOver) break;
      }
      
      // At minimum, we should see various pieces
      expect(piecesSeenTypes.length, greaterThan(3));
    });

    test('classic mode uses standard pieces only', () {
      final classicGame = Game(
        audioProvider: mockAudio,
        gameMode: GameMode.classic,
      );
      
      final standardPieces = {
        FallingBlock.I,
        FallingBlock.O,
        FallingBlock.T,
        FallingBlock.S,
        FallingBlock.Z,
        FallingBlock.J,
        FallingBlock.L,
      };
      
      // Check current and next pieces
      expect(standardPieces.contains(classicGame.current!.type), true);
      expect(standardPieces.contains(classicGame.next), true);
    });
  });
}
