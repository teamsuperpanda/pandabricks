# Pandabricks Flutter App AI Instructions

## Architecture Overview
- **Structure**: Feature-based folders in `lib/` (providers/, screens/, widgets/, dialogs/, l10n/). Entry point `lib/main.dart` wraps app in `MultiProvider` for `AudioProvider` and `LocaleProvider`.
- **State Management**: Provider pattern for reactive state. Audio settings via `ValueNotifier<bool>`, locale via `Locale?`. Data flows from providers to screens/widgets via `context.watch`/`context.read`.
- **Screens**: `HomeScreen` (menu with animations), `GameScreen` (gameplay with board, controls, HUD). Routes defined in `MaterialApp`.
- **Components**: Widgets in `widgets/` subfolders (e.g., `widgets/game/board_painter.dart` for game rendering). Dialogs in `dialogs/game/` for pauses, game over.
- **Localization**: ARB files in `l10n/`, generated classes via `flutter gen-l10n`. Supported locales: en, ar, bn, de, es, fr, hi, it, ja, ko, ru, ur, zh.

## Critical Workflows
- **Dependencies**: `flutter pub get` to install packages (audioplayers, provider, shared_preferences, intl).
- **Testing**: `flutter test` runs unit tests in `test/`. Mocks in `test/mocks/` extend real providers with `enablePlatformAudio: false` to avoid platform calls.
- **Debugging**: `flutter run` for hot reload. Use VS Code Flutter extension for breakpoints. Audio disposed on app pause via `didChangeAppLifecycleState`.
- **Building**: `flutter build apk` for Android release. Icons/splash via `flutter_launcher_icons` and `flutter_native_splash` (run `dart run` commands as noted in pubspec.yaml).

## Project-Specific Conventions
- **Audio Handling**: `AudioProvider` plays menu/game music from `assets/audio/`, toggles via `ValueNotifier`, persists with `SharedPreferences`. Game music random from `gameTracks` list.
- **Persistence**: Settings saved to SharedPreferences in providers.
- **UI Patterns**: Glass morphism cards (`GlassMorphCard`), animated backgrounds (`AnimatedBackground`), ambient particles (`AmbientParticles`). Font: Fredoka.
- **Testing**: Mirror `lib/` structure in `test/`. Use `MockAudioProvider` for widget tests to skip audio plugins.
- **Integration**: Audio via audioplayers AssetSource, locale sets MaterialApp locale for l10n.

## External Dependencies & Communication
- **audioplayers**: For background music and SFX, looped playback.
- **shared_preferences**: Persist audio/locale settings.
- **flutter_localizations/intl**: Generate translations from ARB files.
- **Context7 Access**: Use MCP server for up-to-date library documentation (e.g., resolve library IDs for audioplayers docs).

Reference: `lib/main.dart`, `lib/providers/audio_provider.dart`, `lib/providers/locale_provider.dart`, `pubspec.yaml`.</content>
<parameter name="filePath">/home/howley/Documents/GitHub/pandabricks/.github/copilot-instructions.md