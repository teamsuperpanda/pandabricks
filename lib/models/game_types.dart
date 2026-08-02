// Enum naming matches the well-known single-letter Tetris convention (I, O, T, S, Z, J, L)
// with uppercase special-block names for visual consistency within the enum.
// ignore_for_file: constant_identifier_names

enum Rotation { up, right, down, left }

enum GameMode { classic, timeChallenge, blitz, custom }

class CustomGameConfig {
  const CustomGameConfig({
    this.timeLimit,
    int startingLevel = 1,
    double speedMultiplier = 1.0,
    double scoreMultiplier = 1.0,
    this.enableSpecialBricks = true,
    int boardWidth = 10,
    int boardHeight = 20,
  }) : assert(startingLevel >= 1 && startingLevel <= 20),
       assert(speedMultiplier > 0 && speedMultiplier <= 10),
       assert(scoreMultiplier > 0 && scoreMultiplier <= 10),
       assert(boardWidth >= 4 && boardWidth <= 20),
       assert(boardHeight >= 8 && boardHeight <= 40),
       startingLevel = startingLevel < 1
           ? 1
           : startingLevel > 20
           ? 20
           : startingLevel,
       speedMultiplier =
           speedMultiplier != speedMultiplier || speedMultiplier <= 0
           ? 1.0
           : speedMultiplier > 10
           ? 10
           : speedMultiplier,
       scoreMultiplier =
           scoreMultiplier != scoreMultiplier || scoreMultiplier <= 0
           ? 1.0
           : scoreMultiplier > 10
           ? 10
           : scoreMultiplier,
       boardWidth = boardWidth < 4
           ? 4
           : boardWidth > 20
           ? 20
           : boardWidth,
       boardHeight = boardHeight < 8
           ? 8
           : boardHeight > 40
           ? 40
           : boardHeight;

  final Duration? timeLimit;
  final int startingLevel;
  final double speedMultiplier;
  final double scoreMultiplier;
  final bool enableSpecialBricks;
  final int boardWidth;
  final int boardHeight;

  static const _keep = Object();

  CustomGameConfig copyWith({
    Object? timeLimit = _keep,
    int? startingLevel,
    double? speedMultiplier,
    double? scoreMultiplier,
    bool? enableSpecialBricks,
    int? boardWidth,
    int? boardHeight,
  }) {
    return CustomGameConfig(
      timeLimit: identical(timeLimit, _keep)
          ? this.timeLimit
          : timeLimit as Duration?,
      startingLevel: startingLevel ?? this.startingLevel,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      scoreMultiplier: scoreMultiplier ?? this.scoreMultiplier,
      enableSpecialBricks: enableSpecialBricks ?? this.enableSpecialBricks,
      boardWidth: boardWidth ?? this.boardWidth,
      boardHeight: boardHeight ?? this.boardHeight,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomGameConfig &&
          timeLimit == other.timeLimit &&
          startingLevel == other.startingLevel &&
          speedMultiplier == other.speedMultiplier &&
          scoreMultiplier == other.scoreMultiplier &&
          enableSpecialBricks == other.enableSpecialBricks &&
          boardWidth == other.boardWidth &&
          boardHeight == other.boardHeight;

  @override
  int get hashCode => Object.hash(
    timeLimit,
    startingLevel,
    speedMultiplier,
    scoreMultiplier,
    enableSpecialBricks,
    boardWidth,
    boardHeight,
  );

  @override
  String toString() =>
      'CustomGameConfig('
      'timeLimit: $timeLimit, '
      'startingLevel: $startingLevel, '
      'speedMultiplier: $speedMultiplier, '
      'scoreMultiplier: $scoreMultiplier, '
      'enableSpecialBricks: $enableSpecialBricks, '
      'boardWidth: $boardWidth, '
      'boardHeight: $boardHeight)';
}

class PointInt {
  const PointInt(this.x, this.y);
  final int x;
  final int y;

  PointInt operator +(PointInt other) => PointInt(x + other.x, y + other.y);
}

class ActivePiece {
  const ActivePiece({
    required this.type,
    required this.rotation,
    required this.position,
    this.isSpecialBlock = false,
    this.lastMoveY,
  });

  final FallingBlock type;
  final Rotation rotation;
  final PointInt position;
  final bool isSpecialBlock;
  final int? lastMoveY;

  ActivePiece copyWith({
    FallingBlock? type,
    Rotation? rotation,
    PointInt? position,
    bool? isSpecialBlock,
    int? lastMoveY,
  }) {
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
  I,
  O,
  T,
  S,
  Z,
  J,
  L,
  PANDA,
  GHOST,
  CAT,
  TORNADO,
  BOMB,
}

enum EffectType { column, row }

class CellRender {
  const CellRender({
    required this.x,
    required this.y,
    required this.colorIndex,
    required this.isGhost,
  });
  final int x;
  final int y;
  final int colorIndex;
  final bool isGhost;
}

class EffectRender {
  const EffectRender({
    required this.x,
    required this.y,
    required this.type,
    required this.alpha,
  });
  final int x;
  final int y;
  final EffectType type;
  final int alpha;
}
