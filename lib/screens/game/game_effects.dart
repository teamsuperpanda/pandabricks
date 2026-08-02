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
  for (var i = 1; i <= 5; i++) {
    Future.delayed(Duration(milliseconds: Game.effectDurationMs * i ~/ 5), () {
      if (game._disposed || game._effectGeneration != generation) return;
      if (i == 5) {
        game._effects.removeWhere(
          (e) =>
              e.type == type &&
              (type == EffectType.column ? e.x : e.y) == fixed &&
              e.start == start,
        );
      }
      game.notifyListeners();
    });
  }
}

void triggerColumnEffect(Game game, int x) =>
    _triggerEffect(game, fixed: x, type: EffectType.column, max: game.height);

void triggerRowEffect(Game game, int y) =>
    _triggerEffect(game, fixed: y, type: EffectType.row, max: game.width);
