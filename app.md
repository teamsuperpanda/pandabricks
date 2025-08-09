# Pandabricks — v2.0.0 (Build 9)

A complete outline for the next major release. This plan refreshes the visuals and UX, keeps all existing game modes (including Blitz), and proposes modernized systems while reusing the existing fonts, music, and images in the top-level `assets/` folder. No coding in this document—pure product and technical planning for v2.

## TL;DR

- Major UI/UX refresh built on modern design language (Material 3 look-and-feel) while retaining familiar navigation.
- Same game modes as v1 preserved 1:1 (including Blitz). Blitz special bricks get a thoughtful update for clarity and fun.
- Reuse all root `assets/` fonts, music, images. New palette, motion, and layout improve readability, accessibility, and feel.
- Technical plan: newer Flutter toolchain, componentized architecture, performance and QA budgets, and clean migration from `old_app/`.

---

## Product Goals

1. Refresh the experience without changing what players love.
2. Improve readability, touch targets, and onboarding to reduce early churn.
3. Make Blitz feel more strategic and more “readable” in the moment through clearer special bricks and feedback.
4. Keep binary size and frame pacing tight; hit 60 FPS on modest devices.
5. Lower maintenance cost with a cleaner architecture and testable business logic.

## Scope (What’s In / What’s Out)

In:
- Visual/interaction redesign across all screens.
- Preservation of all existing game modes from v1 (including Blitz). Mode names/labels remain exactly as in v1.
- Updated Blitz special bricks (design proposals below) and tuned scoring/telemetry.
- Asset reuse from the root `assets/` folder: fonts, music, images, sfx.
- Accessibility, localization polish, performance budgets, QA plan.

Out (for this build):
- New monetization mechanics or networked features.
- New modes or drastic rule changes.
- Cloud services beyond what v1 already uses (if any).

## Assets To Reuse (exact paths)

- Fonts (Typography):
	- `assets/fonts/Fredoka-Regular.ttf`
	- `assets/fonts/Fredoka-Medium.ttf`
	- `assets/fonts/Fredoka-Bold.ttf`

- Music:
	- Menu: `assets/audio/music/menu.mp3`
	- In-game: `assets/audio/music/song5.mp3`

- Sound Effects:
	- Flip/Rotate: `assets/audio/sfx/flip.mp3`
	- Row/Clear: `assets/audio/sfx/row_clear.mp3`
	- Panda Disappear/Special: `assets/audio/sfx/panda_disappear.mp3`
	- Pause/Resume: `assets/audio/sfx/pause.mp3`
	- Game Over: `assets/audio/sfx/gameover.mp3`

- Images:
	- Background: `assets/images/background.png`
	- Brand lockup: `assets/images/branding.png`
	- App icon (internal use): `assets/images/icon.png`
	- Logo (splash/header): `assets/images/logo.png`
	- Google Play promo assets: `googleplay/appicon.png`, `googleplay/Feature graphic.png`

Notes:
- We keep the v1 background and branding for continuity; v2 overlays introduce depth, tinting, and subtle motion blur for parallax.
- If we later add new images/animations, we’ll create them under `assets/images/v2/…` and keep v1 assets untouched.

## Visual Direction (Material 3-inspired, friendly, high contrast)

- Typography:
	- Title/H1: Fredoka Bold
	- H2/H3: Fredoka Medium
	- Body/Caption: Fredoka Regular
	- Target sizes: Titles 32–40sp; Buttons 16–18sp; Body 14–16sp; with 1.25–1.5 line-height for readability.

- Color Palette (WCAG AA contrast targets):
	- Primary: Panda Green 600 — #16A085
	- On Primary: #FFFFFF
	- Secondary: Bamboo Yellow 500 — #F4D35E
	- Tertiary: Sakura Pink 400 — #F78FB3
	- Surface: Panda Charcoal — #101417
	- Surface Variant: #1A2024
	- On Surface: #E6EEF2
	- Accent/Success: Leaf — #2ECC71
	- Danger: Ember — #E74C3C
	- Info: Sky — #3498DB

- Shape & Motion:
	- Rounded corners (8–16dp radii) and pill buttons for warmth.
	- Subtle elevation (1–4dp) to separate panels without heavy borders.
	- Easing: Standard Material ease-out for entrances; duration 150–250ms.
	- Motion budget: < 300ms for the primary screen transition; 60 FPS target.

## Information Architecture & Screens

1. Splash → Logo on tinted background, fast entrance (≤1s), proceeds to Home.
2. Home → Big Play CTA (continues last mode), “Modes” entry, Settings, and Help.
3. Modes → Lists all existing v1 modes (including Blitz). Names/labels match v1 exactly.
4. Gameplay → Minimal chrome, high-contrast board, progress/time/score top area, context-aware hints.
5. Pause → Resume, Restart, Settings (sound, haptics), Exit.
6. Results → Score, stars, bests, share, quick restart.
7. Settings → Audio mix, haptics toggle, colorblind-friendly overlays, language selection.
8. Help/How To → Illustrated basics and mode specifics.

Navigation:
- Bottom sheet for quick mode switch from Home.
- Consistent back behavior; confirm dialog on leaving mid-run.

## Gameplay — Modes (unchanged rules; Blitz enhancements only)

- All current v1 modes are retained without rule changes. Menu labels remain the same as v1. This ensures returning players feel at home.
- Blitz: refreshed special bricks (see below) to improve clarity and moment-to-moment tactics while keeping the pace and time pressure.

## Blitz Special Bricks — v2 Proposals

Goal: Keep Blitz fast and readable. Reduce “what does this do?” by favoring intuitive visuals and consistent iconography.

Candidate set (pick 3–4 for launch, the rest for rotation/experiments):
1. Bomb (3×3 clear) — Icon: small circle with 3×3 grid burst; SFX: short percussive “pop”; Screen shake: 4–6dp.
2. Stripe Row — Clears entire row; Icon: horizontal stripes; subtle sweep animation along the row.
3. Stripe Column — Clears entire column; Icon: vertical stripes; similar sweep animation.
4. Color Panda — Clears all tiles of the touched color; Icon: rainbow panda face; saturation pulse.
5. Time Freeze (+3s) — Freezes clock decay for 3s; Icon: snowflake; desaturate UI slightly during freeze.
6. Score Multiplier (x2 for 8s) — Icon: “×2”; UI: glowing score text while active.

Balancing knobs:
- Spawn weights scale with player performance to avoid snowballing.
- Stacking rules: allow one timed effect at a time; Bomb/Stripe can chain.
- Telemetry: track pick-up rates, clears, time saved, net score delta per special.

Accessibility:
- Colors supplemented with unique shapes/icons and motion so effects are distinguishable in colorblind modes.

## Audio Direction

- Music:
	- Menu: `assets/audio/music/menu.mp3` — lower energy, loop at -13 LUFS.
	- Gameplay: `assets/audio/music/song5.mp3` — slightly higher tempo; loop at -12 LUFS.
	- Crossfade: 800–1200ms on transitions.

- SFX mixing:
	- Target peak: -6 dBFS; avoid masking music.
	- Short tails for clears; longer tail for gameover.
	- Haptics mapped to clears, specials, and gameover; user-toggle in Settings.

## Accessibility & Localization

- Colorblind aid: optional outlines/patterns on special bricks; toggle in Settings.
- Text scaling: honor OS font scale up to 1.3× without layout breaks.
- Contrast: ensure ≥ 4.5:1 body text on surfaces; ≥ 3:1 for large text.
- Screen reader labels for primary actions and game state.
- Keep existing v1 locales (from `old_app/lib/l10n/…`); ensure new strings are added to ARB and translated.

## Technical Direction (no code here — implementation plan only)

- Flutter: target latest stable for v2; enable Material 3 and platform-adaptive components.
- Architecture: feature-first folders (home, modes, gameplay, settings), domain logic separate from UI, DI friendly. Prefer a mainstream state manager (e.g., Riverpod or Bloc) for testability.
- Theming: one source of truth for color/typography; dynamic color support on Android 12+ as an optional toggle.
- Asset pipeline: continue using root `assets/` with clear namespaces; sprite/sfx IDs centralized.
- Performance: 60 FPS on mid-tier devices; frame build < 8ms average; Warming caches on first load.
- Testing: fast unit tests for scoring/board logic, golden tests for key screens, and a small set of integration tests.
- Telemetry: minimal analytics events (session start, mode start/finish, blitz special usage, gameover reason). Respect privacy and opt-out.

## Migration from `old_app/`

- Preserve gameplay rules and data models; port logic with tests first to avoid regressions.
- Re-skin UI with new theme and layout; keep control affordances consistent.
- Map old screens to new routes; ensure deep links (if any) remain stable.
- Keep asset references pointing to root paths listed above; remove duplicated assets under `old_app/assets/` once parity is confirmed.

## QA & Performance Budgets

- Build size: aim within ±10% of v1; keep audio/images compressed as in v1 (reuse assets).
- Cold start: ≤ 2.0s on mid-tier Android; ≤ 1.2s on iOS A-series from recent years.
- Jank: < 1% frames over 16ms during gameplay.
- Test coverage: logic ≥ 80%; UI snapshot tests on Home, Modes, Gameplay HUD, Results.

Acceptance checks:
- All v1 modes functionally identical; Blitz specials updated per selection.
- Audio/haptics toggles work; language switching verified for existing locales.
- Accessibility checks pass (TalkBack/VoiceOver, colorblind mode, text scaling).

## Release Notes (2.0.0 • Build 9)

New
- Fully refreshed interface with improved readability and responsiveness.
- Blitz mode gets clearer, more exciting special bricks.
- Accessibility upgrades: colorblind-friendly overlays, better contrast, larger touch targets.

Improved
- Smoother animations, faster loads, and better frame pacing.
- Audio mix and haptics tuned for satisfying feedback.

Fixed
- General polish and stability fixes carried over during the v2 refresh.

## Implementation Checklist (for engineering once approved)

- [ ] Create v2 theme (colors, typography, shapes) and wire it globally.
- [ ] Rebuild Home, Modes, Gameplay HUD, Pause, Results to match v2 mocks.
- [ ] Implement chosen Blitz specials and balance tables.
- [ ] Audio mix pass and haptics mapping with toggles.
- [ ] Accessibility: colorblind mode overlays and text scaling verification.
- [ ] Port and re-point assets to root `assets/` paths; remove duplicates in `old_app/`.
- [ ] Tests: logic, golden, integration; set up CI budgets.
- [ ] Store assets refresh (icon/feature graphic) and metadata update.

## Versioning

- App version: 2.0.0 (Build 9)
- Semantic Versioning: major UI/UX overhaul, same gameplay rules (Blitz specials updated), no breaking changes to saved progress expected.

---

End of v2 outline. Once approved, this becomes the single source of truth for the implementation sprint(s) leading to submission.