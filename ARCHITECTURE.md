# Architecture Overview

[architecture.md](https://architecture.md/) template for rapid codebase comprehension. Update as the codebase evolves.

## 1. Project Structure

```
pandabricks/
├── lib/                    # Main application source code
│   ├── main.dart           # App entry point, provider setup, lifecycle handling
│   ├── theme.dart           # Dark theme definition (Material 3, cyan/neon palette)
│   ├── l10n.yaml            # ARB localization config
│   ├── data/               # Static data
│   │   └── locale_display_names.dart  # Native language name map
│   ├── l10n/               # Localization (13 ARB files, generated code)
│   ├── models/             # Pure data models
│   │   ├── game_types.dart         # FallingBlock enum, ActivePiece, CellRender, EffectRender, enums
│   │   ├── game_settings.dart      # GameSettings wrapper with named constructors per mode
│   │   └── game_input_callbacks.dart # Input callback interface
│   ├── navigation/          # Routing
│   │   └── app_router.dart  # go_router with / (home) and /game (game screen) routes
│   ├── providers/           # ChangeNotifier providers
│   │   ├── audio_provider.dart    # Music/SFX management + SharedPreferences persistence
│   │   └── locale_provider.dart   # Locale state + SharedPreferences persistence
│   ├── screens/             # Full-screen pages
│   │   ├── home/
│   │   │   └── home_screen.dart   # Main menu with animated background, mode cards
│   │   └── game/
│   │       ├── screen.dart        # GameScreen widget
│   │       ├── game_view.dart    # Part: _GameView layout
│   │       ├── game.dart          # Core Game ChangeNotifier (board, spawning, scoring)
│   │       ├── game_engine.dart   # Part: collision detection, movement, ghost calc
│   │       ├── game_effects.dart   # Part: column/row sparkle effects
│   │       ├── special_blocks.dart # Part: 5 special block behaviors
│   │       ├── game_input_handler.dart  # Keyboard + touch input
│   │       └── game_dialog_mediator.dart # Game dialog orchestration
│   ├── services/            # Thin service layer
│   │   └── logging.dart     # DebugPrint-based error logging
│   ├── dialogs/             # Modal dialogs
│   │   ├── game/            # Pause, game over, restart, main menu confirm, custom game
│   │   └── home/            # Help, language selector
│   └── widgets/             # Reusable UI components
│       ├── game/            # BoardPainter (CustomPainter), controls, HUD, preview, timer
│       └── home/            # Glassmorphism cards, animated background, particle effects
├── test/                   # Tests mirroring lib/ structure (~37 test files)
│   ├── mocks/               # MockAudioProvider subclass
│   ├── models/              # GameSettings tests
│   ├── providers/           # AudioProvider + LocaleProvider tests
│   ├── screens/             # Game engine, lifecycle, dialog mediator, home screen tests
│   ├── widgets/             # Per-widget tests (board painter, controls, HUD, etc.)
│   ├── dialogs/             # Dialog integration + per-dialog tests
│   ├── navigation/          # App router tests
│   └── integration/         # App-level integration tests
├── assets/                 # Static assets
│   ├── audio/
│   │   ├── music/          # 7 music tracks (6 game + 1 menu loop)
│   │   └── sfx/            # 6 sound effects
│   ├── fonts/              # Fredoka family + 7 Noto variant fonts
│   └── images/             # Logos, icons, launch screens, store screenshots
├── android/                # Android platform files
├── ios/                    # iOS platform files
├── web/                    # Web platform PWA artifacts
├── pubspec.yaml            # Project manifest
├── analysis_options.yaml   # Linting rules (very_good_analysis)
├── README.md               # Project overview
├── CONTRIBUTING.md         # Contribution guidelines
├── ASSETS-LICENSE.md       # Asset copyright notice
└── ARCHITECTURE.md         # This document
```

## 2. High-Level System Diagram

```
[User] <--> [Flutter App]
                  |
                  No backend. No cloud. No accounts.
                  All state is in-memory per game session.
                  Audio prefs and locale persisted via SharedPreferences.
```

Game state is transient and lives only for the duration of a game session. Only user preferences (audio toggles, locale) are persisted across sessions via SharedPreferences.

## 3. Core Components

### 3.1. Flutter App

**Name:** Panda Bricks

**Description:** A Tetris-like falling blocks game with a playful panda theme. Features 4 game modes (Classic, Time Challenge, Blitz with special blocks, Custom), 12 block types including 5 special blocks, on-screen and keyboard controls, and full audio.

**Technologies:** Flutter, Dart 3.8+, Provider, go_router, audioplayers, SharedPreferences

**Deployment:** Google Play, Apple App Store, Web (PWA)

### 3.2. Game Engine

**Name:** Game (ChangeNotifier)

**Description:** Core game state machine in `lib/screens/game/game.dart`. Uses Dart `part` directives to merge `game_engine.dart`, `special_blocks.dart`, and `game_effects.dart` into one library for internal access. Manages board grid (`List<List<int?>>`), piece spawning (7-bag system), rotation/movement, line clearing, scoring, speed curve, ghost piece.

**Sub-components:**
- `game_engine.dart` — Collision detection, movement application, ghost calculation
- `special_blocks.dart` — 5 special block behaviors (PANDA clears column, BOMB clears row+column, GHOST inverted controls, CAT random movement, TORNADO auto-rotation)
- `game_effects.dart` — Sparkle effects on line/column clears with animation timing

**Technologies:** Dart, CustomPainter, Canvas API

### 3.3. Rendering Engine

**Name:** BoardPainter (CustomPainter)

**Description:** Canvas-based rendering for the game board. Draws grid lines, filled cells with gradients and glow effects, ghost piece overlay, emoji rendering for special blocks, and sparkle effects for line clears.

**Technologies:** Flutter CustomPainter, Canvas, gradient shaders, ImageFilter blur

### 3.4. Audio System

**Name:** AudioProvider

**Description:** Music and SFX management via `audioplayers`. Menu loop + 6 randomized game tracks. Volume control with SharedPreferences persistence. Handles app lifecycle (pause/resume on backgrounding).

**Technologies:** audioplayers ^6.7.1, SharedPreferences

### 3.5. State Management

**Name:** Provider (ChangeNotifier)

**Description:** Three providers:
- `Game` — Core game state (board, score, level, piece, effects)
- `AudioProvider` — Music/SFX toggles
- `LocaleProvider` — Language override

**Technologies:** provider ^6.1.5, ChangeNotifier

### 3.6. Navigation

**Name:** go_router

**Description:** Declarative routing with two routes:
- `/` — Home screen (menu)
- `/game` — Game screen (accepts `GameSettings` as route extra)

**Technologies:** go_router ^17.2.0

## 4. Module Boundary Convention

- **`screens/`** — Full-screen pages composing widgets and managing screen-level state.
- **`widgets/`** — Reusable UI components (`game/` and `home/` subdirectories). No business logic.
- **`models/`** — Pure data models and type definitions. No Flutter imports.
- **`providers/`** — ChangeNotifier providers for app-wide state (audio, locale).
- **`dialogs/`** — Modal overlay dialogs organized by screen context (`game/`, `home/`).
- **`services/`** — Thin service layer (currently only logging).

**Dependency rule:** `widgets/` and `dialogs/` never import from `screens/`. `screens/` may import from `widgets/`, `dialogs/`, and `providers/`. `models/` has no dependencies on other app layers.

## 5. Data Stores

### 5.1. SharedPreferences (Key-Value)

**Name:** SharedPreferences

**Type:** Platform key-value storage

**Purpose:** Persists user preferences across sessions.

**Keys:** `musicEnabled` (bool), `sfxEnabled` (bool), `locale_language` (String), `locale_country` (String), `locale_script` (String)

### 5.2. In-Memory Game State

**Name:** Game (ChangeNotifier)

**Type:** Transient Dart state

**Purpose:** All game state lives in memory for the duration of a game session. Lost on navigation away. No persistence needed.

**State fields:** Board grid, current/next piece, score, lines, level, time remaining, effects list

## 6. External Integrations / APIs

None. The app is fully local with no network requests, no analytics, and no backend services.

## 7. Deployment & Infrastructure

- **CI/CD:** GitHub Actions (`ci.yml`) — analyze, format check, test with coverage
- **Platforms:** Android, iOS, Web
- **Code Generation:** `build_runner` for mockito test mocks only
- **Distribution:** Google Play, Apple App Store
- **Dependabot:** Weekly pub and GitHub Actions updates

## 8. Security Considerations

- **Data at rest:** Only SharedPreferences (audio toggles, locale). No user data stored.
- **Network:** No network requests. No telemetry. No ads.

## 9. Development & Testing

- **Testing:** `flutter_test` + `mockito` for unit and widget tests (~37 test files). Coverage via `flutter test --coverage`.
- **Linting:** `very_good_analysis` + `dart_code_linter`
- **Localization:** ARB-based (`l10n.yaml`, 13 ARB files)
- **Test mocks:** `MockAudioProvider` (subclassed, not generated) for audio-free testing; mockito-generated mocks via `build_runner`

## 10. Future Considerations

- **Online leaderboards:** Optional integration for global high scores
- **Additional game modes:** Puzzle mode, multiplayer
- **Haptic feedback:** Vibration on piece lock and line clears
- **Accessibility:** Screen reader support for game elements

## 11. Project Identification

**Project Name:** Panda Bricks

**Repository URL:** https://github.com/teamsuperpanda/pandabricks

**License:** PolyForm Noncommercial 1.0.0

**Date of Last Update:** 2026-07-24

## 12. Glossary

**7-bag system:** Tetris-standard randomizer that shuffles all 7 piece types into a bag, ensuring even distribution before repeating

**Ghost piece:** Transparent preview showing where the current piece will land

**Special blocks:** 5 non-standard blocks with unique behaviors (PANDA, BOMB, GHOST, CAT, TORNADO)

**go_router:** Declarative routing library for Flutter with type-safe parameter passing

**CustomPainter:** Flutter class for direct Canvas drawing, used here for the game board

**audioplayers:** Cross-platform audio playback plugin for Flutter
