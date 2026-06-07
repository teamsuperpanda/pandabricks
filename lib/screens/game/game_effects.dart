part of 'game.dart';

void _triggerEffect(
  Game game, {
  required int fixed,
  required EffectType type,
  required int max,
}) {
  game._effects.removeWhere(
    (e) => e.type == type && (type == EffectType.column ? e.x : e.y) == fixed,
  );
  final start = DateTime.now().millisecondsSinceEpoch;
  for (var i = 0; i < max; i++) {
    game._effects.add(
      _Effect(
        x: type == EffectType.column ? fixed : i,
        y: type == EffectType.column ? i : fixed,
        type: type,
        start: start,
      ),
    );
  }
  game.notifyListeners();
  final generation = game._effectGeneration;
  Future.delayed(const Duration(milliseconds: Game.effectDurationMs), () {
    if (game._disposed) return;
    if (game._effectGeneration != generation) return;
    game._effects.removeWhere(
      (e) =>
          e.type == type &&
          (type == EffectType.column ? e.x : e.y) == fixed &&
          e.start == start,
    );
    game.notifyListeners();
  });
}

void triggerColumnEffect(Game game, int x) =>
    _triggerEffect(game, fixed: x, type: EffectType.column, max: game.height);

void triggerRowEffect(Game game, int y) =>
    _triggerEffect(game, fixed: y, type: EffectType.row, max: game.width);
