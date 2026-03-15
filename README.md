# Pandabricks

<img src="assets/images/icon_org.png" width="80" alt="Pandabricks Icon">

A modern, panda-themed take on the classic falling blocks game. Fast, fun, and accessible with smooth animations and multi-language support.

> Built by [Team Super Panda](https://www.teamsuperpanda.com)

---

## Features

- **Classic Gameplay**: Familiar falling blocks with a panda twist.
- **Modes**: Includes Timed Mode for competitive play.
- **Audio & Visuals**: Background music, SFX, particle effects, and animated backgrounds.
- **Localization**: Supported in 13+ languages (en, ar, fr, zh, etc.).
- **Privacy First**: Zero cloud overhead. No accounts or tracking.
- **Modern UI**: Dark/light modes with Glass Morphism design.

---

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (^3.8.1)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Persistence**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Audio**: [Audioplayers](https://pub.dev/packages/audioplayers)
- **Localization**: [Intl](https://pub.dev/packages/intl)

---

## Getting Started

### Prerequisites
- Flutter SDK & Dart: `^3.8.1`

### Install & Run
```bash
git clone https://github.com/teamsuperpanda/pandabricks.git
cd pandabricks
flutter pub get
flutter run
```

### Tests
```bash
flutter test --coverage
```

---

## Architecture Overview

- **State**: [AudioProvider](lib/providers/audio_provider.dart) and [LocaleProvider](lib/providers/locale_provider.dart) manage settings via `SharedPreferences`.
- **UI**: Feature-based structure in `lib/`. Uses `context.watch/read` for reactive updates.
- **L10n**: ARB files in `lib/l10n/`, generated via `flutter gen-l10n`.

---

## License

- **Code**: [MIT License](LICENSE).
- **Assets**: Copyright © 2025 Team Super Panda. See [ASSETS-LICENSE.md](ASSETS-LICENSE.md).

For more, visit [www.teamsuperpanda.com](https://www.teamsuperpanda.com).
