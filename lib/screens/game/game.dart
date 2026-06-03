import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pandabricks/models/game_types.dart';
import 'package:pandabricks/providers/audio_provider.dart';

export 'package:pandabricks/models/game_types.dart';

part 'game_engine.dart';
part 'special_blocks.dart';
part 'game_effects.dart';

class _Effect {
  const _Effect({required this.x, required this.y, required this.type, required this.start});
  final int x;
  final int y;
  final EffectType type;
  final int start;
}

class Game extends ChangeNotifier {

  Game({
    required this.audioProvider, int? width,
    int? height,
    this.gameMode = GameMode.classic,
    this.customConfig,
  }) :
    width = customConfig?.boardWidth ?? width ?? 10,
    height = customConfig?.boardHeight ?? height ?? 20 {
    _resetBoard();
    _refillBag();
    next = _drawFromBag();
    _spawn();
    final initialTimeLimit = configuredTimeLimitFor(gameMode, customConfig);
    if (initialTimeLimit != null) {
      timeRemaining = initialTimeLimit;
      gameStartTime = DateTime.now();
    }
    if (customConfig != null && customConfig!.startingLevel > 1) {
      level = customConfig!.startingLevel;
      linesCleared = (level - 1) * 10;
    }
  }
  final int width;
  final int height;
  final AudioProvider audioProvider;
  final GameMode gameMode;
  final CustomGameConfig? customConfig;

  int _version = 0;

  int get version => _version;

  bool _disposed = false;

  static const int effectDurationMs = 500;
  static const int baseSpeedMs = 800;
  static const int speedLevelDecrement = 50;
  static const int minSpeedMs = 50;
  static const int maxSpeedMs = 2000;

  static const List<int> lineClearScores = [0, 100, 300, 500, 800, 1200, 1600, 2000, 2400, 3000];
  static const int pandaBrickBonus = 200;
  static const int bombBrickBonus = 500;

  late List<List<int?>> board;
  ActivePiece? current;
  FallingBlock? next;
  bool isGameOver = false;
  bool isPaused = false;

  int score = 0;
  int linesCleared = 0;
  int level = 1;

  Duration? timeRemaining;
  DateTime? gameStartTime;

  final Random _rng = Random();
  final List<FallingBlock> _bag = [];
  final List<_Effect> _effects = [];
  int _effectGeneration = 0;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    _version++;
    super.notifyListeners();
  }

  static const Map<FallingBlock, int> colorFor = {
    FallingBlock.I: 0,
    FallingBlock.O: 1,
    FallingBlock.T: 2,
    FallingBlock.S: 3,
    FallingBlock.Z: 4,
    FallingBlock.J: 5,
    FallingBlock.L: 6,
    FallingBlock.PANDA: 7,
    FallingBlock.GHOST: 8,
    FallingBlock.CAT: 9,
    FallingBlock.TORNADO: 10,
    FallingBlock.BOMB: 11,
  };

  void _resetBoard() {
    board = List.generate(height, (_) => List<int?>.filled(width, null));
    isGameOver = false;
    isPaused = false;
    score = 0;
    linesCleared = 0;
    level = 1;
    final initialTimeLimit = configuredTimeLimitFor(gameMode, customConfig);
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
    _effects.clear();
    _effectGeneration++;
    if (_bag.isEmpty) _refillBag();
    next ??= _drawFromBag();
    _spawn();
    notifyListeners();
  }

  void togglePause() {
    if (isGameOver) return;
    final totalDuration = configuredTimeLimitFor(gameMode, customConfig);
    if (totalDuration != null && gameStartTime != null) {
      if (!isPaused) {
        final elapsed = DateTime.now().difference(gameStartTime!);
        final remaining = totalDuration - elapsed;
        timeRemaining = remaining.isNegative ? Duration.zero : remaining;
      } else if (timeRemaining != null) {
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

  static const _standardPieces = [FallingBlock.I, FallingBlock.O, FallingBlock.T, FallingBlock.S, FallingBlock.Z, FallingBlock.J, FallingBlock.L];
  static const _specialPieces = [FallingBlock.PANDA, FallingBlock.GHOST, FallingBlock.CAT, FallingBlock.TORNADO, FallingBlock.BOMB];
  static const _extraStandardCount = 3;

  void _refillBag() {
    _bag.clear();
    final includeSpecial = gameMode == GameMode.blitz ||
        (gameMode == GameMode.custom && (customConfig?.enableSpecialBricks ?? true));
    _bag.addAll(_standardPieces);
    if (includeSpecial) {
      _bag.addAll(_standardPieces);
      _bag.addAll(_standardPieces.take(_extraStandardCount));
      _bag.addAll(_specialPieces);
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
    final isSpecial = _specialPieces.contains(type);
    final piece = ActivePiece(type: type, rotation: Rotation.up, position: spawnPos, isSpecialBlock: isSpecial);
    if (collidesWithBoard(this, piece)) {
      isGameOver = true;
    } else {
      current = piece;
    }
    notifyListeners();
  }

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
    FallingBlock.PANDA: _singleCell,
    FallingBlock.GHOST: _singleCell,
    FallingBlock.CAT: _squareCell,
    FallingBlock.TORNADO: {
      Rotation.up:    [PointInt(-1, 0), PointInt(0, 0), PointInt(1, 0), PointInt(0, 1)],
      Rotation.right: [PointInt(0, -1), PointInt(0, 0), PointInt(0, 1), PointInt(1, 0)],
      Rotation.down:  [PointInt(-1, 0), PointInt(0, 0), PointInt(1, 0), PointInt(0, -1)],
      Rotation.left:  [PointInt(0, -1), PointInt(0, 0), PointInt(0, 1), PointInt(-1, 0)],
    },
    FallingBlock.BOMB: _singleCell,
  };

  static const _singleCell = {
    Rotation.up:    [PointInt(0, 0)],
    Rotation.right: [PointInt(0, 0)],
    Rotation.down:  [PointInt(0, 0)],
    Rotation.left:  [PointInt(0, 0)],
  };

  static const _squareCell = {
    Rotation.up:    [PointInt(0, 0), PointInt(1, 0), PointInt(0, 1), PointInt(1, 1)],
    Rotation.right: [PointInt(0, 0), PointInt(1, 0), PointInt(0, 1), PointInt(1, 1)],
    Rotation.down:  [PointInt(0, 0), PointInt(1, 0), PointInt(0, 1), PointInt(1, 1)],
    Rotation.left:  [PointInt(0, 0), PointInt(1, 0), PointInt(0, 1), PointInt(1, 1)],
  };

  bool moveLeft() {
    // Ghost brick moves in opposite direction for chaotic behavior
    if (current?.type == FallingBlock.GHOST) {
      return applyMove(this, const PointInt(1, 0));
    }
    return applyMove(this, const PointInt(-1, 0));
  }

  bool moveRight() {
    if (current?.type == FallingBlock.GHOST) {
      return applyMove(this, const PointInt(-1, 0));
    }
    return applyMove(this, const PointInt(1, 0));
  }

  bool softDrop() => applyMove(this, const PointInt(0, 1));

  void rotateCW() {
    if (isPaused || isGameOver || current == null) return;
    final nextRotation = Rotation.values[(current!.rotation.index + 1) % 4];
    final rotated = current!.copyWith(rotation: nextRotation);
    final kicks = [
      const PointInt(0, 0),
      const PointInt(-1, 0),
      const PointInt(1, 0),
      const PointInt(0, -1),
    ];
    for (final k in kicks) {
      final candidate = rotated.copyWith(position: rotated.position + k);
      if (!collidesWithBoard(this, candidate)) {
        current = candidate;
        notifyListeners();
        return;
      }
    }
  }

  void hardDrop() {
    if (isPaused || isGameOver || current == null) return;
    var distance = 0;
    while (true) {
      final nextPiece = current!.copyWith(position: PointInt(current!.position.x, current!.position.y + 1));
      if (collidesWithBoard(this, nextPiece)) break;
      current = nextPiece;
      distance++;
    }
    lockCurrentPiece(this);
    score += (distance * 2 * level * (customConfig?.scoreMultiplier ?? 1.0)).round();
  }

  void tick() {
    if (isPaused || isGameOver) return;
    final totalTimeLimit = configuredTimeLimitFor(gameMode, customConfig);
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
    applySpecialBehaviors(this);
    if (!softDrop()) {
      lockCurrentPiece(this);
    }
  }

  int clearLines() {
    var cleared = 0;
    final clearedRows = <int>[];
    var y = height - 1;
    while (y >= 0) {
      if (board[y].every((cell) => cell != null)) {
        cleared += 1;
        clearedRows.add(y);
        for (var yy = y; yy > 0; yy--) {
          board[yy] = List<int?>.from(board[yy - 1]);
        }
        board[0] = List<int?>.filled(width, null);
      } else {
        y--;
      }
    }
    for (final rowY in clearedRows) {
      triggerRowEffect(this, rowY);
    }
    if (cleared > 0) {
      audioProvider.playSfx(GameSfx.rowClear);
    }
    return cleared;
  }

  Duration currentSpeed() {
    final baseMs = baseSpeedMs - (level - 1) * speedLevelDecrement;
    final speedMs = (baseMs / (customConfig?.speedMultiplier ?? 1.0)).clamp(minSpeedMs, maxSpeedMs).toInt();
    return Duration(milliseconds: speedMs);
  }

  Iterable<CellRender> filledCellsWithGhost() sync* {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final v = board[y][x];
        if (v != null) yield CellRender(x: x, y: y, colorIndex: v, isGhost: false);
      }
    }
    if (current != null) {
      final ghost = calculateGhost(this);
      for (final c in cells(current!)) {
        yield CellRender(x: c.x, y: c.y, colorIndex: colorFor[current!.type]!, isGhost: false);
      }
      for (final c in ghost) {
        yield CellRender(x: c.x, y: c.y, colorIndex: colorFor[current!.type]!, isGhost: true);
      }
    }
  }

  Iterable<EffectRender> currentEffects() sync* {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final e in _effects) {
      final elapsed = (now - e.start).clamp(0, effectDurationMs);
      final t = elapsed / effectDurationMs;
      final alpha = (160 * (1 - t)).toInt().clamp(0, 160);
      yield EffectRender(x: e.x, y: e.y, type: e.type, alpha: alpha);
    }
  }

  static Duration? configuredTimeLimitFor(GameMode mode, CustomGameConfig? config) {
    if (mode == GameMode.timeChallenge) {
      return const Duration(minutes: 5);
    }
    if (mode == GameMode.custom) {
      return config?.timeLimit;
    }
    return null;
  }

  List<PointInt> cells(ActivePiece piece) {
    final offsets = shapes[piece.type]![piece.rotation]!;
    return offsets.map((o) => piece.position + o).toList(growable: false);
  }
}
