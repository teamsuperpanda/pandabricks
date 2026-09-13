import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart' hide Game;
import 'package:flame/particles.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:pandabricks/screens/game/game.dart';
import 'package:pandabricks/widgets/game/draw_board.dart';
import 'package:pandabricks/widgets/game/game_palette.dart';

/// Immutable snapshot of the HUD values published to the overlay widgets.
/// `timeRemaining` is quantized to whole seconds so the notifier only fires
/// when the displayed value actually changes.
class HudSnapshot {
  const HudSnapshot({
    required this.score,
    required this.level,
    required this.lines,
    required this.timeRemaining,
    this.next,
    this.hold,
    this.isPaused = false,
  });
  final int score;
  final int level;
  final int lines;
  final Duration? timeRemaining;
  final FallingBlock? next;
  final FallingBlock? hold;
  final bool isPaused;

  @override
  bool operator ==(Object other) =>
      other is HudSnapshot &&
      other.score == score &&
      other.level == level &&
      other.lines == lines &&
      other.timeRemaining == timeRemaining &&
      other.next == next &&
      other.hold == hold &&
      other.isPaused == isPaused;

  @override
  int get hashCode =>
      Object.hash(score, level, lines, timeRemaining, next, hold, isPaused);
}

/// Flame game wrapper around the pure `Game` simulation. Owns the loop
/// (gravity accumulator, clock, effect pruning) and renders the board through
/// `drawBoard`. Widget overlays (HUD, dialogs) live outside of Flame.
class PandaGame extends FlameGame {
  PandaGame({required this.sim, required this.hud}) {
    _wireSimCallbacks();
  }

  /// (Re)connects the Flame effects to the simulation callbacks. Called from
  /// the constructor and after every restart, since `sim.reset()` may be
  /// backed by a fresh `Game` instance or clear its callback fields.
  void _wireSimCallbacks() {
    sim.onPieceLocked = _spawnLockDust;
    sim.onCombo = _spawnPopup;
    sim.onBigClear = _shakeCamera;
  }

  /// The most recently constructed game, so the app lifecycle observer in
  /// `main.dart` can pause/resume the engine without a BuildContext.
  static PandaGame? current;

  final Game sim;
  final ValueNotifier<HudSnapshot> hud;

  /// Delay before a held direction starts auto-repeating (DAS).
  static const double kDas = 0.15;

  /// Repeat rate while held (ARR).
  static const double kArr = 0.04;

  int _heldDir = 0;
  double _dasTimer = 0;
  double _arrTimer = 0;

  final Random _rng = Random();

  double _dropAccumulator = 0;
  int _clock = 0;
  bool _gameOverHandled = false;
  double _gameOverDelay = 0;
  static const double _gameOverOverlayDelaySeconds = 0.5;

  /// Dedupes `onBigClear` so a single event (e.g. a BOMB that also clears rows)
  /// triggers only one shake per frame.
  bool _shookThisFrame = false;

  late final Map<int, LinearGradient> _gradients;

  /// Sets the held movement direction (-1 left, 1 right, 0 none). A nonzero
  /// direction immediately moves the piece once (so a tap still moves), then
  /// DAS/ARR auto-repeat takes over in `update`.
  void setHeldDirection(int dir) {
    _heldDir = dir < 0 ? -1 : (dir > 0 ? 1 : 0);
    _dasTimer = 0;
    _arrTimer = 0;
    if (_heldDir != 0) {
      if (_heldDir < 0) {
        sim.moveLeft();
      } else {
        sim.moveRight();
      }
    }
  }

  @override
  Future<void> onLoad() async {
    _gradients = buildShaderGradients(kGamePalette);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _shookThisFrame = false;
    if (sim.isGameOver) {
      // 500ms delay before the game-over overlay (was a Timer in the old
      // dialog mediator).
      if (!_gameOverHandled) {
        _gameOverDelay += dt;
        if (_gameOverDelay >= _gameOverOverlayDelaySeconds) {
          _gameOverHandled = true;
          overlays.add('gameover');
        }
      }
      return;
    }
    if (sim.isPaused) return;

    _clock += (dt * 1000).round();

    // Timed mode is driven from _clock, not wall-clock time, so pausing never
    // leaks real time.
    sim.advanceTime(_clock);

    // Prune expired effects (replaces the old Future.delayed chain).
    sim.pruneEffects(_clock);

    // DAS/ARR: held direction auto-repeats after the DAS delay at the ARR rate.
    if (_heldDir != 0) {
      _dasTimer += dt;
      if (_dasTimer >= kDas) {
        _arrTimer += dt;
        while (_arrTimer >= kArr) {
          _arrTimer -= kArr;
          if (_heldDir < 0) {
            sim.moveLeft();
          } else {
            sim.moveRight();
          }
        }
      }
    }

    // Frame-rate independent gravity.
    final dropInterval = sim.currentSpeed().inMilliseconds / 1000.0;
    _dropAccumulator += dt;
    while (_dropAccumulator >= dropInterval) {
      _dropAccumulator -= dropInterval;
      sim.tick(_clock);
    }

    pushHud();
  }

  @override
  void render(Canvas canvas) {
    // Draw the board first, then the component tree (camera, popups, dust),
    // so transient Flame components stay visible above the board.
    drawBoard(
      canvas,
      size.toSize(),
      sim.width,
      sim.height,
      sim.filledCellsWithGhost(),
      sim.currentEffects(_clock),
      kGamePalette,
      _gradients,
    );
    super.render(canvas);
  }

  /// Publishes the current simulation state to [hud]. Called every frame and
  /// after pause/restart transitions that happen outside the loop.
  void pushHud() {
    final next = HudSnapshot(
      score: sim.score,
      level: sim.level,
      lines: sim.linesCleared,
      timeRemaining: sim.timeRemaining == null
          ? null
          : Duration(seconds: sim.timeRemaining!.inSeconds),
      next: sim.next,
      hold: sim.hold,
      isPaused: sim.isPaused,
    );
    if (next != hud.value) hud.value = next;
  }

  /// Restarts the run, clearing any open overlays and game-over state.
  void restart() {
    _gameOverHandled = false;
    _gameOverDelay = 0;
    _dropAccumulator = 0;
    _clock = 0;
    _heldDir = 0;
    _dasTimer = 0;
    _arrTimer = 0;
    overlays.remove('gameover');
    overlays.remove('pause');
    sim.reset();
    _wireSimCallbacks();
    pushHud();
  }

  /// Spawns a short dust burst at the cells of a freshly locked piece. The
  /// cell-to-canvas math mirrors `drawBoard` (same cellSize/centering).
  void _spawnLockDust(List<PointInt> cells) {
    if (cells.isEmpty) return;
    final gameSize = size;
    final cellW = gameSize.x / sim.width;
    final cellH = gameSize.y / sim.height;
    final cellSize = min(cellW, cellH);
    final boardWidth = cellSize * sim.width;
    final boardHeight = cellSize * sim.height;
    final offsetX = (gameSize.x - boardWidth) / 2.0;
    final offsetY = (gameSize.y - boardHeight) / 2.0;

    final particle = Particle.generate(
      count: 12,
      generator: (i) {
        final c = cells[i % cells.length];
        final cx = offsetX + (c.x + 0.5) * cellSize;
        final cy = offsetY + (c.y + 0.5) * cellSize;
        final angle = _rng.nextDouble() * 2 * pi;
        final speed = 24 + _rng.nextDouble() * 32;
        return TranslatedParticle(
          offset: Vector2(cx, cy),
          lifespan: 0.25,
          child: AcceleratedParticle(
            speed: Vector2(cos(angle) * speed, sin(angle) * speed - 16),
            acceleration: Vector2(0, 160),
            child: CircleParticle(
              radius: 1.5 + _rng.nextDouble() * 1.5,
              paint: Paint()..color = Colors.white.withValues(alpha: 0.85),
            ),
          ),
        );
      },
    );
    // add() returns FutureOr; the particle system removes itself after its
    // lifespan, so the future does not need to be awaited.
    // ignore: discarded_futures
    add(ParticleSystemComponent(particle: particle));
  }

  /// Spawns a self-removing "COMBO xN" popup at the board center that floats
  /// up and fades out. The cell-to-canvas math mirrors `_spawnLockDust`.
  void _spawnPopup(int combo, bool backToBack) {
    final gameSize = size;
    final cellW = gameSize.x / sim.width;
    final cellH = gameSize.y / sim.height;
    final cellSize = min(cellW, cellH);
    final boardWidth = cellSize * sim.width;
    final boardHeight = cellSize * sim.height;
    final offsetX = (gameSize.x - boardWidth) / 2.0;
    final offsetY = (gameSize.y - boardHeight) / 2.0;

    final text = backToBack ? 'COMBO x$combo B2B' : 'COMBO x$combo';
    final popup = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(offsetX + boardWidth / 2, offsetY + boardHeight / 2),
      priority: 100,
    );
    // Component.add() returns FutureOr; the effects animate on their own, so
    // the futures do not need to be awaited.
    // ignore: discarded_futures
    popup.add(
      MoveByEffect(
        Vector2(0, -30),
        EffectController(duration: 0.8, curve: Curves.easeOut),
      ),
    );
    // The fade-out removes the popup on completion; the add future does not
    // need to be awaited.
    // ignore: discarded_futures
    popup.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.8),
        onComplete: popup.removeFromParent,
      ),
    );
    // The popup removes itself after its effects complete, so the add future
    // does not need to be awaited.
    // ignore: discarded_futures
    add(popup);
  }

  /// Short, small camera shake for big clears. Flame 1.38 has no
  /// `camera.shake`, so a MoveByEffect that oscillates forward and back on the
  /// viewfinder is used instead. `alternate: true` returns the viewfinder to
  /// its original position when the effect completes.
  void _shakeCamera() {
    if (_shookThisFrame) return;
    _shookThisFrame = true;
    camera.stop();
    // The effect oscillates back to the viewfinder's origin on its own; the
    // add future does not need to be awaited.
    // ignore: discarded_futures
    camera.viewfinder.add(
      MoveByEffect(
        Vector2(4, 0),
        EffectController(duration: 0.06, alternate: true),
      ),
    );
  }
}
