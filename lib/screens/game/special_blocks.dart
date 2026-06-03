part of 'game.dart';

void _tryApplySpecialMove(Game game, ActivePiece candidate) {
  if (!collidesWithBoard(game, candidate)) {
    game.current = candidate;
  } else {
    game.current = game.current!.copyWith(lastMoveY: game.current!.position.y);
  }
}

void _writePieceToBoard(Game game) {
  for (final c in game.cells(game.current!)) {
    if (c.y < 0 || c.y >= game.height || c.x < 0 || c.x >= game.width) {
      game.isGameOver = true;
      return;
    }
    game.board[c.y][c.x] = Game.colorFor[game.current!.type];
  }
}

void applySpecialBehaviors(Game game) {
  if (game.current == null || !game.current!.isSpecialBlock) return;

  if (game.current!.type == FallingBlock.CAT) {
    if (game.current!.lastMoveY != game.current!.position.y) {
      final movement = game._rng.nextInt(3) - 1;
      if (movement != 0) {
        final newPos = game.current!.position + PointInt(movement, 0);
        _tryApplySpecialMove(
          game,
          game.current!.copyWith(
            position: newPos,
            lastMoveY: game.current!.position.y,
          ),
        );
      } else {
        game.current = game.current!.copyWith(
          lastMoveY: game.current!.position.y,
        );
      }
    }
  }

  if (game.current!.type == FallingBlock.TORNADO) {
    if (game.current!.lastMoveY != game.current!.position.y) {
      final nextRotation =
          Rotation.values[(game.current!.rotation.index + 1) % 4];
      _tryApplySpecialMove(
        game,
        game.current!.copyWith(
          rotation: nextRotation,
          lastMoveY: game.current!.position.y,
        ),
      );
    }
  }
}

void handleSpecialBlockEffects(Game game) {
  if (game.current == null) return;
  final cells = game.cells(game.current!);

  // GHOST, CAT, TORNADO handled by applySpecialBehaviors and lockCurrentPiece
  switch (game.current!.type) {
    case FallingBlock.PANDA:
      for (final c in cells) {
        if (c.x >= 0 && c.x < game.width) {
          clearColumn(game, c.x);
        }
      }
      game.score += Game.pandaBrickBonus;
      game.audioProvider.playSfx(GameSfx.columnClear);

    case FallingBlock.BOMB:
      for (final c in cells) {
        if (c.y >= 0 && c.y < game.height && c.x >= 0 && c.x < game.width) {
          clearRow(game, c.y);
          clearColumn(game, c.x);
        }
      }
      game.score += Game.bombBrickBonus;
      game.audioProvider.playSfx(GameSfx.bombExplosion);

    case FallingBlock.GHOST:
    case FallingBlock.CAT:
    case FallingBlock.TORNADO:
      _writePieceToBoard(game);

    default:
      _writePieceToBoard(game);
  }
}

void clearColumn(Game game, int x) {
  for (var y = 0; y < game.height; y++) {
    game.board[y][x] = null;
  }
  triggerColumnEffect(game, x);
}

void clearRow(Game game, int y) {
  for (var x = 0; x < game.width; x++) {
    game.board[y][x] = null;
  }
  triggerRowEffect(game, y);
}

void lockCurrentPiece(Game game) {
  if (game.current == null) return;
  if (game.current!.isSpecialBlock) {
    handleSpecialBlockEffects(game);
  } else {
    _writePieceToBoard(game);
  }
  final cleared = game.clearLines();
  if (cleared > 0) {
    game.linesCleared += cleared;
    game.score +=
        (Game.lineClearScores[cleared.clamp(
                  0,
                  Game.lineClearScores.length - 1,
                )] *
                game.level *
                (game.customConfig?.scoreMultiplier ?? 1.0))
            .toInt();
    game.level = 1 + (game.linesCleared ~/ 10);
  }
  game._spawn();
}
