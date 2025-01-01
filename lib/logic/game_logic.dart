import 'dart:math';
import 'dart:async';
import 'package:pandabricks/logic/bricks_logic.dart';
import 'package:pandabricks/services/audio_service.dart';
import 'package:pandabricks/models/mode_model.dart';
import 'package:pandabricks/logic/score_logic.dart';

// Define the Direction enum
enum Direction {
  left,
  right,
  down,
}

// Define the Tetris piece class
class TetrisPiece {
  List<List<int>> shape; // 2D array representing the piece shape
  int x; // Current x position
  int y; // Current y position
  int colorIndex; // Index to determine the color of the piece

  TetrisPiece(this.shape, this.x, this.y, this.colorIndex);
}

// List of available pieces using TetrisShapes
List<TetrisPiece> pieces = BrickShapes.shapes
    .asMap()
    .entries
    .map((entry) => TetrisPiece(entry.value, 0, 0, entry.key))
    .toList();

// Instead, implement GameLogic as a class
class GameLogic {
  List<List<int>> playfield;
  TetrisPiece? currentPiece;
  TetrisPiece? nextPiece;
  bool isGameOver = false;
  List<int> flashingRows = [];
  bool isClearing = false;
  bool isPandaBrick = false;
  bool isPandaFlashing = false;
  Timer? flashTimer;
  final AudioService audioService;
  final ModeModel mode;
  late final ScoreLogic scoreLogic;
  double currentSpeed;
  final double speedIncrease;
  final int scoreThreshold;
  bool isGhostBrick = false;
  bool isCatBrick = false;
  Timer? catMovementTimer;
  bool isTornadoBrick = false;
  Timer? tornadoRotationTimer;
  bool isFlipping = false;
  bool shouldFlip = false;
  double flipProgress = 0.0;
  final int? flipThreshold;
  int lastFlipScore = 0;
  static const List<int> specialBrickIndices = [
    BrickShapes.ghostBrick, // 8
    BrickShapes.catBrick, // 9
    BrickShapes.tornadoBrick, // 10
    BrickShapes.bombBrick, // 11
  ];

  // Add callback for explosion effect
  Function(double x, double y)? onPandaExplode;

  // Add callback for bomb effect
  Function(int x, int y)? onBombExplode;

  GameLogic(this.playfield, this.audioService, this.mode)
      : currentSpeed = mode.speed.toDouble(),
        speedIncrease = mode.speedIncrease.toDouble(),
        scoreThreshold = mode.scoreThreshold,
        flipThreshold = mode.flipThreshold {
    scoreLogic = ScoreLogic(
      rowClearScore: mode.rowClearScore,
    );
    spawnPiece();
  }

  int get score => scoreLogic.score;

  void spawnPiece() {
    if (nextPiece == null) {
      // Reset states
      isGhostBrick = false;
      isCatBrick = false;
      isTornadoBrick = false;

      bool shouldSpawnSpecial = mode.name == 'Bambooblitz' &&
          Random().nextInt(100) < mode.specialBlocksSpawnPercentage;
      bool shouldSpawnPanda = !shouldSpawnSpecial &&
          Random().nextInt(100) < mode.pandabrickSpawnPercentage;

      int randomIndex;
      if (shouldSpawnSpecial) {
        // Get a random special brick (excluding brick effect)
        List<int> normalSpecialBricks = [
          BrickShapes.ghostBrick,
          BrickShapes.catBrick,
          BrickShapes.tornadoBrick,
          BrickShapes.bombBrick,
        ];
        randomIndex =
            normalSpecialBricks[Random().nextInt(normalSpecialBricks.length)];

        // Set the appropriate flags
        isGhostBrick = randomIndex == BrickShapes.ghostBrick;
        isCatBrick = randomIndex == BrickShapes.catBrick;
        isTornadoBrick = randomIndex == BrickShapes.tornadoBrick;
      } else if (shouldSpawnPanda) {
        randomIndex = BrickShapes.pandaBrick;
      } else {
        randomIndex = Random().nextInt(BrickShapes.standardBrickEnd + 1);
      }

      List<List<int>> shapeClone =
          pieces[randomIndex].shape.map((row) => List<int>.from(row)).toList();

      // Calculate spawn position to center the piece
      int pieceWidth = shapeClone[0].length;
      int spawnX = (playfield[0].length - pieceWidth) ~/ 2;

      currentPiece = TetrisPiece(
        shapeClone,
        spawnX, // Center the piece horizontally
        0,
        randomIndex,
      );
      isPandaBrick = randomIndex == 7;
    } else {
      // Handle next piece becoming current
      currentPiece = nextPiece;

      // Center normal pieces as before
      int pieceWidth = currentPiece!.shape[0].length;
      currentPiece!.x = (playfield[0].length - pieceWidth) ~/ 2;

      isPandaBrick = nextPiece!.colorIndex == 7;
      isGhostBrick = nextPiece!.colorIndex == 8;
      isCatBrick = nextPiece!.colorIndex == 9;
      isTornadoBrick = nextPiece!.colorIndex == 10;

      if (isCatBrick) {
        startCatMovement();
      }
    }

    // Generate next piece
    bool shouldSpawnNextSpecial = mode.name == 'Bambooblitz' &&
        Random().nextInt(100) < mode.specialBlocksSpawnPercentage;
    bool shouldSpawnNextPanda = !shouldSpawnNextSpecial &&
        Random().nextInt(100) < mode.pandabrickSpawnPercentage;

    int nextIndex;
    if (shouldSpawnNextSpecial) {
      nextIndex =
          specialBrickIndices[Random().nextInt(specialBrickIndices.length)];
    } else if (shouldSpawnNextPanda) {
      nextIndex = BrickShapes.pandaBrick;
    } else {
      nextIndex = Random().nextInt(BrickShapes.standardBrickEnd + 1);
    }

    // Create next piece (even for brick effect, to show in next piece window)
    List<List<int>> nextShapeClone =
        pieces[nextIndex].shape.map((row) => List<int>.from(row)).toList();
    nextPiece = TetrisPiece(
      nextShapeClone,
      0,
      0,
      nextIndex,
    );

    // Only check collision if we have a current piece
    if (currentPiece != null &&
        checkCollision(currentPiece!.x, currentPiece!.y)) {
      isGameOver = true;
    }
  }

  void movePiece(Direction direction) {
    if (currentPiece == null || isClearing || isGameOver || isPandaFlashing) {
      return;
    }

    // Handle reversed controls for ghost brick in Bamboo Blitz
    if (isGhostBrick && currentPiece?.colorIndex == 8) {
      switch (direction) {
        case Direction.left:
          // When player presses left, move right
          if (!checkCollision(currentPiece!.x + 1, currentPiece!.y)) {
            currentPiece!.x++;
          }
          break;
        case Direction.right:
          // When player presses right, move left
          if (!checkCollision(currentPiece!.x - 1, currentPiece!.y)) {
            currentPiece!.x--;
          }
          break;
        case Direction.down:
          // Down movement stays the same
          if (!checkCollision(currentPiece!.x, currentPiece!.y + 1)) {
            currentPiece!.y++;
          } else {
            lockPiece();
          }
          break;
      }
      return;
    }

    // Original movement code for normal pieces
    switch (direction) {
      case Direction.left:
        if (!checkCollision(currentPiece!.x - 1, currentPiece!.y)) {
          currentPiece!.x--;
        }
        break;
      case Direction.right:
        if (!checkCollision(currentPiece!.x + 1, currentPiece!.y)) {
          currentPiece!.x++;
        }
        break;
      case Direction.down:
        if (!checkCollision(currentPiece!.x, currentPiece!.y + 1)) {
          currentPiece!.y++;
        } else {
          lockPiece();
        }
        break;
    }
  }

  void updateGame() {
    if (currentPiece == null || isClearing || isGameOver || isPandaFlashing) {
      return;
    }

    // Check for flip condition
    if (shouldCheckForFlip()) {
      currentPiece = null; // Remove current piece
      startFlipAnimation();
      return;
    }

    if (!checkCollision(currentPiece!.x, currentPiece!.y + 1)) {
      currentPiece!.y++;
      // Rotate tornado piece when it moves down
      if (isTornadoBrick) {
        rotatePiece();
      }
    } else {
      lockPiece();
    }
  }

  void placePiece() {
    for (int y = 0; y < currentPiece!.shape.length; y++) {
      for (int x = 0; x < currentPiece!.shape[y].length; x++) {
        if (currentPiece!.shape[y][x] != 0) {
          int worldY = currentPiece!.y + y;
          int worldX = currentPiece!.x + x;
          if (worldY >= 0 &&
              worldY < playfield.length &&
              worldX >= 0 &&
              worldX < playfield[0].length) {
            playfield[worldY][worldX] = currentPiece!.colorIndex + 1;
          }
        }
      }
    }
  }

  void checkLines() {
    if (isClearing) return;

    flashingRows.clear();
    // Check all rows from bottom to top
    for (int y = playfield.length - 1; y >= 0; y--) {
      bool isRowFull = true;
      for (int x = 0; x < playfield[y].length; x++) {
        if (playfield[y][x] == 0) {
          isRowFull = false;
          break;
        }
      }
      if (isRowFull) {
        flashingRows.add(y);
      }
    }

    if (flashingRows.isNotEmpty) {
      isClearing = true;
      // Create a new list to avoid modification issues
      flashingRows = List.from(flashingRows);
      // Sort rows in descending order to handle removal properly
      flashingRows.sort((a, b) => b.compareTo(a));
    } else {
      spawnPiece();
    }
  }

  void removeLines() {
    if (!isClearing || flashingRows.isEmpty) return;

    int basePoints = scoreLogic.updateScore(flashingRows.length);

    // Check if we need to increase speed based on score threshold
    if (scoreThreshold > 0 &&
        scoreLogic.score > 0 &&
        (scoreLogic.score / scoreThreshold).floor() >
            ((scoreLogic.score - basePoints) / scoreThreshold).floor()) {
      currentSpeed += speedIncrease;
    }

    // Remove completed rows from bottom to top to avoid index shifting issues
    for (int y in flashingRows) {
      playfield.removeAt(y);
      playfield.insert(0, List.filled(playfield[0].length, 0));
    }

    // Reset state
    flashingRows = [];
    isClearing = false;

    // Check for any new lines that might have formed after the removal
    bool hasMoreLines = false;
    for (int y = playfield.length - 1; y >= 0; y--) {
      bool isRowFull = true;
      for (int x = 0; x < playfield[y].length; x++) {
        if (playfield[y][x] == 0) {
          isRowFull = false;
          break;
        }
      }
      if (isRowFull) {
        hasMoreLines = true;
        break;
      }
    }

    if (hasMoreLines) {
      // If there are more lines to clear, check them
      checkLines();
    } else {
      // If no more lines to clear, spawn new piece
      spawnPiece();
    }
  }

  void rotatePiece() {
    if (currentPiece == null || isClearing || isGameOver || isPandaFlashing) {
      return;
    }

    List<List<int>> rotated = rotate(currentPiece!.shape);

    // Create a temporary piece to check collision
    TetrisPiece tempPiece = TetrisPiece(
      rotated,
      currentPiece!.x,
      currentPiece!.y,
      currentPiece!.colorIndex,
    );

    // Check if this is an I-piece (4x1 or 1x4 shape)
    bool isIPiece =
        currentPiece!.shape.length == 1 || currentPiece!.shape[0].length == 1;

    // Try rotation at current position
    if (!checkRotationCollision(tempPiece)) {
      currentPiece!.shape = rotated;
      return;
    }

    // Try shifting left
    tempPiece.x--;
    if (!checkRotationCollision(tempPiece)) {
      currentPiece!.x--;
      currentPiece!.shape = rotated;
      return;
    }
    tempPiece.x++;

    // Try shifting right
    tempPiece.x++;
    if (!checkRotationCollision(tempPiece)) {
      currentPiece!.x++;
      currentPiece!.shape = rotated;
      return;
    }
    tempPiece.x--;

    // Additional wall kicks for I-piece
    if (isIPiece) {
      // Try two spaces left
      tempPiece.x -= 2;
      if (!checkRotationCollision(tempPiece)) {
        currentPiece!.x -= 2;
        currentPiece!.shape = rotated;
        return;
      }
      tempPiece.x += 2;

      // Try two spaces right
      tempPiece.x += 2;
      if (!checkRotationCollision(tempPiece)) {
        currentPiece!.x += 2;
        currentPiece!.shape = rotated;
        return;
      }
    }

    // If no valid position found, don't rotate
  }

  bool checkRotationCollision(TetrisPiece piece) {
    for (int y = 0; y < piece.shape.length; y++) {
      for (int x = 0; x < piece.shape[y].length; x++) {
        if (piece.shape[y][x] != 0) {
          int worldX = piece.x + x;
          int worldY = piece.y + y;

          if (worldX < 0 ||
              worldX >= playfield[0].length ||
              worldY >= playfield.length ||
              (worldY >= 0 && playfield[worldY][worldX] != 0)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  List<List<int>> rotate(List<List<int>> shape) {
    return List.generate(
        shape[0].length,
        (i) =>
            List.generate(shape.length, (j) => shape[shape.length - j - 1][i]));
  }

  bool checkCollision(int newX, int newY) {
    if (currentPiece == null) return false;

    for (int y = 0; y < currentPiece!.shape.length; y++) {
      for (int x = 0; x < currentPiece!.shape[y].length; x++) {
        if (currentPiece!.shape[y][x] != 0) {
          int worldX = newX + x;
          int worldY = newY + y;

          // Check if reached bottom
          if (worldY >= playfield.length) {
            if (isPandaBrick) {
              // Lock panda at bottom
              currentPiece!.colorIndex = 8; // Grey color
              return true;
            }
            return true;
          }

          // Check wall collisions
          if (worldX < 0 || worldX >= playfield[0].length) {
            return true;
          }

          // Check brick collisions
          if (worldY >= 0 && playfield[worldY][worldX] != 0) {
            if (isPandaBrick && !isPandaFlashing) {
              startPandaFlash();
            }
            return true;
          }
        }
      }
    }
    return false;
  }

  void lockPiece() {
    if (isCatBrick) {
      catMovementTimer?.cancel();
    }
    if (isTornadoBrick) {
      tornadoRotationTimer?.cancel();
    }
    if (isPandaBrick) {
      if (currentPiece!.y + 2 >= playfield.length) {
        currentPiece!.colorIndex = 8;
        placePiece();
        currentPiece = null;
        checkLines();
      } else if (!isPandaFlashing) {
        startPandaFlash();
      }
    } else if (isBombBrick()) {
      // Trigger bomb effect
      int bombX = currentPiece!.x;
      int bombY = currentPiece!.y;
      onBombExplode?.call(bombX, bombY);

      // Clear the row and column of the bomb
      clearBombEffects(bombX, bombY);

      // Lock the bomb piece
      placePiece();
      currentPiece = null;
      checkLines();
    } else {
      placePiece();
      currentPiece = null;

      // Check for queued flip after piece is locked
      if (shouldFlip && !isClearing) {
        executeFlip();
      } else {
        checkLines();
      }
    }
  }

  void clearBombEffects(int x, int y) {
    // Add to flashing rows for animation effect
    flashingRows.add(y);
    isClearing = true;

    // Delay the actual clearing to allow for animation
    Future.delayed(const Duration(milliseconds: 500), () {
      // Clear entire row
      for (int col = 0; col < playfield[0].length; col++) {
        playfield[y][col] = 0;
      }

      // Clear entire column
      for (int row = 0; row < playfield.length; row++) {
        playfield[row][x] = 0;
      }

      // Reset state
      flashingRows.clear();
      isClearing = false;

      // Play explosion sound
      audioService.playSound('bomb_explode');

      // Check for any new lines and spawn new piece
      checkLines();
    });
  }

  bool isBombBrick() {
    return currentPiece?.colorIndex == BrickShapes.bombBrick;
  }

  void hardDrop() {
    if (currentPiece == null || isClearing || isGameOver || isPandaFlashing) {
      return;
    }

    // Move piece down until collision
    while (!checkCollision(currentPiece!.x, currentPiece!.y + 1)) {
      currentPiece!.y++;
    }

    // Lock the piece in place
    lockPiece();
  }

  void startPandaFlash() {
    if (isPandaFlashing) return;

    isPandaFlashing = true;
    flashTimer?.cancel();

    // Play stab sound when flash starts
    audioService.playStabSound();

    flashTimer = Timer(const Duration(milliseconds: 1500), () {
      clearPandaArea();
    });
  }

  void clearPandaArea() {
    if (currentPiece == null) return;

    // Get the positions before clearing
    int startX = currentPiece!.x;
    int startY = currentPiece!.y;

    // Calculate center position for explosion
    double cellSize = 30.0;
    double centerX = (startX + 1.0) * cellSize;
    double centerY = (startY + 1.0) * cellSize;

    // Clear the panda brick immediately
    for (int y = 0; y < currentPiece!.shape.length; y++) {
      for (int x = 0; x < currentPiece!.shape[y].length; x++) {
        if (currentPiece!.shape[y][x] != 0) {
          int worldY = currentPiece!.y + y;
          int worldX = currentPiece!.x + x;
          if (worldY >= 0 && worldY < playfield.length) {
            playfield[worldY][worldX] = 0;
          }
        }
      }
    }

    // Trigger explosion animation
    onPandaExplode?.call(centerX, centerY);

    // Clear the columns after a delay
    Future.delayed(const Duration(milliseconds: 150), () {
      // Clear the columns below
      for (int x = startX; x < startX + 2; x++) {
        for (int y = startY; y < playfield.length; y++) {
          playfield[y][x] = 0;
        }
      }

      // Reset state
      isPandaFlashing = false;
      currentPiece = null;
      AudioService().playSound('panda_disappear');
      checkLines();
    });
  }

  void dispose() {
    flashTimer?.cancel();
    catMovementTimer?.cancel();
  }

  void forceNextPandaBrick() {
    // Create a panda brick as the next piece
    List<List<int>> pandaShape =
        pieces[7].shape.map((row) => List<int>.from(row)).toList();
    nextPiece = TetrisPiece(
      pandaShape,
      0,
      0,
      7, // Index for panda brick
    );
  }

  void removePandaBrick() {
    // Play the disappear sound
    AudioService().playSound('panda_disappear');
  }

  void startCatMovement() {
    catMovementTimer?.cancel();
    catMovementTimer = Timer.periodic(
      BrickShapes.catMovementInterval,
      (timer) {
        if (currentPiece == null || !isCatBrick || isGameOver) {
          timer.cancel();
          return;
        }

        // Only handle horizontal movement, let natural gravity handle falling
        int horizontalMove = Random().nextInt(3) - 1; // -1, 0, or 1
        if (horizontalMove != 0) {
          int newX = currentPiece!.x + horizontalMove;
          if (!checkCollision(newX, currentPiece!.y)) {
            currentPiece!.x = newX;
          }
        }
      },
    );
  }

  bool shouldCheckForFlip() {
    if (flipThreshold == null || isFlipping) return false;
    int flipPoints =
        (scoreLogic.score / flipThreshold!).floor() * flipThreshold!;
    return flipPoints > lastFlipScore;
  }

  void startFlipAnimation() {
    if (isFlipping || isGameOver) {
      return;
    }

    // If there's an active piece, set shouldFlip flag and wait
    if (currentPiece != null || isClearing) {
      shouldFlip = true;
      return;
    }

    // Execute flip if no active piece
    executeFlip();
  }

  Future<void> executeFlip() async {
    isFlipping = true;
    lastFlipScore =
        (scoreLogic.score / flipThreshold!).floor() * flipThreshold!;

    // Let the animation complete before flipping the playfield
    await Future.delayed(const Duration(milliseconds: 1000));

    // Mirror the playfield vertically
    List<List<int>> flippedField = [];
    for (int i = playfield.length - 1; i >= 0; i--) {
      flippedField.add(List.from(playfield[i]));
    }
    playfield = flippedField;

    // Start letting pieces fall
    letPiecesFall();
  }

  void letPiecesFall() {
    bool hasFalling = false;

    // Check each cell from bottom to top
    for (int y = playfield.length - 2; y >= 0; y--) {
      for (int x = 0; x < playfield[y].length; x++) {
        if (playfield[y][x] != 0 && playfield[y + 1][x] == 0) {
          playfield[y + 1][x] = playfield[y][x];
          playfield[y][x] = 0;
          hasFalling = true;
        }
      }
    }

    if (hasFalling) {
      // Continue falling on next frame with a slight delay for visual effect
      Future.delayed(const Duration(milliseconds: 50), letPiecesFall);
    } else {
      // Falling complete - check for completed rows before spawning new piece
      isFlipping = false;
      shouldFlip = false;
      checkLines(); // Add this line to check for completed rows
      if (!isClearing) {
        // Only spawn new piece if no rows need to be cleared
        spawnPiece();
      }
    }
  }
}
