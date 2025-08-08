# Panda Bricks Project Overview (Managed by Gemini)

This `GEMINI.md` file provides an overview of the Panda Bricks project, its structure, and how the Gemini CLI agent interacts with it.

## Project Description
Panda Bricks is a Flutter-based game, a modern take on the classic falling blocks game with a panda theme.

## Key Directories and Files:
- `lib/`: Contains the core Dart source code for the Flutter application.
  - `lib/main.dart`: The entry point of the application.
  - `lib/l10n/`: Localization files (`.arb` files) and generated Dart code.
  - `lib/services/`: Contains service classes for audio, high scores, and language management.
  - `lib/logic/`: Contains game logic, including brick shapes, game rules, and mode definitions.
  - `lib/models/`: Data models used throughout the application.
  - `lib/screens/`: Defines the main screens of the application.
  - `lib/widgets/`: Reusable UI components.
- `assets/`: Stores game assets like audio, fonts, and images.
- `android/`: Android-specific project files.
  - `android/app/build.gradle`: Android build configuration, including `targetSdkVersion` and `versionCode`.
- `ios/`: iOS-specific project files.
- `pubspec.yaml`: Flutter project configuration, including dependencies and versioning.

## Development Environment:
- **Framework:** Flutter
- **Language:** Dart
- **Platform Targets:** Android, iOS, Web, Linux, macOS, Windows

## Gemini Agent Interaction Notes:
- **Dependency Management:** The agent uses `flutter pub get`, `flutter pub upgrade`, and `flutter pub upgrade --major-versions` to manage Dart/Flutter dependencies.
- **Code Analysis:** `flutter analyze` is used to identify and resolve static analysis issues, errors, and warnings.
- **Localization:** `flutter gen-l10n` is used to generate localization files from `.arb` files. The agent ensures correct import paths for generated localization files.
- **Version Management:** The agent can update `pubspec.yaml` and `android/app/build.gradle` for versioning.
- **Code Refactoring:** The agent performs refactoring to improve code quality, `const` correctness, and adherence to Flutter best practices (e.g., using centralized constants for strings).
- **File Operations:** The agent uses `read_file`, `write_file`, `replace`, `list_directory`, and `search_file_content` for file system interactions.
- **Shell Commands:** `run_shell_command` is used for executing Flutter CLI commands and other shell operations.
