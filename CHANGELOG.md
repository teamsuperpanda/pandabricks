# Changelog

All notable changes to this project are documented in this file.

## [2.4.0] - 2026-08-29

### Added
- Hold piece: stash and swap the active block (once per drop).
- DAS/ARR responsive controls for smooth held movement (keyboard and touch).
- Combo and back-to-back tracking with on-screen popups and score bonuses.
- Lock-dust particles and a line-clear flash for clearer feedback.
- Targeted screen shake on big clears (BOMB and tetris clears).

### Changed
- Game loop migrated from a pure-Flutter `CustomPainter`/`ChangeNotifier`/
  `Timer.periodic` architecture to the Flame engine (`PandaGame`). Frame-time
  based timing, retained-mode rendering, and dialogs shown as Flame overlays.
- HUD updates via a `ValueNotifier`, eliminating per-tick widget rebuilds.
- App lifecycle now pauses and resumes the game engine.

### Fixed
- Dialog button no longer overflows on narrow viewports (label scales to fit).

### Notes
- The next-queue preview (feature B) and the additional sound effects
  (feature F) described in `flame.md` section 8 were deferred and are not
  part of this release.
