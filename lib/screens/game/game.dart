import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pandabricks/providers/audio_provider.dart';

enum Rotation { up, right, down, left }

enum GameMode { classic, timeChallenge, blitz, custom }

class CustomGameConfig {
  static const Duration _unsetDuration = Duration(days: -1);
  final Duration? timeLimit; // null for unlimited
  final int startingLevel;
  final double speedMultiplier;
  final double scoreMultiplier;
  final bool enableSpecialBricks;
  final int boardWidth;
  final int boardHeight;

  const CustomGameConfig({
    this.timeLimit,
    this.startingLevel = 1,
    this.speedMultiplier = 1.0,
    this.scoreMultiplier = 1.0,
    this.enableSpecialBricks = true,
    this.boardWidth = 10,
    this.boardHeight = 20,
  });

  CustomGameConfig copyWith({
    Duration? timeLimit = _unsetDuration,
    int? startingLevel,
    double? speedMultiplier,
    double? scoreMultiplier,
    bool? enableSpecialBricks,
    int? boardWidth,
    int? boardHeight,
  }) {
    return CustomGameConfig(
      timeLimit: timeLimit == _unsetDuration ? this.timeLimit : timeLimit,
      startingLevel: startingLevel ?? this.startingLevel,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      scoreMultiplier: scoreMultiplier ?? this.scoreMultiplier,
      enableSpecialBricks: enableSpecialBricks ?? this.enableSpecialBricks,
      boardWidth: boardWidth ?? this.boardWidth,
      boardHeight: boardHeight ?? this.boardHeight,
    );
  }
}

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
  final bool isSpecialBlock;
  final int lastMoveY; // Track Y position for cat brick auto-movement

  const ActivePiece({
    required this.type,
    required this.rotation,
    required this.position,
    this.isSpecialBlock = false,
    this.lastMoveY = -1,
  });

  ActivePiece copyWith({FallingBlock? type, Rotation? rotation, PointInt? position, bool? isSpecialBlock, int? lastMoveY}) {
    return ActivePiece(
      type: type ?? this.type,
      rotation: rotation ?? this.rotation,
      position: position ?? this.position,
      isSpecialBlock: isSpecialBlock ?? this.isSpecialBlock,
      lastMoveY: lastMoveY ?? this.lastMoveY,
    );
  }
}

enum FallingBlock { 
  I, O, T, S, Z, J, L, 
  // Special blitz mode blocks
  pandaBrick, ghostBrick, catBrick, tornadoBrick, bombBrick 
}

class Game extends ChangeNotifier {
  final int width;
  final int height;
  final AudioProvider audioProvider;
  final GameMode gameMode;
  final CustomGameConfig? customConfig;

  // Game timing constants (milliseconds)
  static const int effectDurationMs = 500;
  static const int baseSpeedMs = 800;
  static const int speedLevelDecrement = 50;
  static const int minSpeedMs = 50;
  static const int maxSpeedMs = 2000;

  // Scoring constants
  static const List<int> lineClearScores = [0, 100, 300, 500, 800];
  static const int pandaBrickBonus = 200;
  static const int bombBrickBonus = 500;

  late List<List<int?>> board; // height x width, stores color index or null
  ActivePiece? current;
  FallingBlock? next;
  bool isGameOver = false;
  bool isPaused = false;

  int score = 0;
  int linesCleared = 0;
  int level = 1;

  // Time challenge specific properties
  Duration? timeRemaining;
  DateTime? gameStartTime;

  final Random _rng = Random();
  final List<FallingBlock> _bag = [];
  // Temporary visual effects (store start time so we can animate fades)
  // Each effect is a map: {'x':int, 'y':int, 'type':int, 'start':ms}
  // type: 0 = column clear, 1 = row clear
  final List<Map<String, int>> _effects = [];

  // Colors indices map for painter; 0..n
  static const Map<FallingBlock, int> colorFor = {
    FallingBlock.I: 0,
    FallingBlock.O: 1,
    FallingBlock.T: 2,
    FallingBlock.S: 3,
    FallingBlock.Z: 4,
    FallingBlock.J: 5,
    FallingBlock.L: 6,
    // Special blitz blocks
    FallingBlock.pandaBrick: 7,
    FallingBlock.ghostBrick: 8,
    FallingBlock.catBrick: 9,
    FallingBlock.tornadoBrick: 10,
    FallingBlock.bombBrick: 11,
  };

  Game({
    int? width,
    int? height,
    required this.audioProvider,
    this.gameMode = GameMode.classic,
    this.customConfig,
  }) : 
    width = customConfig?.boardWidth ?? width ?? 10,
    height = customConfig?.boardHeight ?? height ?? 20 {
    // Initialize board with correct dimensions
    _resetBoard();
    
    _refillBag();
    next = _drawFromBag();
    _spawn();
    
    // Initialize time challenge if applicable
    final initialTimeLimit = _configuredTimeLimit;
    if (initialTimeLimit != null) {
      timeRemaining = initialTimeLimit;
      gameStartTime = DateTime.now();
    }
    
    // Apply custom starting level
    if (customConfig != null && customConfig!.startingLevel > 1) {
      level = customConfig!.startingLevel;
      linesCleared = (level - 1) * 10; // Set lines cleared to match the level
    }
  }

  void _resetBoard() {
    board = List.generate(height, (_) => List<int?>.filled(width, null));
    isGameOver = false;
    isPaused = false;
    score = 0;
    linesCleared = 0;
    level = 1;
    
    final initialTimeLimit = _configuredTimeLimit;
    if (initialTimeLimit != null) {
      timeRemaining = initialTimeLimit;
      gameStartTime = DateTime.now();
    } else {
      timeRemaining = null;
      gameStartTime = null;
    }
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
    
    final totalDuration = _configuredTimeLimit;
    if (totalDuration != null && gameStartTime != null) {
      if (!isPaused) {
        // Pausing - capture the remaining time based on elapsed duration
        final elapsed = DateTime.now().difference(gameStartTime!);
        final remaining = totalDuration - elapsed;
        timeRemaining = remaining.isNegative ? Duration.zero : remaining;
      } else if (timeRemaining != null) {
        // Resuming - rebuild the start time so ticking logic keeps consistent elapsed tracking
        final elapsed = totalDuration - timeRemaining!;
        gameStartTime = DateTime.now().subtract(elapsed);
      } else {
        timeRemaining = totalDuration;
        gameStartTime = DateTime.now();
      }
    }
    
    isPaused = !isPaused;
    notifyListeners();
  }

  void _refillBag() {
    _bag.clear();
    
    final shouldIncludeSpecial = (gameMode == GameMode.blitz) || 
                                (gameMode == GameMode.custom && (customConfig?.enableSpecialBricks ?? true));
    
    if (shouldIncludeSpecial) {
      // Include regular pieces + special pieces
      // 70% regular pieces, 30% special pieces
      _bag.addAll([FallingBlock.I, FallingBlock.O, FallingBlock.T, FallingBlock.S, FallingBlock.Z, FallingBlock.J, FallingBlock.L]);
      _bag.addAll([FallingBlock.I, FallingBlock.O, FallingBlock.T, FallingBlock.S, FallingBlock.Z, FallingBlock.J, FallingBlock.L]);
      _bag.addAll([FallingBlock.I, FallingBlock.O, FallingBlock.T]);
      
      // Add special pieces
      _bag.addAll([FallingBlock.pandaBrick, FallingBlock.ghostBrick, FallingBlock.catBrick, FallingBlock.tornadoBrick, FallingBlock.bombBrick]);
    } else {
      // Classic, time challenge, or custom with special bricks disabled - only regular pieces
      _bag.addAll([FallingBlock.I, FallingBlock.O, FallingBlock.T, FallingBlock.S, FallingBlock.Z, FallingBlock.J, FallingBlock.L]);
    }
    
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
    final isSpecial = [FallingBlock.pandaBrick, FallingBlock.ghostBrick, FallingBlock.catBrick, FallingBlock.tornadoBrick, FallingBlock.bombBrick].contains(type);
    final piece = ActivePiece(type: type, rotation: Rotation.up, position: spawnPos, isSpecialBlock: isSpecial);
    if (_collides(piece)) {
      isGameOver = true;
      notifyListeners(); // Notify listeners when game over state changes
    } else {
      current = piece;
      notifyListeners(); // Notify listeners immediately when piece spawns
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
    // Special blitz mode blocks
    FallingBlock.pandaBrick: {
      Rotation.up: [PointInt(0, 0)],
      Rotation.right: [PointInt(0, 0)],
      Rotation.down: [PointInt(0, 0)],
      Rotation.left: [PointInt(0, 0)],
    },
    FallingBlock.ghostBrick: {
      Rotation.up: [PointInt(0, 0)],
      Rotation.right: [PointInt(0, 0)],
      Rotation.down: [PointInt(0, 0)],
      Rotation.left: [PointInt(0, 0)],
    },
    FallingBlock.catBrick: {
      Rotation.up: [PointInt(0, 0), PointInt(1, 0), PointInt(0, 1), PointInt(1, 1)],
      Rotation.right: [PointInt(0, 0), PointInt(1, 0), PointInt(0, 1), PointInt(1, 1)],
      Rotation.down: [PointInt(0, 0), PointInt(1, 0), PointInt(0, 1), PointInt(1, 1)],
      Rotation.left: [PointInt(0, 0), PointInt(1, 0), PointInt(0, 1), PointInt(1, 1)],
    },
    FallingBlock.tornadoBrick: {
      Rotation.up: [PointInt(-1, 0), PointInt(0, 0), PointInt(1, 0), PointInt(0, 1)],
      Rotation.right: [PointInt(0, -1), PointInt(0, 0), PointInt(0, 1), PointInt(1, 0)],
      Rotation.down: [PointInt(-1, 0), PointInt(0, 0), PointInt(1, 0), PointInt(0, -1)],
      Rotation.left: [PointInt(0, -1), PointInt(0, 0), PointInt(0, 1), PointInt(-1, 0)],
    },
    FallingBlock.bombBrick: {
      Rotation.up: [PointInt(0, 0)],
      Rotation.right: [PointInt(0, 0)],
      Rotation.down: [PointInt(0, 0)],
      Rotation.left: [PointInt(0, 0)],
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

  bool moveLeft() {
    // Ghost brick has reversed controls
    if (current?.type == FallingBlock.ghostBrick) {
      return _tryMove(const PointInt(1, 0));
    }
    return _tryMove(const PointInt(-1, 0));
  }
  
  bool moveRight() {
    // Ghost brick has reversed controls
    if (current?.type == FallingBlock.ghostBrick) {
      return _tryMove(const PointInt(-1, 0));
    }
    return _tryMove(const PointInt(1, 0));
  }
  
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
    score += (distance * 2 * (customConfig?.scoreMultiplier ?? 1.0)).toInt();
    notifyListeners();
  }

  // Called each tick
  void tick() {
    if (isPaused || isGameOver) return;
    
    final totalTimeLimit = _configuredTimeLimit;
    if (totalTimeLimit != null && gameStartTime != null) {
      final elapsed = DateTime.now().difference(gameStartTime!);
      final remaining = totalTimeLimit - elapsed;
      timeRemaining = remaining.isNegative ? Duration.zero : remaining;
      
      if (timeRemaining == Duration.zero) {
        isGameOver = true;
        notifyListeners();
        return;
      }
    }
    
    // Handle special block behaviors before normal drop
    _handleSpecialBlockBehaviors();
    
    if (!softDrop()) {
      _lockPiece();
    }
  }

  void _handleSpecialBlockBehaviors() {
    if (current == null || !current!.isSpecialBlock) return;

    // Cat brick: moves randomly left, right, or stays in place as it falls
    if (current!.type == FallingBlock.catBrick) {
      if (current!.lastMoveY != current!.position.y) {
        final movement = _rng.nextInt(3) - 1; // -1, 0, or 1
        if (movement != 0) {
          final newPos = current!.position + PointInt(movement, 0);
          final candidate = current!.copyWith(position: newPos, lastMoveY: current!.position.y);
          if (!_collides(candidate)) {
            current = candidate;
          } else {
            current = current!.copyWith(lastMoveY: current!.position.y);
          }
        } else {
          current = current!.copyWith(lastMoveY: current!.position.y);
        }
      }
    }
    
    // Tornado brick: rotates automatically as it falls
    if (current!.type == FallingBlock.tornadoBrick) {
      if (current!.lastMoveY != current!.position.y) {
        final nextRotation = Rotation.values[(current!.rotation.index + 1) % 4];
        final rotated = current!.copyWith(rotation: nextRotation, lastMoveY: current!.position.y);
        if (!_collides(rotated)) {
          current = rotated;
        } else {
          current = current!.copyWith(lastMoveY: current!.position.y);
        }
      }
    }
  }

  void _lockPiece() {
    if (current == null) return;
    bool gameOverDetected = false;
    
    // Handle special block effects before placing on board
    if (current!.isSpecialBlock) {
      _handleSpecialBlockEffects();
    } else {
      // Normal block placement
      for (final c in _cells(current!)) {
        if (c.y < 0 || c.y >= height || c.x < 0 || c.x >= width) {
          isGameOver = true;
          gameOverDetected = true;
          continue;
        }
        board[c.y][c.x] = colorFor[current!.type];
      }
    }
    
    final cleared = _clearLines();
    if (cleared > 0) {
      linesCleared += cleared;
      // Basic scoring similar to falling blocks guideline (simplified)
      final lineScore = lineClearScores[cleared];
      final baseScore = lineScore * level;
      score += (baseScore * (customConfig?.scoreMultiplier ?? 1.0)).toInt();
      // increase level every 10 lines
      level = 1 + (linesCleared ~/ 10);
    }
    _spawn();
    
    // Notify listeners if game over was detected during piece locking
    if (gameOverDetected) {
      notifyListeners();
    }
  }

  void _handleSpecialBlockEffects() {
    if (current == null) return;
    final cells = _cells(current!);
    
    switch (current!.type) {
      case FallingBlock.pandaBrick:
        // Clear the entire column where panda brick lands
        for (final c in cells) {
          if (c.x >= 0 && c.x < width) {
            _clearColumn(c.x);
          }
        }
        // Award bonus points for column clear
        score += pandaBrickBonus;
        audioProvider.playSfx(GameSfx.columnClear);
        break;
        
      case FallingBlock.bombBrick:
        // Clear the row and column where bomb brick lands (like Bomberman)
        for (final c in cells) {
          if (c.y >= 0 && c.y < height && c.x >= 0 && c.x < width) {
            _clearRow(c.y);
            _clearColumn(c.x);
          }
        }
        // Award bonus points for bomb explosion
        score += bombBrickBonus;
        audioProvider.playSfx(GameSfx.bombExplosion);
        break;
        
      default:
        // Other special blocks (Ghost, Cat, Tornado) behave like normal blocks when locked
        for (final c in cells) {
          if (c.y < 0 || c.y >= height || c.x < 0 || c.x >= width) {
            isGameOver = true;
            continue;
          }
          board[c.y][c.x] = colorFor[current!.type];
        }
        break;
    }
  }

  void _clearColumn(int x) {
    // Clear column cells
    for (int y = 0; y < height; y++) {
      board[y][x] = null;
    }
    // Trigger visual effect for this column
    _triggerColumnEffect(x);
  }

  void _clearRow(int y) {
    // Clear row cells
    for (int x = 0; x < width; x++) {
      board[y][x] = null;
    }
    // Trigger visual effect for this row
    _triggerRowEffect(y);
  }

  // Public accessor for painter
  Iterable<List<int>> currentEffects() sync* {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final e in _effects) {
      final start = e['start'] ?? now;
      final elapsed = (now - start).clamp(0, effectDurationMs);
      final t = elapsed / effectDurationMs;
      // alpha goes from 160 -> 0
      final alpha = (160 * (1 - t)).toInt().clamp(0, 160);
      yield [e['x']!, e['y']!, e['type']!, alpha];
    }
  }

  void _triggerColumnEffect(int x) {
    // Don't clear all effects - just remove old effects for this column
    _effects.removeWhere((e) => e['type'] == 0 && e['x'] == x);
    final start = DateTime.now().millisecondsSinceEpoch;
    for (int y = 0; y < height; y++) {
      _effects.add({'x': x, 'y': y, 'type': 0, 'start': start});
    }
    notifyListeners();
    // Schedule cleanup after animation duration
    // The animation itself is driven by the game tick timer in GameScreen
    Future.delayed(const Duration(milliseconds: effectDurationMs), () {
      _effects.removeWhere((e) => e['type'] == 0 && e['x'] == x && e['start'] == start);
      notifyListeners();
    });
  }

  void _triggerRowEffect(int y) {
    // Don't clear all effects - just remove old effects for this row
    _effects.removeWhere((e) => e['type'] == 1 && e['y'] == y);
    final start = DateTime.now().millisecondsSinceEpoch;
    for (int x = 0; x < width; x++) {
      _effects.add({'x': x, 'y': y, 'type': 1, 'start': start});
    }
    notifyListeners();
    // Schedule cleanup after animation duration
    // The animation itself is driven by the game tick timer in GameScreen
    Future.delayed(const Duration(milliseconds: effectDurationMs), () {
      _effects.removeWhere((e) => e['type'] == 1 && e['y'] == y && e['start'] == start);
      notifyListeners();
    });
  }

  int _clearLines() {
    int cleared = 0;
    List<int> clearedRows = []; // Track which rows get cleared for effects
    
    for (int y = height - 1; y >= 0; y--) {
      if (board[y].every((cell) => cell != null)) {
        cleared += 1;
        clearedRows.add(y); // Record this row for sparkle effect
        
        // shift down
        for (int yy = y; yy > 0; yy--) {
          board[yy] = List<int?>.from(board[yy - 1]);
        }
        board[0] = List<int?>.filled(width, null);
        y++; // recheck this row after shifting
      }
    }
    
    // Trigger sparkle effects for all cleared rows
    for (final rowY in clearedRows) {
      _triggerRowEffect(rowY);
    }
    
    return cleared;
  }

  Duration currentSpeed() {
    // Speed up with level, clamp to min 50ms and max 2000ms
    final baseMs = baseSpeedMs - (level - 1) * speedLevelDecrement;
    final speedMs = (baseMs / (customConfig?.speedMultiplier ?? 1.0)).clamp(minSpeedMs, maxSpeedMs).toInt();
    return Duration(milliseconds: speedMs);
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

  Duration? get _configuredTimeLimit {
    if (gameMode == GameMode.timeChallenge) {
      return const Duration(minutes: 5);
    }
    if (gameMode == GameMode.custom) {
      return customConfig?.timeLimit;
    }
    return null;
  }
}
