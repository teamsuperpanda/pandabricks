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
  final start = game._clock;
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
}

void triggerColumnEffect(Game game, int x) =>
    _triggerEffect(game, fixed: x, type: EffectType.column, max: game.height);

void triggerRowEffect(Game game, int y) =>
    _triggerEffect(game, fixed: y, type: EffectType.row, max: game.width);

/// Adds a single fading white flash over a cleared row. Ages off the game
/// clock like the other effects, so it pauses correctly.
void triggerRowFlashEffect(Game game, int y) {
  game._effects.removeWhere((e) => e.type == EffectType.rowFlash && e.y == y);
  game._effects.add(
    _Effect(x: 0, y: y, type: EffectType.rowFlash, start: game._clock),
  );
}
