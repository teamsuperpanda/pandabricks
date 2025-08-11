import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pandabricks/providers/audio_provider.dart';

enum Rotation { up, right, down, left }

class PointInt {
  final int x;
  final int y;
  const PointInt(this.x, this.y);

  PointInt operator +(PointInt other) => PointInt(x + other.x, y + other.y);
}

class ActivePiece {
  final FallingBlock type;
  final Rotation rotation;
  final PointInt position; // position of pivot on the board

  const ActivePiece({
    required this.type,
    required this.rotation,
    required this.position,
  });

  ActivePiece copyWith({FallingBlock? type, Rotation? rotation, PointInt? position}) {
    return ActivePiece(
      type: type ?? this.type,
      rotation: rotation ?? this.rotation,
      position: position ?? this.position,
    );
  }
}

enum FallingBlock { I, O, T, S, Z, J, L }

class Game extends ChangeNotifier {
  final int width;
  final int height;
  final AudioProvider audioProvider;

  late List<List<int?>> board; // height x width, stores color index or null
  ActivePiece? current;
  FallingBlock? next;
  bool isGameOver = false;
  bool isPaused = false;

  int score = 0;
  int linesCleared = 0;
  int level = 1;

  final Random _rng = Random();
  final List<FallingBlock> _bag = [];

  // Colors indices map for painter; 0..n
  static const Map<FallingBlock, int> colorFor = {
    FallingBlock.I: 0,
    FallingBlock.O: 1,
    FallingBlock.T: 2,
    FallingBlock.S: 3,
    FallingBlock.Z: 4,
    FallingBlock.J: 5,
    FallingBlock.L: 6,
  };

  Game({this.width = 10, this.height = 20, required this.audioProvider}) {
    _resetBoard();
    _refillBag();
    next = _drawFromBag();
    _spawn();
  }

  void _resetBoard() {
    board = List.generate(height, (_) => List<int?>.filled(width, null));
    isGameOver = false;
    isPaused = false;
    score = 0;
    linesCleared = 0;
    level = 1;
  }

  void reset() {
    _resetBoard();
    if (_bag.isEmpty) _refillBag();
    next ??= _drawFromBag();
    _spawn();
    notifyListeners();
  }

  void togglePause() {
    if (isGameOver) return;
    isPaused = !isPaused;
    notifyListeners();
  }

  void _refillBag() {
    _bag.clear();
    _bag.addAll(FallingBlock.values);
    _bag.shuffle(_rng);
  }

  FallingBlock _drawFromBag() {
    if (_bag.isEmpty) _refillBag();
    return _bag.removeLast();
  }

  void _spawn() {
    final type = next ?? _drawFromBag();
    next = _drawFromBag();
    final spawnPos = PointInt(width ~/ 2, 1);
    final piece = ActivePiece(type: type, rotation: Rotation.up, position: spawnPos);
    if (_collides(piece)) {
      isGameOver = true;
      notifyListeners(); // Notify listeners when game over state changes
    } else {
      current = piece;
      // Small note: spawn near the top; if colliding, mark game over
    }
  }

  // FallingBlock definition as list of relative offsets per rotation
  static const Map<FallingBlock, Map<Rotation, List<PointInt>>> shapes = {
    FallingBlock.I: {
      Rotation.up: [PointInt(-2, 0), PointInt(-1, 0), PointInt(0, 0), PointInt(1, 0)],
      Rotation.right: [PointInt(0, -1), PointInt(0, 0), PointInt(0, 1), PointInt(0, 2)],
      Rotation.down: [PointInt(-2, 1), PointInt(-1, 1), PointInt(0, 1), PointInt(1, 1)],
      Rotation.left: [PointInt(-1, -1), PointInt(-1, 0), PointInt(-1, 1), PointInt(-1, 2)],
    },
    FallingBlock.O: {
      Rotation.up: [PointInt(0, 0), PointInt(1, 0), PointInt(0, 1), PointInt(1, 1)],
      Rotation.right: [PointInt(0, 0), PointInt(1, 0), PointInt(0, 1), PointInt(1, 1)],
      Rotation.down: [PointInt(0, 0), PointInt(1, 0), PointInt(0, 1), PointInt(1, 1)],
      Rotation.left: [PointInt(0, 0), PointInt(1, 0), PointInt(0, 1), PointInt(1, 1)],
    },
    FallingBlock.T: {
      Rotation.up: [PointInt(-1, 0), PointInt(0, 0), PointInt(1, 0), PointInt(0, 1)],
      Rotation.right: [PointInt(0, -1), PointInt(0, 0), PointInt(0, 1), PointInt(1, 0)],
      Rotation.down: [PointInt(-1, 0), PointInt(0, 0), PointInt(1, 0), PointInt(0, -1)],
      Rotation.left: [PointInt(0, -1), PointInt(0, 0), PointInt(0, 1), PointInt(-1, 0)],
    },
    FallingBlock.S: {
      Rotation.up: [PointInt(0, 0), PointInt(1, 0), PointInt(-1, 1), PointInt(0, 1)],
      Rotation.right: [PointInt(0, 0), PointInt(0, 1), PointInt(1, -1), PointInt(1, 0)],
      Rotation.down: [PointInt(0, 0), PointInt(1, 0), PointInt(-1, 1), PointInt(0, 1)],
      Rotation.left: [PointInt(0, 0), PointInt(0, 1), PointInt(1, -1), PointInt(1, 0)],
    },
    FallingBlock.Z: {
      Rotation.up: [PointInt(-1, 0), PointInt(0, 0), PointInt(0, 1), PointInt(1, 1)],
      Rotation.right: [PointInt(1, 0), PointInt(1, 1), PointInt(0, -1), PointInt(0, 0)],
      Rotation.down: [PointInt(-1, -1), PointInt(0, -1), PointInt(0, 0), PointInt(1, 0)],
      Rotation.left: [PointInt(0, 0), PointInt(0, 1), PointInt(-1, -1), PointInt(-1, 0)],
    },
    FallingBlock.J: {
      Rotation.up: [PointInt(-1, 0), PointInt(0, 0), PointInt(1, 0), PointInt(-1, 1)],
      Rotation.right: [PointInt(0, -1), PointInt(0, 0), PointInt(0, 1), PointInt(1, -1)],
      Rotation.down: [PointInt(-1, 0), PointInt(0, 0), PointInt(1, 0), PointInt(1, -1)],
      Rotation.left: [PointInt(0, -1), PointInt(0, 0), PointInt(0, 1), PointInt(-1, 1)],
    },
    FallingBlock.L: {
      Rotation.up: [PointInt(-1, 0), PointInt(0, 0), PointInt(1, 0), PointInt(1, 1)],
      Rotation.right: [PointInt(0, -1), PointInt(0, 0), PointInt(0, 1), PointInt(1, 1)],
      Rotation.down: [PointInt(-1, -1), PointInt(-1, 0), PointInt(0, 0), PointInt(1, 0)],
      Rotation.left: [PointInt(-1, -1), PointInt(0, -1), PointInt(0, 0), PointInt(0, 1)],
    },
  };

  List<PointInt> _cells(ActivePiece piece) {
    final offsets = shapes[piece.type]![piece.rotation]!;
    return offsets.map((o) => piece.position + o).toList(growable: false);
  }

  bool _collides(ActivePiece piece) {
    for (final c in _cells(piece)) {
      if (c.x < 0 || c.x >= width || c.y < 0 || c.y >= height) return true;
      if (board[c.y][c.x] != null) return true;
    }
    return false;
  }

  bool moveLeft() => _tryMove(const PointInt(-1, 0));
  bool moveRight() => _tryMove(const PointInt(1, 0));
  bool softDrop() => _tryMove(const PointInt(0, 1));

  bool _tryMove(PointInt delta) {
    if (isPaused || isGameOver || current == null) return false;
    final nextPiece = current!.copyWith(position: current!.position + delta);
    if (_collides(nextPiece)) return false;
    current = nextPiece;
    notifyListeners();
    return true;
  }

  void rotateCW() {
    if (isPaused || isGameOver || current == null) return;
    final nextRotation = Rotation.values[(current!.rotation.index + 1) % 4];
    final rotated = current!.copyWith(rotation: nextRotation);
    // simple wall kick attempts
    final kicks = [
      const PointInt(0, 0),
      const PointInt(-1, 0),
      const PointInt(1, 0),
      const PointInt(0, -1),
    ];
    for (final k in kicks) {
      final candidate = rotated.copyWith(position: rotated.position + k);
      if (!_collides(candidate)) {
        current = candidate;
        notifyListeners();
        return;
      }
    }
  }

  void hardDrop() {
    if (isPaused || isGameOver || current == null) return;
    int distance = 0;
    while (true) {
      final nextPiece = current!.copyWith(position: PointInt(current!.position.x, current!.position.y + 1));
      if (_collides(nextPiece)) break;
      current = nextPiece;
      distance++;
    }
    _lockPiece();
    // optional drop score
    score += distance * 2;
    notifyListeners();
  }

  // Called each tick
  void tick() {
    if (isPaused || isGameOver) return;
    if (!softDrop()) {
      _lockPiece();
    }
  }

  void _lockPiece() {
    if (current == null) return;
    bool gameOverDetected = false;
    for (final c in _cells(current!)) {
      if (c.y < 0 || c.y >= height || c.x < 0 || c.x >= width) {
        isGameOver = true;
        gameOverDetected = true;
        continue;
      }
      board[c.y][c.x] = colorFor[current!.type];
    }
    final cleared = _clearLines();
    if (cleared > 0) {
      linesCleared += cleared;
      // Basic scoring similar to falling blocks guideline (simplified)
      final lineScore = [0, 100, 300, 500, 800][cleared];
      score += lineScore * level;
      // increase level every 10 lines
      level = 1 + (linesCleared ~/ 10);
    }
    _spawn();
    
    // Notify listeners if game over was detected during piece locking
    if (gameOverDetected) {
      notifyListeners();
    }
  }

  int _clearLines() {
    int cleared = 0;
    for (int y = height - 1; y >= 0; y--) {
      if (board[y].every((cell) => cell != null)) {
        cleared += 1;
        // shift down
        for (int yy = y; yy > 0; yy--) {
          board[yy] = List<int?>.from(board[yy - 1]);
        }
        board[0] = List<int?>.filled(width, null);
        y++; // recheck this row after shifting
      }
    }
    return cleared;
  }

  Duration currentSpeed() {
    // Speed up with level, clamp to min 100ms
    final baseMs = 800 - (level - 1) * 50;
    return Duration(milliseconds: baseMs.clamp(100, 800));
  }

  // Helper to get all filled cells and ghost for painter
  Iterable<List<int>> filledCellsWithGhost() sync* {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final v = board[y][x];
        if (v != null) yield [x, y, v];
      }
    }
    // add current piece
    if (current != null) {
      final ghost = _computeGhost();
      for (final c in _cells(current!)) {
        yield [c.x, c.y, colorFor[current!.type]!];
      }
      // encode ghost with negative color index to differentiate
      for (final c in ghost) {
        yield [c.x, c.y, -colorFor[current!.type]! - 1];
      }
    }
  }

  List<PointInt> _computeGhost() {
    if (current == null) return const [];
    var ghost = current!;
    while (true) {
      final nextPiece = ghost.copyWith(position: PointInt(ghost.position.x, ghost.position.y + 1));
      if (_collides(nextPiece)) break;
      ghost = nextPiece;
    }
    return _cells(ghost);
  }
}
