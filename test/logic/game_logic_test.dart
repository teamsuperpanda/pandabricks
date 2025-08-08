import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/logic/game_logic.dart';
import 'package:pandabricks/models/mode_model.dart';
import 'package:pandabricks/logic/bricks_logic.dart';
import '../mocks/audio_service_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GameLogic gameLogic;
  late ModeModel testMode;
  late MockAudioService mockAudio;

  setUp(() {
    mockAudio = MockAudioService();
    testMode = ModeModel(
      id: ModeId.normal,
      name: 'Test',
      initialSpeed: 100,
      speedIncrease: 10,
      scoreThreshold: 1000,
      pandabrickSpawnPercentage: 5,
      rowClearScore: 1,
      specialBlocksSpawnPercentage: 0,
    );

    gameLogic = GameLogic(
      List.generate(20, (index) => List.filled(10, 0)),
      mockAudio,
      testMode,
    );
  });

  group('Row Clearing Tests', () {
    test('should detect completed row', () {
      // Fill a row completely
      gameLogic.playfield[19] = List.filled(10, 1);

      gameLogic.checkLines();

      expect(gameLogic.flashingRows.length, 1);
      expect(gameLogic.flashingRows[0], 19);
    });

    test('should detect multiple completed rows', () {
      // Fill two rows completely
      gameLogic.playfield[19] = List.filled(10, 1);
      gameLogic.playfield[18] = List.filled(10, 1);

      gameLogic.checkLines();

      expect(gameLogic.flashingRows.length, 2);
      expect(gameLogic.flashingRows, containsAll([18, 19]));
    });

    test('should clear completed rows and update score', () {
      // Fill a row completely
      gameLogic.playfield[19] = List.filled(10, 1);

      gameLogic.checkLines();
      gameLogic.removeLines();

      // Check if row was cleared
      expect(gameLogic.playfield[19].every((cell) => cell == 0), true);
      // Check if score was updated
      expect(gameLogic.score > 0, true);
    });
  });

  group('Piece Movement Tests', () {
    test('should move piece left when valid', () {
      gameLogic.spawnPiece();
      gameLogic.currentPiece!.x = 5;
      gameLogic.movePiece(Direction.left);
      expect(gameLogic.currentPiece!.x, 4);
    });

    test('should move piece right when valid', () {
      gameLogic.spawnPiece();
      int initialX = gameLogic.currentPiece!.x;

      gameLogic.movePiece(Direction.right);

      expect(gameLogic.currentPiece!.x, initialX + 1);
    });

    test('should not move piece outside boundaries', () {
      gameLogic.spawnPiece();

      // Move piece to left boundary
      while (!gameLogic.checkCollision(
          gameLogic.currentPiece!.x - 1, gameLogic.currentPiece!.y)) {
        gameLogic.movePiece(Direction.left);
      }
      int atBoundaryX = gameLogic.currentPiece!.x;

      // Try to move left again
      gameLogic.movePiece(Direction.left);

      expect(gameLogic.currentPiece!.x, atBoundaryX);
    });
  });

  group('Piece Rotation Tests', () {
    test('should rotate piece when space available', () {
      // Use I-piece (index 0) which changes when rotated
      gameLogic.currentPiece = TetrisPiece(
        BrickShapes.shapes[0], // I-piece
        4,
        0,
        0,
      );

      var originalShape = List<List<int>>.from(
          gameLogic.currentPiece!.shape.map((row) => List<int>.from(row)));

      gameLogic.rotatePiece();

      expect(gameLogic.currentPiece!.shape, isNot(equals(originalShape)));
    });
  });

  group('Board Flip Tests', () {
    test('should flip board correctly', () async {
      gameLogic = GameLogic(
        List.generate(20, (index) => List.filled(10, 0)),
        mockAudio,
        ModeModel(
          id: ModeId.bambooblitz,
          name: 'Test',
          initialSpeed: 100,
          speedIncrease: 10,
          scoreThreshold: 1000,
          pandabrickSpawnPercentage: 5,
          rowClearScore: 1,
          specialBlocksSpawnPercentage: 0,
          flipThreshold: 1000,
        ),
      );

      // Place multiple pieces at the top to track the flip
      gameLogic.playfield[0][0] = 1;
      gameLogic.playfield[1][0] = 2;
      gameLogic.playfield[2][0] = 3;

      await gameLogic.executeFlip();

      // Verify the board has been flipped and pieces have fallen to the bottom
      expect(gameLogic.playfield[19][0], 1);
      expect(gameLogic.playfield[18][0], 2);
      expect(gameLogic.playfield[17][0], 3);
    });
  });

  group('Special Brick Tests', () {
    test('should handle panda brick correctly', () {
      gameLogic.forceNextPandaBrick();
      gameLogic.spawnPiece();

      expect(gameLogic.isPandaBrick, true);
      expect(gameLogic.currentPiece!.colorIndex, 7);
    });
  });

  group('Game Over Tests', () {
    test('should detect game over when piece spawns in occupied space', () {
      // Fill spawn area completely to guarantee collision
      for (int i = 0; i < 10; i++) {
        gameLogic.playfield[0][i] = 1;
      }

      gameLogic.spawnPiece();

      expect(gameLogic.isGameOver, true);
    });
  });

  group('Speed Tests', () {
    test('should increase speed when score threshold is reached', () {
      double initialSpeed = gameLogic.currentSpeed;

      // Simulate scoring enough points to trigger speed increase
      gameLogic.playfield[19] = List.filled(10, 1);
      gameLogic.checkLines();
      gameLogic.removeLines();

      // Add more rows until threshold is reached
      while (gameLogic.score < testMode.scoreThreshold) {
        gameLogic.playfield[19] = List.filled(10, 1);
        gameLogic.checkLines();
        gameLogic.removeLines();
      }

      expect(gameLogic.currentSpeed, initialSpeed + testMode.speedIncrease);
    });
  });

  group('Special Mechanics Tests', () {
    test('should handle ghost brick reversed controls', () {
      // Force spawn a ghost brick
      gameLogic.currentPiece = TetrisPiece(
        BrickShapes.shapes[8],
        4,
        0,
        8, // Ghost brick index
      );
      gameLogic.isGhostBrick = true;

      int initialX = gameLogic.currentPiece!.x;

      // When moving left, ghost brick should go right
      gameLogic.movePiece(Direction.left);
      expect(gameLogic.currentPiece!.x, initialX + 1);

      // When moving right, ghost brick should go left
      gameLogic.movePiece(Direction.right);
      expect(gameLogic.currentPiece!.x, initialX);
    });

    test('should auto-rotate tornado brick on downward movement', () {
      // Force spawn a tornado brick
      gameLogic.currentPiece = TetrisPiece(
        BrickShapes.shapes[10],
        4,
        0,
        10, // Tornado brick index
      );
      gameLogic.isTornadoBrick = true;

      var originalShape = List<List<int>>.from(
          gameLogic.currentPiece!.shape.map((row) => List<int>.from(row)));

      gameLogic.updateGame();

      expect(gameLogic.currentPiece!.shape, isNot(equals(originalShape)));
    });
  });
}
