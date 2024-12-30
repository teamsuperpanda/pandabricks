import 'dart:math';
import 'dart:async';
import 'package:pandabricks/constants/tetris_shapes.dart'; // Import Tetris shapes
import 'package:pandabricks/services/audio_service.dart'; // Import AudioService
import 'package:pandabricks/models/mode_model.dart'; // Import ModeModel

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
List<TetrisPiece> pieces = TetrisShapes.shapes
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
  int score = 0;
  double currentSpeed;

  GameLogic(this.playfield, this.audioService, this.mode)
      : currentSpeed = mode.speed.toDouble() {
    spawnPiece();
  }

  void spawnPiece() {
    if (nextPiece == null) {
      // Use mode's pandabrickSpawnPercentage instead of hardcoded value
      bool shouldSpawnPanda =
          Random().nextInt(100) < mode.pandabrickSpawnPercentage;
      int randomIndex = shouldSpawnPanda ? 7 : Random().nextInt(7);

      List<List<int>> shapeClone =
          pieces[randomIndex].shape.map((row) => List<int>.from(row)).toList();
      currentPiece = TetrisPiece(
        shapeClone,
        4,
        0,
        randomIndex,
      );
      isPandaBrick = shouldSpawnPanda;
    } else {
      currentPiece = TetrisPiece(
        nextPiece!.shape.map((row) => List<int>.from(row)).toList(),
        4,
        0,
        nextPiece!.colorIndex,
      );
      isPandaBrick = nextPiece!.colorIndex == 7;
    }

    // Generate next piece (exclude panda from next preview)
    int nextIndex = Random().nextInt(7);
    List<List<int>> nextShapeClone =
        pieces[nextIndex].shape.map((row) => List<int>.from(row)).toList();
    nextPiece = TetrisPiece(
      nextShapeClone,
      0,
      0,
      nextIndex,
    );

    if (checkCollision(currentPiece!.x, currentPiece!.y)) {
      isGameOver = true;
    }
  }

  void movePiece(Direction direction) {
    if (currentPiece == null || isClearing || isGameOver) return;

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
    if (currentPiece == null || isClearing || isGameOver) return;

    if (!checkCollision(currentPiece!.x, currentPiece!.y + 1)) {
      currentPiece!.y++;
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
    // Check from bottom to top
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
      flashingRows = List.from(flashingRows);
    } else {
      spawnPiece();
    }
  }

  void removeLines() {
    if (!isClearing || flashingRows.isEmpty) return;

    // Update score before removing lines
    updateScore(flashingRows.length);

    // Sort rows in descending order to remove from bottom up
    flashingRows.sort((a, b) => b.compareTo(a));

    // Remove completed rows
    for (int y in flashingRows) {
      playfield.removeAt(y);
      playfield.insert(0, List.filled(playfield[0].length, 0));
    }

    // Reset state
    flashingRows = [];
    isClearing = false;
    spawnPiece();
  }

  void rotatePiece() {
    if (currentPiece == null || isClearing || isGameOver) return;

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
    if (isPandaBrick) {
      if (currentPiece!.y + 2 >= playfield.length) {
        // Reached bottom, lock normally with grey color
        currentPiece!.colorIndex = 8;
        placePiece();
        currentPiece = null;
        checkLines();
      } else if (!isPandaFlashing) {
        // Start flash sequence if collided with other bricks
        startPandaFlash();
      }
    } else {
      // Normal piece locking
      placePiece();
      currentPiece = null;
      checkLines();
    }
  }

  void hardDrop() {
    if (currentPiece == null || isClearing || isGameOver) return;

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

    // Clear both the panda brick and the columns below it in one go
    for (int x = startX; x < startX + 2; x++) {
      // Clear from the panda brick position all the way down
      for (int y = startY; y < playfield.length; y++) {
        playfield[y][x] = 0;
      }
    }

    // Reset state
    isPandaFlashing = false;
    currentPiece = null;
    // Play sound before checking lines
    AudioService().playSound('panda_disappear');
    checkLines();
  }

  void dispose() {
    flashTimer?.cancel();
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

  void updateScore(int clearedLines) {
    // Use standard Tetris scoring multipliers
    final Map<int, int> scoreMultipliers = {
      1: 100, // Single
      2: 300, // Double
      3: 500, // Triple
      4: 800, // Tetris
    };

    // Calculate base points from number of lines cleared
    int basePoints = (scoreMultipliers[clearedLines] ?? 0) * mode.rowClearScore;

    // Add points to score
    score += basePoints;

    // Check if we need to increase speed based on score threshold
    if (mode.scoreThreshold > 0 &&
        score > 0 &&
        (score / mode.scoreThreshold).floor() >
            ((score - basePoints) / mode.scoreThreshold).floor()) {
      currentSpeed += mode.speedIncrease;
    }
  }
}
