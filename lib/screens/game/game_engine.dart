part of 'game.dart';

bool collidesWithBoard(Game game, ActivePiece piece) {
  for (final c in game.cells(piece)) {
    if (c.x < 0 || c.x >= game.width || c.y < 0 || c.y >= game.height)
      return true;
    if (game.board[c.y][c.x] != null) return true;
  }
  return false;
}

bool applyMove(Game game, PointInt delta) {
  if (game.isPaused || game.isGameOver || game.current == null) return false;
  final nextPiece = game.current!.copyWith(
    position: game.current!.position + delta,
  );
  if (collidesWithBoard(game, nextPiece)) return false;
  game.current = nextPiece;
  game.notifyListeners();
  return true;
}

List<PointInt> calculateGhost(Game game) {
  if (game.current == null) return const [];
  var ghost = game.current!;
  while (true) {
    final nextPiece = ghost.copyWith(
      position: PointInt(ghost.position.x, ghost.position.y + 1),
    );
    if (collidesWithBoard(game, nextPiece)) break;
    ghost = nextPiece;
  }
  return game.cells(ghost);
}
