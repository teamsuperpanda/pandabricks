# Panda Bricks: Migration to Flame (coding-ready TODO)

This is a migration plan plus an implementation reference. It maps the current
pure-Flutter code (`CustomPainter` + `ChangeNotifier` + `Timer.periodic`) to
Flame, with exact signatures, line references, and near-complete code skeletons
so the work is mechanical. Read-only investigation of `lib/` plus current
Flame docs (`flame-engine/flame`) backs every claim. Not committed.

Note: features B (next-queue preview) and F (additional sound effects) from
section 8 were deferred and are NOT included in the 2.4.0 release (the game
ships with its original three SFX: row, column/PANDA, and BOMB clears).

---

## 0. Why Flame (honest)

The game works today. The efficiency win is architectural:

- Every tick and effect frame calls `notifyListeners()` (`game.dart:104`),
  which rebuilds every `context.watch<Game>()` consumer (HUD, controls,
  preview) on top of repainting `BoardPainter`.
- `Timer.periodic` + `Future.delayed` chains drive simulation and effects
  (`screen.dart:121`, `game_effects.dart`, `special_blocks.dart`) in wall-clock
  milliseconds, not frame time.
- `BoardPainter` redraws the whole grid every version bump.

Flame gives a `update(dt)`/`render(Canvas)` loop decoupled from widget rebuilds,
frame-time-based timing, and a retained-mode component model with headroom for
richer effects. We keep models, audio, dialogs, menu, and routing untouched.

---

## 1. What stays as-is (do NOT rewrite)

- `lib/models/game_types.dart` - all enums, `PointInt`, `ActivePiece`,
  `CellRender`, `EffectRender`, `shapes`, `colorFor`. Pure data.
- `lib/models/game_settings.dart`, `lib/models/game_input_callbacks.dart`.
- `lib/providers/audio_provider.dart` - keep `audioplayers`, constructor
  injected (already Flame-friendly).
- `lib/providers/locale_provider.dart`.
- `lib/navigation/app_router.dart` - `go_router` stays; Flame embeds in `/game`.
- `lib/screens/home/*`, `lib/widgets/home/*` - pure Flutter, untouched.
- `lib/dialogs/*` - dialog WIDGETS stay; only how they are shown changes.
- `lib/widgets/game/controls.dart`, `hud.dart`, `timer_display.dart`,
  `dialog_button.dart` - keep as Flutter overlay widgets.
- `lib/widgets/game/game_palette.dart` - `kGamePalette`, `kSpecialBlockEmojis`,
  `kSpecialBlockStartIndex`. Reused by Flame.
- `lib/theme.dart`, `lib/l10n/*`, `lib/data/*`, `lib/services/logging.dart`.
- Pure logic in `game_engine.dart` (`collidesWithBoard`, `applyMove`,
  `calculateGhost`), `special_blocks.dart`, and `game.dart` line-clear/spawn
  logic. Port as-is; only the caller and notification change.

---

## 2. Recommended architecture

Keep the `Game` class as the simulation, strip `ChangeNotifier`, and wrap it in
a `FlameGame` that owns the loop and render. Widgets (HUD, controls, dialogs)
stay Flutter, layered over the `GameWidget` via a `Stack` or Flame overlays.

```
FlameGame (PandaGame)
  ├─ owns Game sim            (data + rules, no ChangeNotifier)
  ├─ update(dt): gravity accumulator, soft-drop, DAS, timed countdown,
  │             effect pruning, game-over detection
  └─ render(canvas): calls drawBoard(...) (extracted from BoardPainter)

Flutter UI (Stack over GameWidget)
  ├─ HUD / controls / preview  (read sim via ValueNotifier<HudSnapshot>)
  └─ Dialogs = Flame overlays ('pause', 'gameover', 'restart', 'mainmenu')
```

No `FixedResolutionViewport` is required: mirror `BoardPainter` and compute
`cellSize` from Flame's `size` each frame, centering the board. Add a viewport
later only if you want pixel-perfect scaling.

---

## 3. Implementation reference

### 3.1 Extract the board paint into a free function

Create `lib/widgets/game/draw_board.dart`. Move the body of
`BoardPainter.paint` (`board_painter.dart:90-264`) verbatim into:

```dart
// draw_board.dart
import 'package:flutter/material.dart';
import 'package:pandabricks/models/game_types.dart';
import 'package:pandabricks/widgets/game/game_palette.dart';

// Same static Paints as board_painter.dart:25-44 (grid, glow, cell, sparkle,
// innerHighlight gradient). Also move cachedEmojiPainter (lines 63-88) here.
// buildShaderGradients (lines 48-61) also moves here.

void drawBoard(
  Canvas canvas,
  Size size,
  int width,
  int height,
  Iterable<CellRender> cells,
  Iterable<EffectRender> effects,
  List<Color> palette,
  Map<int, LinearGradient> gradients,
) {
  // PASTE BoardPainter.paint body. Replace `this.width/height/cells/effects/
  // palette` with the parameters, and `_cachedShaderGradient[idx]` with
  // `gradients[idx]`. Everything else is identical.
}
```

Now `BoardPainter` becomes dead code and is deleted in Phase 8. `draw_board.dart`
is also reused by the preview (see 3.10) if desired, or the preview stays a
`CustomPainter` (it is cheap and static).

### 3.2 New file: `lib/screens/game/flame/panda_game.dart`

```dart
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart'; // only if using Flame keyboard
import 'package:flutter/material.dart';
import 'package:pandabricks/models/game_types.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/screens/game/game.dart'; // Game (sim)
import 'package:pandabricks/widgets/game/game_palette.dart';
import 'package:pandabricks/widgets/game/draw_board.dart';

class HudSnapshot {
  const HudSnapshot({
    required this.score,
    required this.level,
    required this.lines,
    required this.timeRemaining,
  });
  final int score;
  final int level;
  final int lines;
  final Duration? timeRemaining;
  @override
  bool operator ==(Object other) =>
      other is HudSnapshot &&
      other.score == score &&
      other.level == level &&
      other.lines == lines &&
      other.timeRemaining == timeRemaining;
  @override
  int get hashCode => score ^ level ^ lines ^ (timeRemaining?.inSeconds ?? -1);
}

class PandaGame extends FlameGame {
  PandaGame({
    required this.sim,
    required this.audioProvider,
    required this.hud,
  });
  final Game sim;
  final AudioProvider audioProvider; // already constructor-injected into sim
  final ValueNotifier<HudSnapshot> hud;

  double _dropAccumulator = 0;
  int _clock = 0; // pausable game clock in ms (replaces DateTime.now())
  bool _gameOverHandled = false;
  double _gameOverDelay = 0; // seconds remaining before showing overlay

  late final Map<int, LinearGradient> _gradients;

  @override
  Future<void> onLoad() async {
    _gradients = buildShaderGradients(kGamePalette);
  }

  @override
  void update(double dt) {
    if (sim.isGameOver) {
      // 500ms delay before game-over overlay (was Timer in mediator, line 28)
      if (!_gameOverHandled) {
        _gameOverDelay -= dt;
        if (_gameOverDelay <= 0) {
          _gameOverHandled = true;
          overlays.add('gameover');
        }
      }
      return;
    }
    if (sim.isPaused) return;

    _clock += (dt * 1000).round();

    // Timed mode: drive from _clock, not DateTime (replace tick()'s wall-clock)
    sim.advanceTime(_clock); // see 3.3

    // Prune expired effects (replaces Future.delayed chain, see 3.5)
    sim.pruneEffects(_clock);

    // Gravity: frame-rate independent. currentSpeed() -> Duration (game.dart:316)
    final dropInterval = sim.currentSpeed().inMilliseconds / 1000.0;
    _dropAccumulator += dt;
    while (_dropAccumulator >= dropInterval) {
      _dropAccumulator -= dropInterval;
      sim.tick(_clock); // pass clock so tick uses _clock for timed countdown
    }

    _pushHud();
  }

  @override
  void render(Canvas canvas) {
    drawBoard(
      canvas,
      size,
      sim.width,
      sim.height,
      sim.filledCellsWithGhost(),
      sim.currentEffects(_clock), // clock-based alpha (see 3.5)
      kGamePalette,
      _gradients,
    );
  }

  void _pushHud() {
    final next = HudSnapshot(
      score: sim.score,
      level: sim.level,
      lines: sim.linesCleared,
      timeRemaining: sim.timeRemaining,
    );
    if (next != hud.value) hud.value = next; // equality guard avoids churn
  }

  // Called by Flame overlays / input to pause and show overlay
  void pauseAndShow() {
    sim.togglePause();
    overlays.add('pause');
  }
}
```

### 3.3 Changes to `Game` (strip `ChangeNotifier`)

`Game` (`game.dart:27`) currently `extends ChangeNotifier`. Plan:

- Change `class Game extends ChangeNotifier` to `class Game {` (plain class).
- Delete `notifyListeners()` override (lines 103-108) and every
  `notifyListeners()` call (lines 138, 159, 215, 249, 269, 281, 282, 312 area,
  and inside `game_effects.dart` callbacks).
- Delete `_version`/`version` (lines 52-54) and the `filledCellsWithGhost`
  version cache (lines 324-333) since Flame calls `render` every frame; just
  return `_computeFilledCellsWithGhost()` directly (or keep a simple cache
  that rebuilds on mutation).
- Keep constructor (lines 28-45) but drop the `width`/`height` defaults logic
  only if you want custom board sizing; it is fine as-is.
- Add `void advanceTime(int clock)` and change `tick` signature to
  `void tick(int clock)` so the timed countdown uses `clock` instead of
  `DateTime.now()` (lines 274-284). The `togglePause()` wall-clock math
  (lines 143-156) should also switch to `_clock`; store `_clock` on `Game`
  instead of `gameStartTime`/`DateTime`, OR keep `timeRemaining` and decrement it
  in `advanceTime` by `dt` (simplest: pass elapsed ms).
- Keep all rules: `moveLeft/Right` (218/226), `softDrop` (233), `rotateCW`
  (235), `hardDrop` (255), `clearLines` (291), `currentSpeed` (316), `_spawn`
  (199), `lockCurrentPiece` (special_blocks.dart:112). They no longer notify;
  HUD reads via `ValueNotifier` from `update` (3.2).

Note: `clearLines` calls `audioProvider.playSfx(GameSfx.rowClear)` (line 311)
and `special_blocks.dart` calls `columnClear`/`bombExplosion`. Audio is already
wired through the injected `audioProvider`. No change needed there.

### 3.4 HUD without `notifyListeners`

- In `GameScreen`, create `final hud = ValueNotifier<HudSnapshot>(...)` and
  pass it to `PandaGame`.
- Wrap `GameHUD` in `ValueListenableBuilder<HudSnapshot>` (or keep the existing
  widget but feed it from the notifier). The HUD no longer uses
  `context.watch<Game>()`.
- In timed mode the timer updates because `_pushHud` runs each frame and the
  `==` guard updates the notifier only when the displayed second changes.

### 3.5 Effects: kill `Future.delayed`

Today (`game_effects.dart`): `_triggerEffect` adds entries then fires 5
`Future.delayed` callbacks (100-500ms) just to call `notifyListeners()`, and
removes effects at the 5th. `currentEffects()` (game.dart:375) derives alpha
from `DateTime.now() - start`.

Replace with a clock-based, update-driven model:

- Add `int _clock = 0;` to `Game` (or pass it in). Effects store `start` as a
  clock value (already `int start` in `_Effect`, line 14-24).
- `triggerRowEffect`/`triggerColumnEffect` (game_effects.dart:41-45): just add
  `_Effect` entries with `start = clock`. Delete the `Future.delayed` block.
- Add `void pruneEffects(int clock)` to `Game`: remove entries where
  `clock - start > effectDurationMs` (500). Call it from `PandaGame.update`
  (3.2).
- Change `Iterable<EffectRender> currentEffects()` to
  `Iterable<EffectRender> currentEffects(int clock)` using
  `elapsed = (clock - e.start).clamp(0, effectDurationMs)` instead of
  `DateTime.now()`. Alpha math (line 380) is unchanged.
- `effectDurationMs` (game.dart:58) stays 500. Sparkle draw (`_drawSparkles`,
  board_painter.dart:266-309) is unchanged and reused by `drawBoard`.

This removes all `Future.delayed` churn and makes effects pause correctly
(they age off `_clock`, which only advances when `update` runs).

### 3.6 Input

Keep `GameInputHandler` (`game_input_handler.dart`) almost verbatim as a Flutter
widget around the `GameWidget`. Two choices:

- **Keep Flutter (recommended, least work):** `KeyboardListener` +
  `GestureDetector` stay in `game_view.dart`/`screen.dart`. Point the
  `GameInputCallbacks` (model, lines in `game_input_callbacks.dart`) at the sim
  methods: `onMoveLeft: sim.moveLeft`, etc. The soft-drop repeat
  `Timer.periodic(120ms)` (handler line 56) and drag threshold 18px / fling
  900 (lines 14-16) stay as-is. `onStartMusic` wraps the first call.
- **Flame-native (optional later):** mix `HasKeyboardHandlerComponents` and use
  `KeyboardListenerComponent` / `PanDetector`. Mapping table is unchanged:

  | Key / gesture | Action |
  |---|---|
  | ArrowLeft | `sim.moveLeft()` |
  | ArrowRight | `sim.moveRight()` |
  | ArrowUp / Space | `sim.rotateCW()` |
  | ArrowDown (hold) | `sim.softDrop()` + 120ms repeat |
  | Enter | `sim.hardDrop()` |
  | Horizontal drag >18px | move left/right |
  | Vertical drag down >18px | soft drop |
  | Vertical fling >900 | hard drop |
  | Tap playfield | `sim.rotateCW()` (game_view.dart:252) |

On-screen `controls.dart` buttons stay Flutter, calling the same callbacks.

### 3.7 Audio (no change)

`AudioProvider` is constructor-injected into `Game` (`game.dart:29,48`). A
`FlameGame` has no `BuildContext`, so do NOT switch to `context.read`. Sim
already holds `audioProvider` and calls `playSfx` from `clearLines` /
`special_blocks.dart`. Keep `playMenuMusic`/`playGameMusic` calls in the screen
widgets as today.

### 3.8 Dialogs -> Flame overlays

`GameDialogMediator` (`game_dialog_mediator.dart`) currently does
`showDialog(...)` (lines 136-145) for Pause/GameOver/Restart/MainMenu. Move
these to **Flame overlays** so they are part of the game lifecycle and pause
properly:

- In `GameScreen`, build the `GameWidget` with `overlayBuilderMap`:
  ```dart
  GameWidget<PandaGame>.managed(
    gameFactory: () => pandaGame,
    overlayBuilderMap: {
      'pause': (ctx, game) => PauseDialog(
        onResume: () { game.overlays.remove('pause'); game.sim.togglePause(); },
        onRestart: () { game.overlays.remove('pause'); game.sim.reset(); },
        onMainMenu: () => context.go('/'),
      ),
      'gameover': (ctx, game) => GameOverDialog(
        score: game.sim.score, level: game.sim.level,
        lines: game.sim.linesCleared,
        onRestart: () { game.overlays.remove('gameover'); game.sim.reset(); },
        onMainMenu: () => context.go('/'),
      ),
      'restart': ...,
      'mainmenu': ...,
    },
  )
  ```
- `GameDialogMediator` becomes a thin adapter (or is deleted): call
  `pandaGame.overlays.add('pause')` / `.add('gameover')` instead of
  `showDialog`. The 500ms game-over delay moves into `PandaGame.update`
  (3.2).
- Dialog WIDGETS (`dialogs/game/*`) are unchanged; they already take callbacks.
- `PopScope` back-button handling stays in the Flutter `GameScreen`.

### 3.9 Lifecycle

Today there is NO `WidgetsBindingObserver` in `screen.dart` (confirmed in
investigation). Add one in `main.dart` (which already has
`WidgetsBindingObserver`, lines 47-80): on `AppLifecycleState.paused`/
`detached`, call `pandaGame.pauseEngine()` (and keep stopping music); on
`resumed`, `pandaGame.resumeEngine()`. This replaces the current music-only
handling and also freezes the game clock.

### 3.10 Preview (optional)

`PiecePreview` (`preview.dart`) is static and cheap. Keep it as a Flutter widget
(unchanged). Only delete it if you later want a Flame `NextPieceComponent`.

---

## 4. File-by-file change table

| File | Action | Detail |
|---|---|---|
| `widgets/game/draw_board.dart` | ADD | `drawBoard()` + moved `cachedEmojiPainter` + `buildShaderGradients` from `board_painter.dart`. |
| `screens/game/flame/panda_game.dart` | ADD | `PandaGame extends FlameGame` + `HudSnapshot` (3.2). |
| `screens/game/game.dart` | EDIT | Drop `ChangeNotifier`/`notifyListeners`/`_version`; add `_clock`; `tick(int clock)`; `currentEffects(int clock)`; `pruneEffects`; `advanceTime`. Keep all rules. |
| `screens/game/game_effects.dart` | EDIT | Remove `Future.delayed` block; `triggerRow/ColumnEffect` just append entries with `start = clock`. |
| `screens/game/special_blocks.dart` | EDIT | Remove any `notifyListeners()`; logic unchanged. |
| `screens/game/game_engine.dart` | STAY | Pure functions reused as-is. |
| `screens/game/screen.dart` | EDIT | Remove `Timer.periodic` (121-124), `_onGameChanged` (107-119), `ChangeNotifierProvider` (161). Build `GameWidget` + `ValueNotifier<HudSnapshot>` + overlays. Dispose `pandaGame`. |
| `screens/game/game_view.dart` | EDIT | Replace `CustomPaint(BoardPainter)` (263) with `GameWidget`. Keep `Stack` with HUD/controls. Keep `GestureDetector` (27-31) wiring to sim. |
| `screens/game/game_input_handler.dart` | EDIT | Repoint `GameInputCallbacks` to `sim.*` (keep keys/gestures/timers). |
| `screens/game/game_dialog_mediator.dart` | EDIT/DELETE | Replace `showDialog` with `overlays.add` calls; or delete after overlays wired. |
| `widgets/game/board_painter.dart` | DELETE | Replaced by `draw_board.dart` (Phase 8). |
| `widgets/game/preview.dart` | STAY | Keep as Flutter widget. |
| `providers/audio_provider.dart` | STAY | No change. |
| `main.dart` | EDIT | On lifecycle pause/resume call `pauseEngine`/`resumeEngine`. |
| `models/*`, `dialogs/*`, `screens/home/*`, `widgets/home/*`, `navigation/*` | STAY | Untouched. |

---

## 5. TODO checklist (phased)

### Phase 0 - Deps & bootstrap
- [ ] Add `flame: ^1.x` to `pubspec.yaml` (verify vs SDK `^3.8.1`).
- [ ] Create `draw_board.dart` (3.1): move `BoardPainter.paint` body + emoji
      cache + gradient builder. No logic change.

### Phase 1 - Game model off ChangeNotifier
- [ ] `Game`: remove `extends ChangeNotifier`, `notifyListeners`, `_version`.
- [ ] Add `int _clock`; refactor `tick`/`togglePause`/`advanceTime` to use it.
- [ ] `currentEffects(int clock)` and `pruneEffects(int clock)` added.

### Phase 2 - FlameGame + loop
- [ ] Create `panda_game.dart` (3.2). `onLoad` builds gradients; `update`
      drives gravity via `dt` accumulator and `sim.tick(_clock)`; `render` calls
      `drawBoard`.
- [ ] Remove `Timer.periodic` and `_onGameChanged` from `screen.dart`; build
      `GameWidget` + `ValueNotifier<HudSnapshot>`.

### Phase 3 - HUD + input
- [ ] Wrap `GameHUD` in `ValueListenableBuilder` reading `hud`.
- [ ] Repoint `GameInputHandler` callbacks at `sim.*`; keep keys/gestures/
      repeat timers.

### Phase 4 - Effects
- [ ] Remove `Future.delayed` from `game_effects.dart`; effects age off `_clock`.
- [ ] Verify sparkle alpha curve unchanged.

### Phase 5 - Dialogs -> overlays
- [ ] Wire `overlayBuilderMap` (pause/gameover/restart/mainmenu) in
      `GameScreen`; adapt/delete `GameDialogMediator`; 500ms delay in `update`.

### Phase 6 - Lifecycle
- [ ] `main.dart`: `pauseEngine`/`resumeEngine` on app background.

### Phase 7 - Tests
- [ ] `board_painter_test` -> test `drawBoard` directly or via Flame render.
- [ ] Keep `game_engine_test`, `special_bricks_test`, `game_types_test`.
- [ ] Add loop test: enough `update(dt)` accumulation descends/locks a piece.
- [ ] Keep control/hud/dialog widget tests.

### Phase 8 - Cleanup
- [ ] Delete `board_painter.dart`; remove dead `_version`/notifyListeners refs.
- [ ] `flutter analyze` clean + `flutter test` green.

---

## 6. Risks / open questions

- **Emoji in Flame canvas:** `cachedEmojiPainter` uses `TextPainter` with
  `fontFamilyFallback: ['Noto Color Emoji','Apple Color Emoji']`
  (board_painter.dart:77). Flame renders via the same `dart:ui` Canvas, so this
  works unchanged. Verify emoji render on web (color emoji support varies).
- **No `BuildContext` in components:** audio is already constructor-injected,
  so no `context.read` needed. Keep it that way.
- **Route re-creation:** `go_router` rebuilds `GameScreen`; ensure `pandaGame`
  is created once per screen and disposed on exit (use `GameWidget.managed` or
  explicit lifecycle) to avoid leaks.
- **Timed-mode clock:** must be `_clock`-based (not `DateTime.now()`) or pause
  will leak real time. Covered in 3.3.
- **Scope:** do NOT port the home screen or dialog widgets to Flame. Keep the
  migration to the `/game` surface.

## 7. Suggested first PR (de-risk)

1. Add `flame`, create `draw_board.dart` (extract paint, visual parity).
2. `Game` off `ChangeNotifier`; add `_clock` + `currentEffects(int)` +
   `pruneEffects`.
3. `PandaGame` + `GameWidget` in `game_view.dart`; `update` gravity accumulator.
4. Keep input/audio/dialogs exactly as today (Flutter overlays, `showDialog`).
5. Delete `BoardPainter`, `_version`, board `notifyListeners`.

If that PR renders and plays identically, the rest (HUD notifier, overlays,
lifecycle) is mechanical.

---

## 8. Post-migration feature backlog (game-design picks)

These are selected from the quick-win and medium ideas. Selection criteria, in
order: (1) helps the player (clarity, control, fairness), (2) keeps the board
readable (this is a puzzle game, not an action game), (3) feedback that rewards
without fatiguing, (4) scope that fits a small team. Replay was excluded by
request. Versus/garbage and a busy in-game particle background were cut on
scope/readability grounds (see 8.3).

### 8.1 Designer rationale (why these, not gimmicks)

Panda Bricks is a cute, casual, internationally localized falling-blocks game.
The player's biggest frustrations in this genre are imprecise controls and not
being able to plan ahead. So the highest-value additions are control feel and
planning info. Juice (particles, shake, popups) is included only where it
reinforces an event the player caused and stays subtle. Anything that covers
the board or shakes on every tap is a gimmick that hurts a puzzle game, so it
is out.

### 8.2 Selected features

#### A. DAS/ARR responsive controls (quick win, essential)
- **Why:** Held left/right should auto-repeat smoothly. Today movement is
  drag-threshold or single keypress only. This is the single biggest feel fix.
- **How:** In `PandaGame.update(dt)`, track held-direction state and two timers:
  DAS (delay before repeat, ~150ms) then ARR (repeat rate, ~30-50ms). Call
  `sim.moveLeft()`/`moveRight()` from the accumulator, not from a Flutter
  `Timer`. Reuses the existing `moveLeft/Right` (game.dart:218/226).
- **Touch:** keep the 18px drag threshold but also support hold-to-repeat via
  the same DAS/ARR accumulators.

#### B. Next-queue (3-next) preview (medium, high value)
- **Why:** Players plan. Single "next" exists; a 3-deep queue is the genre
  standard and low risk.
- **How:** Add `List<FallingBlock> _nextQueue` to `Game` (seed 4 in `_spawn`,
  game.dart:199). Render via a `NextQueueComponent` (or extend `draw_board.dart`
  with a `drawNextQueue` helper mirroring the preview painter, preview.dart).
  HUD overlay reads it from the `HudSnapshot` or directly from `sim`.

#### C. Hold piece (medium, strategic depth)
- **Why:** Gives players a tactical option without speeding the game up.
  Lower priority than next-queue but the natural companion.
- **How:** Add `FallingBlock? hold` + `bool holdUsed` to `Game`. New
  `swapHold()` method: if not used this drop, stash current and pull hold (or
  draw from queue). Render a `HoldComponent` beside the board. Wire a hold
  button into `controls.dart` and a key (e.g. `Shift`/`C`) into
  `game_input_handler.dart`.

#### D. Subtle lock + line-clear feedback (quick win)
- **Why:** The player needs to feel a piece lock and a clear, without noise.
- **How (Flame):**
  - Lock dust: a short `ParticleSystemComponent` burst at the locked cells
    (reuse `Particle` API). Keep it small (<=12 particles, ~250ms).
  - Line-clear flash: extend `game_effects.dart` with a brief white flash on the
    cleared rows (add an `EffectType.rowFlash` or reuse the sparkle path with a
    brighter alpha). Already clock-driven after Phase 4.
  - **Do NOT** add screen shake on every hard drop (fatigue). See 8.3.

#### E. Targeted screen shake (quick win, scoped)
- **Why:** Big moments should land. But constant shake trains the player to
  ignore it and strains casual players.
- **How:** `CameraComponent` (or `game.shake` on `FlameGame`) shake only on
  BOMB clears and 3+ line (tetris) clears, short duration (~120ms), small
  magnitude. Triggered from `special_blocks.dart` BOMB path and `clearLines`
  when `cleared >= 3`.

#### F. Move / rotate / lock SFX (quick win)
- **Why:** Audible confirmation of actions improves feel and accessibility.
- **How:** Extend `GameSfx` (audio_provider.dart:9) with `move`, `rotate`,
  `softDrop`, `hardDrop`, `lock`, `levelUp`. Call from `Game` methods
  (moveLeft/Right/rotateCW/hardDrop/lockCurrentPiece). **Gate behind the
  existing `sfxEnabled` setting** (already in `playSfx`) and keep volumes low
  so it does not become noisy. Add the asset files under `assets/audio/sfx/`.

#### G. Combo + back-to-back tracking with popups (medium)
- **Why:** Rewards skilled consecutive clears, gives positive reinforcement,
  and adds a light scoring layer without changing board rules.
- **How:** Add `int combo` and `bool backToBack` to `Game`. In `clearLines`
  (game.dart:291): if `cleared > 0`, `combo++` and apply a combo bonus to
  `score`; else `combo = 0`. Back-to-back tracks consecutive difficult clears
  (tetris / BOMB). Render a `TextComponent` popup ("COMBO x3", "B2B") that
  floats and fades via an `EffectController` (already available per Flame docs).
  Popups are Flame components, so they need no widget rebuild.

### 8.3 Explicitly excluded (and why)

- **Busy in-game particle background:** the home screen already has
  `AmbientParticles`; putting a moving field behind the playfield hurts board
  readability for a puzzle game. Skip. Keep the existing subtle gradient.
- **Screen shake on every action:** fatiguing for casual players; restricted to
  BOMB / tetris clears only (feature E).
- **Versus / garbage lines:** large scope (second sim, networking or local
  state, new UI). Out of scope for a recoding task.
- **Replay system:** excluded by request.
- **T-spin detection:** adds rules complexity the cute casual audience did not
  ask for. Defer unless there is demand.

### 8.4 Suggested order after the migration lands

1. A (DAS/ARR) and F (SFX) - control feel, cheap, highest player impact.
2. B (next-queue) and D (lock/clear feedback) - planning + readable feedback.
3. G (combo popups) - depth and reward.
4. C (hold) and E (targeted shake) - last, as they are the heaviest UI/scope.

Each item reuses the Flame loop, components, and the already-injected
`AudioProvider`, so none require touching the home screen, dialogs, or routing.
