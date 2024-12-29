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
  bool isGameOver = false; // {{ Add isGameOver flag }}
  List<int> flashingRows = []; // Add this to track which rows are flashing

  GameLogic(this.playfield) {
    spawnPiece();
    if (checkCollision(currentPiece!.x, currentPiece!.y)) {
      isGameOver = true;
    }
  }

  void spawnPiece() {
    currentPiece = nextPiece ?? pieces[Random().nextInt(pieces.length)];
    currentPiece!.x = 4;
    currentPiece!.y = 0;
    if (checkCollision(currentPiece!.x, currentPiece!.y)) {
      isGameOver = true;
    }
    nextPiece = pieces[Random().nextInt(pieces.length)];
  }

  void movePiece(Direction direction) {
    if (currentPiece != null) {
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
            placePiece();
            clearLines();
            spawnPiece();
          }
          break;
      }
    }
  }

  void rotatePiece() {
    if (currentPiece != null) {
      // Rotate the piece shape (you may need to implement a proper rotation logic)
      currentPiece!.shape = rotate(currentPiece!.shape);
      // Add collision detection logic here
    }
  }

  void clearLines() {
    flashingRows.clear(); // Clear previous flashing rows

    for (int y = playfield.length - 1; y >= 0; y--) {
      if (playfield[y].every((cell) => cell != 0)) {
        flashingRows.add(y); // Add row to flash
      }
    }

    // Only remove rows after showing flash animation
    if (flashingRows.isNotEmpty) {
      for (int y in flashingRows) {
        playfield.removeAt(y);
        playfield.insert(0, List.filled(playfield[0].length, 0));
      }
    }
  }

  void updateGame() {
    if (currentPiece != null && !isGameOver) {
      // Check if moving down would cause a collision
      if (!checkCollision(currentPiece!.x, currentPiece!.y + 1)) {
        currentPiece!.y++;
      } else {
        // If collision detected, place the piece and spawn a new one
        placePiece();
        clearLines();
        spawnPiece();
      }
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

  // Helper function to rotate the piece shape
  List<List<int>> rotate(List<List<int>> shape) {
    // Implement rotation logic for the piece
    // For example, transpose and reverse rows for clockwise rotation
    List<List<int>> rotated = List.generate(
        shape[0].length,
        (i) =>
            List.generate(shape.length, (j) => shape[shape.length - j - 1][i]));
    return rotated;
  }

  bool checkCollision(int newX, int newY) {
    for (int y = 0; y < currentPiece!.shape.length; y++) {
      for (int x = 0; x < currentPiece!.shape[y].length; x++) {
        if (currentPiece!.shape[y][x] != 0) {
          int worldX = newX + x;
          int worldY = newY + y;

          // Check boundaries
          if (worldX < 0 ||
              worldX >= playfield[0].length ||
              worldY >= playfield.length) {
            return true;
          }

          // Check collision with placed pieces
          if (worldY >= 0 && playfield[worldY][worldX] != 0) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
