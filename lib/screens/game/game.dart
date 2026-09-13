import 'dart:async';
import 'dart:math';

import 'package:pandabricks/models/game_types.dart';
import 'package:pandabricks/providers/audio_provider.dart';

export 'package:pandabricks/models/game_types.dart';

part 'game_engine.dart';
part 'special_blocks.dart';
part 'game_effects.dart';

class _Effect {
  const _Effect({
    required this.x,
    required this.y,
    required this.type,
    required this.start,
  });
  final int x;
  final int y;
  final EffectType type;
  final int start;
}

class Game {
  Game({
    required this.audioProvider,
    int? width,
    int? height,
    this.gameMode = GameMode.classic,
    this.customConfig,
  }) : width = customConfig?.boardWidth ?? width ?? 10,
       height = customConfig?.boardHeight ?? height ?? 20 {
    _resetBoard();
    _refillBag();
    next = _drawFromBag();
    _spawn();
  }
  final int width;
  final int height;
  final AudioProvider audioProvider;
  final GameMode gameMode;
  final CustomGameConfig? customConfig;

  /// Current game clock in milliseconds since the last reset. Only advances
  /// while the game is neither paused nor over, so pausing never leaks time.
  int _clock = 0;

  /// Clock value at which the current timed run started. Null in untimed modes.
  int? _timeStartClock;

  /// Clock value captured when the game was paused, used to exclude the paused
  /// period from the elapsed time when resuming.
  int? _pauseStartClock;

  static const int effectDurationMs = 500;
  static const int baseSpeedMs = 800;
  static const int speedLevelDecrement = 50;
  static const int minSpeedMs = 50;
  static const int maxSpeedMs = 2000;

  static const List<int> lineClearScores = [
    0,
    100,
    300,
    500,
    800,
    1200,
    1600,
    2000,
    2400,
    3000,
  ];
  static const int pandaBrickBonus = 200;
  static const int bombBrickBonus = 500;

  /// Combo bonus per cleared line, multiplied by (combo - 1).
  static const int comboBonusPerLine = 50;

  /// Bonus applied when two consecutive clears are both difficult (tetris or
  /// BOMB).
  static const int backToBackBonus = 100;

  late List<List<int?>> board;
  ActivePiece? current;
  FallingBlock? next;
  bool isGameOver = false;
  bool isPaused = false;

  /// Invoked with the cells of a piece right after it locks. Used by the
  /// Flame layer to spawn lock-dust particles without coupling the sim to
  /// rendering.
  void Function(List<PointInt> cells)? onPieceLocked;

  /// Invoked when a combo or back-to-back streak deserves a popup. Fired from
  /// clearLines with the current combo and back-to-back state.
  // The bool flag is part of the documented callback contract, not a boolean
  // function argument, so the positional-flag lint does not apply.
  // ignore: avoid_positional_boolean_parameters
  void Function(int combo, bool backToBack)? onCombo;

  /// Invoked on big clears (BOMB, tetris, 3+ lines) so the Flame layer can
  /// shake the camera.
  void Function()? onBigClear;

  int score = 0;
  int linesCleared = 0;
  int level = 1;

  /// Counts consecutive clearing drops. Resets to 0 whenever a drop clears
  /// nothing.
  int combo = 0;

  /// True while two consecutive clears were both difficult (tetris or BOMB).
  bool backToBack = false;

  /// The piece stashed by swapHold. Null until the first swap.
  FallingBlock? hold;

  /// Whether swapHold was used for the current drop. Reset on lock.
  bool holdUsed = false;

  bool _previousClearWasDifficult = false;

  Duration? timeRemaining;

  final Random _rng = Random();
  final List<FallingBlock> _bag = [];
  final List<_Effect> _effects = [];

  void _resetBoard() {
    board = List.generate(height, (_) => List<int?>.filled(width, null));
    isGameOver = false;
    isPaused = false;
    score = 0;
    linesCleared = 0;
    level = 1;
    if (customConfig case CustomGameConfig(:final startingLevel)) {
      level = startingLevel;
      linesCleared = (startingLevel - 1) * 10;
    }
    _clock = 0;
    _pauseStartClock = null;
    combo = 0;
    backToBack = false;
    hold = null;
    holdUsed = false;
    _previousClearWasDifficult = false;
    final initialTimeLimit = configuredTimeLimitFor(gameMode, customConfig);
    if (initialTimeLimit != null) {
      timeRemaining = initialTimeLimit;
      _timeStartClock = 0;
    } else {
      timeRemaining = null;
      _timeStartClock = null;
    }
  }

  void reset() {
    _resetBoard();
    _effects.clear();
    if (_bag.isEmpty) _refillBag();
    next ??= _drawFromBag();
    _spawn();
  }

  void togglePause() {
    if (isGameOver) return;
    final totalDuration = configuredTimeLimitFor(gameMode, customConfig);
    if (totalDuration != null && _timeStartClock != null) {
      if (!isPaused) {
        final elapsed = Duration(
          milliseconds: (_clock - _timeStartClock!).clamp(
            0,
            totalDuration.inMilliseconds,
          ),
        );
        timeRemaining = totalDuration - elapsed;
        _pauseStartClock = _clock;
      } else if (_pauseStartClock != null) {
        // Resume: shift the start clock forward by the paused duration so the
        // paused period is excluded from the elapsed time.
        _timeStartClock = _timeStartClock! + (_clock - _pauseStartClock!);
        _pauseStartClock = null;
      }
    }
    isPaused = !isPaused;
  }

  static const List<FallingBlock> _standardPieces = [
    FallingBlock.I,
    FallingBlock.O,
    FallingBlock.T,
    FallingBlock.S,
    FallingBlock.Z,
    FallingBlock.J,
    FallingBlock.L,
  ];
  static const List<FallingBlock> _specialPieces = [
    FallingBlock.PANDA,
    FallingBlock.GHOST,
    FallingBlock.CAT,
    FallingBlock.TORNADO,
    FallingBlock.BOMB,
  ];
  static const _extraStandardCount = 3;

  void _refillBag() {
    _bag.clear();
    final includeSpecial =
        gameMode == GameMode.blitz ||
        (gameMode == GameMode.custom &&
            (customConfig?.enableSpecialBricks ?? true));
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
    final piece = ActivePiece(
      type: type,
      rotation: Rotation.up,
      position: spawnPos,
      isSpecialBlock: isSpecial,
    );
    if (collidesWithBoard(this, piece)) {
      isGameOver = true;
    } else {
      current = piece;
    }
  }

  /// Stashes the active piece and pulls the held piece (if any), or draws a
  /// fresh piece from the bag on the first swap. Usable once per drop.
  void swapHold() {
    if (isPaused || isGameOver || current == null || holdUsed) return;
    final currentType = current!.type;
    if (hold == null) {
      hold = currentType;
      _spawn();
    } else {
      final incoming = hold!;
      hold = currentType;
      final piece = ActivePiece(
        type: incoming,
        rotation: Rotation.up,
        position: PointInt(width ~/ 2, 1),
        isSpecialBlock: _specialPieces.contains(incoming),
      );
      if (collidesWithBoard(this, piece)) {
        isGameOver = true;
      } else {
        current = piece;
      }
    }
    holdUsed = true;
  }

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
        return;
      }
    }
  }

  void hardDrop() {
    if (isPaused || isGameOver || current == null) return;
    var distance = 0;
    while (true) {
      final nextPiece = current!.copyWith(
        position: PointInt(current!.position.x, current!.position.y + 1),
      );
      if (collidesWithBoard(this, nextPiece)) break;
      current = nextPiece;
      distance++;
    }
    lockCurrentPiece(this);
    score += (distance * 2 * level * (customConfig?.scoreMultiplier ?? 1.0))
        .round();
  }

  /// Advances the clock to [clock] and updates the timed-mode countdown.
  /// Called every frame by the game loop. Sets [isGameOver] when time runs out.
  void advanceTime(int clock) {
    _clock = clock;
    final totalTimeLimit = configuredTimeLimitFor(gameMode, customConfig);
    if (totalTimeLimit != null && _timeStartClock != null) {
      final elapsed = Duration(
        milliseconds: (clock - _timeStartClock!).clamp(
          0,
          totalTimeLimit.inMilliseconds,
        ),
      );
      timeRemaining = totalTimeLimit - elapsed;
      if (timeRemaining == Duration.zero) {
        isGameOver = true;
      }
    }
  }

  void tick(int clock) {
    if (isPaused || isGameOver) return;
    _clock = clock;
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
      triggerRowFlashEffect(this, rowY);
    }
    if (cleared > 0) {
      unawaited(audioProvider.playSfx(GameSfx.rowClear));
      combo++;
      final difficult = cleared >= 4;
      _updateClearStreak(difficult: difficult);
      score +=
          (cleared *
                  comboBonusPerLine *
                  (combo - 1) *
                  level *
                  (customConfig?.scoreMultiplier ?? 1.0))
              .round();
      if (cleared >= 3) onBigClear?.call();
      // Only surface a combo popup from the second consecutive clear onward;
      // a lone single clear (combo == 1) should not pop, and B2B is shown as a
      // suffix only when there is an actual combo.
      if (combo >= 2) onCombo?.call(combo, backToBack);
    } else {
      combo = 0;
    }
    return cleared;
  }

  /// Tracks the back-to-back streak across consecutive difficult clears
  /// (tetris or BOMB). A non-difficult clear resets the streak.
  void _updateClearStreak({required bool difficult}) {
    if (difficult && _previousClearWasDifficult) {
      backToBack = true;
      score +=
          (backToBackBonus * level * (customConfig?.scoreMultiplier ?? 1.0))
              .round();
    } else if (!difficult) {
      backToBack = false;
    }
    _previousClearWasDifficult = difficult;
  }

  /// Marks a BOMB clear as a difficult clear for back-to-back tracking and
  /// signals the big-clear callback.
  void recordBombClear() {
    _updateClearStreak(difficult: true);
    onBigClear?.call();
  }

  Duration currentSpeed() {
    final baseMs = baseSpeedMs - (level - 1) * speedLevelDecrement;
    final speedMs = (baseMs / (customConfig?.speedMultiplier ?? 1.0))
        .clamp(minSpeedMs, maxSpeedMs)
        .toInt();
    return Duration(milliseconds: speedMs);
  }

  Iterable<CellRender> filledCellsWithGhost() => _computeFilledCellsWithGhost();

  List<CellRender> _computeFilledCellsWithGhost() {
    final result = <CellRender>[];
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final v = board[y][x];
        if (v != null) {
          result.add(CellRender(x: x, y: y, colorIndex: v, isGhost: false));
        }
      }
    }
    if (current != null) {
      final ghost = calculateGhost(this);
      final colorIndex = colorFor[current!.type]!;
      final position = current!.position;
      final offsets = shapes[current!.type]![current!.rotation]!;
      for (final offset in offsets) {
        final c = position + offset;
        result.add(
          CellRender(x: c.x, y: c.y, colorIndex: colorIndex, isGhost: false),
        );
      }
      for (final c in ghost) {
        result.add(
          CellRender(x: c.x, y: c.y, colorIndex: colorIndex, isGhost: true),
        );
      }
    }
    return result;
  }

  Iterable<EffectRender> currentEffects(int clock) sync* {
    for (final e in _effects) {
      final elapsed = (clock - e.start).clamp(0, effectDurationMs);
      final t = elapsed / effectDurationMs;
      final alpha = (160 * (1 - t)).toInt().clamp(0, 160);
      yield EffectRender(x: e.x, y: e.y, type: e.type, alpha: alpha);
    }
  }

  /// Removes effects whose lifetime has exceeded [effectDurationMs]. Called
  /// every frame by the game loop, replacing the old `Future.delayed` chain.
  void pruneEffects(int clock) {
    _effects.removeWhere((e) => clock - e.start > effectDurationMs);
  }

  static Duration? configuredTimeLimitFor(
    GameMode mode,
    CustomGameConfig? config,
  ) {
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
    final result = List<PointInt>.filled(offsets.length, piece.position);
    for (var i = 0; i < offsets.length; i++) {
      result[i] = piece.position + offsets[i];
    }
    return result;
  }
}
