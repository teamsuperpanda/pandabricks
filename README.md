# Pandabricks

<img src="assets/images/launchscreen/panda.png" width="100" alt="Pandabricks Icon">

Pandabricks is a modern take on the classic falling blocks game, featuring a playful panda theme and unique gameplay mechanics. It's designed to be fast, fun, and accessible, with smooth animations, audio feedback, and support for multiple languages.

> Built with care by [Team Super Panda](https://www.teamsuperpanda.com)

---

## Download

Get Pandabricks on the Google Play Store:

<a href="https://play.google.com/store/apps/details?id=com.teamsuperpanda.pandabricks">
<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" width="200" alt="Get it on Google Play"></a>

---

## What is Pandabricks?

Pandabricks is a puzzle game for people who want:

- Classic falling blocks gameplay with a panda twist
- Smooth animations and particle effects
- Background music and sound effects
- Timed mode for competitive play
- Dark & light themes
- Localization support for multiple languages
- Local settings persistence
- Zero cloud overhead: No accounts, no sync setup

If you enjoy puzzle games that are relaxing yet challenging, with adorable panda aesthetics, Pandabricks is for you.

---

## How it works

Pandabricks uses a clean architecture to keep the app reliable and easy to extend.

### Data & persistence

- Local storage: `SharedPreferences` stores settings like audio preferences and locale on-device
- No external databases or cloud services

### Business logic

- `AudioProvider` (`lib/providers/audio_provider.dart`)
  - Manages background music and sound effects using audioplayers
  - Handles menu and game music tracks
- `LocaleProvider` (`lib/providers/locale_provider.dart`)
  - Manages localization preferences
- Initialization in `main()` before `runApp()`

### UI & state management

- `HomeScreen` (`lib/screens/home/home_screen.dart`)
  - Main menu with animated background and navigation
- `GameScreen` (`lib/screens/game/screen.dart`)
  - Game board, controls, HUD, and gameplay logic
- Reactive updates via `Provider` for state management

All state is managed reactively through Provider, so UI widgets automatically rebuild when data changes.

---

## Features

- **Classic gameplay** with falling blocks and line clearing
- **Panda theme** with adorable characters and animations
- **Timed mode** for competitive challenges
- **Audio system** with menu and game music tracks
- **Particle effects** and smooth animations
- **Dark mode** with persistent theme preference
- **Localization** with ARB files and intl package
- **Local settings** using SharedPreferences
- **Responsive design** for different screen sizes

---

## Tech stack

- **Framework**: [Flutter](https://flutter.dev) (Dart ^3.8.1)
- **Audio**: [Audioplayers](https://pub.dev/packages/audioplayers)
- **State management**: [Provider](https://pub.dev/packages/provider)
- **Localization**: [Intl](https://pub.dev/packages/intl)
- **Persistence**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Splash screen**: [Flutter Native Splash](https://pub.dev/packages/flutter_native_splash)
- **Animations**: [Shimmer](https://pub.dev/packages/shimmer)

---

## Getting started

### Prerequisites

- Flutter SDK: `^3.8.1`
- Dart: `^3.8.1`

Make sure Flutter is installed and configured for your platform (Android, iOS, web, desktop).

### Install & run

1. **Clone the repository**

   ```bash
   git clone https://github.com/teamsuperpanda/pandabricks.git
   cd pandabricks
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**

   ```bash
   flutter run
   ```

By default, Flutter will prompt you to pick a connected device or emulator/simulator.

### Running tests

Run the full test suite with coverage:

```bash
flutter test --coverage
```

Run tests for specific components:

```bash
flutter test test/providers/audio_provider_test.dart        # Audio management
flutter test test/providers/locale_provider_test.dart      # Localization
```

---

## Contributing

We'd love your help making Pandabricks better.

Whether it's a bug report, feature idea, design tweak, or documentation improvement—contributions of all sizes are welcome.

### Ways to contribute

- Report bugs – Open a GitHub issue with steps to reproduce
- Suggest features – Share what you'd like to see next
- Improve tests – Add or refine unit and widget tests
- Polish the UI/UX – Small design improvements are very welcome
- Docs – Help make the project easier to understand

### Contribution flow

1. **Fork** the repository
2. **Create a branch** for your idea

   ```bash
   git checkout -b feature/your-idea
   ```

3. **Make your changes**
   - Keep the existing architecture and style in mind
   - Add or update tests where it makes sense

4. **Run tests**

   ```bash
   flutter test
   ```

5. **Open a Pull Request**
   - Describe what you changed and why
   - Include screenshots/GIFs for UI changes if possible

We'll review and discuss your contribution. Thank you for helping Pandabricks grow.

---

## License & assets

The application source code is licensed under the [MIT License](LICENSE).

**Important notes:**

- The MIT License allows commercial use, but rebranding this app as your own and selling it without meaningful modifications is **not** in the spirit of this project.
- We encourage contributions and derivative works that add value and respect the original branding.

### Assets

Unless otherwise noted, all application assets (including images, audio, and fonts under `assets/`) are **not** licensed under MIT and are copyright © 2025 Team Super Panda.

See [ASSETS-LICENSE.md](ASSETS-LICENSE.md) for full asset licensing details.

---

## Learn more about Team Super Panda

Pandabricks is maintained by **Team Super Panda**, a small group that loves building thoughtful, fun games.

Visit us at **[www.teamsuperpanda.com](https://www.teamsuperpanda.com)** to learn more, follow our work, or say hi.

If you ship something cool with Pandabricks—or build your own spin‑off—let us know. We'd love to see what you create.
