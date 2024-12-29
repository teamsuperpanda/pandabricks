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

  GameLogic(this.playfield) {
    spawnPiece();
  }

  void spawnPiece() {
    currentPiece = pieces[Random().nextInt(pieces.length)];
    currentPiece!.x = 4; // Set initial x position
    currentPiece!.y = 0; // Set initial y position
  }

  void movePiece(Direction direction) {
    if (currentPiece != null) {
      switch (direction) {
        case Direction.left:
          currentPiece!.x--;
          break;
        case Direction.right:
          currentPiece!.x++;
          break;
        case Direction.down:
          currentPiece!.y++;
          break;
      }
      // Add collision detection logic here
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
    for (int y = playfield.length - 1; y >= 0; y--) {
      if (playfield[y].every((cell) => cell != 0)) {
        playfield.removeAt(y);
        playfield.insert(
            0,
            List.filled(
                playfield[0].length, 0)); // Add a new empty line at the top
        y++; // Check the same line again
      }
    }
  }

  void updateGame() {
    if (currentPiece != null) {
      // Move the piece down
      currentPiece!.y++;

      // Check for collisions
      if (checkCollision()) {
        // If collision occurs, place the piece on the playfield
        placePiece();
        clearLines(); // Clear completed lines
        spawnPiece(); // Spawn a new piece
      }
    }
  }

  bool checkCollision() {
    for (int y = 0; y < currentPiece!.shape.length; y++) {
      for (int x = 0; x < currentPiece!.shape[y].length; x++) {
        if (currentPiece!.shape[y][x] != 0) {
          // If the cell is part of the piece
          int newX = currentPiece!.x + x;
          int newY = currentPiece!.y + y;

          // Check if the new position is out of bounds or collides with another piece
          if (newX < 0 ||
              newX >= playfield[0].length ||
              newY >= playfield.length ||
              (newY >= 0 && playfield[newY][newX] != 0)) {
            currentPiece!.y--; // Move the piece back up
            return true; // Collision detected
          }
        }
      }
    }
    return false; // No collision
  }

  void placePiece() {
    for (int y = 0; y < currentPiece!.shape.length; y++) {
      for (int x = 0; x < currentPiece!.shape[y].length; x++) {
        if (currentPiece!.shape[y][x] != 0) {
          // If the cell is part of the piece
          int newX = currentPiece!.x + x;
          int newY = currentPiece!.y + y;
          if (newY >= 0) {
            // Only place if within bounds
            playfield[newY][newX] = currentPiece!.colorIndex +
                1; // Mark the cell with the color index
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
}
