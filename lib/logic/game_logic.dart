import 'dart:math';
import 'package:pandabricks/constants/tetris_shapes.dart'; // Import Tetris shapes

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

  GameLogic(this.playfield) {
    spawnPiece();
  }

  void spawnPiece() {
    // Create a deep copy of the next piece or generate a new one
    if (nextPiece == null) {
      int randomIndex = Random().nextInt(pieces.length);
      List<List<int>> shapeClone =
          pieces[randomIndex].shape.map((row) => List<int>.from(row)).toList();
      currentPiece = TetrisPiece(
        shapeClone,
        4,
        0,
        pieces[randomIndex].colorIndex,
      );
    } else {
      currentPiece = TetrisPiece(
        nextPiece!.shape.map((row) => List<int>.from(row)).toList(),
        4,
        0,
        nextPiece!.colorIndex,
      );
    }

    // Generate next piece with a deep copy of the shape
    int nextIndex = Random().nextInt(pieces.length);
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
    currentPiece!.shape = rotated;
  }

  List<List<int>> rotate(List<List<int>> shape) {
    return List.generate(
        shape[0].length,
        (i) =>
            List.generate(shape.length, (j) => shape[shape.length - j - 1][i]));
  }

  bool checkCollision(int newX, int newY) {
    for (int y = 0; y < currentPiece!.shape.length; y++) {
      for (int x = 0; x < currentPiece!.shape[y].length; x++) {
        if (currentPiece!.shape[y][x] != 0) {
          int worldX = newX + x;
          int worldY = newY + y;

          if (worldX < 0 ||
              worldX >= playfield[0].length ||
              worldY >= playfield.length) {
            return true;
          }

          if (worldY >= 0 && playfield[worldY][worldX] != 0) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void lockPiece() {
    placePiece();
    currentPiece = null;
    checkLines();
  }
}
