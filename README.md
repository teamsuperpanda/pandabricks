# Panda Bricks 🐼

flutter pub get
flutter gen-l10n

A modern take on the classic block-falling puzzle game, featuring unique gameplay mechanics and special blocks.

## Features

- 🎮 Three Game Modes:
  - Easy Mode: Relaxed gameplay with constant speed
  - Normal Mode: Classic experience with gradual speed increase
  - Bamboo Blitz: Fast-paced mode with special blocks and board flips

- 🧱 Special Blocks:
  - 🐼 Panda Block: Clears columns when activated
  - 👻 Ghost Block: Reversed controls
  - 🐱 Cat Block: Moves unpredictably
  - 🌪️ Tornado Block: Auto-rotates while falling
  - 💣 Bomb Block: Clears its entire row and column upon placement

- 🎵 Audio Features:
  - Background music
  - Sound effects
  - Toggleable audio settings

- 🏆 Features:
  - High score tracking for each mode
  - Responsive controls (touch and keyboard)
  - Pause/Resume functionality
  - Smooth animations and visual effects

## Languages Supported

- 🇺🇸 English
- 🇪🇸 Español (Spanish)
- 🇫🇷 Français (French)
- 🇩🇪 Deutsch (German)
- 🇮🇹 Italiano (Italian)
- 🇵🇹 Português (Portuguese)
- 🇯🇵 日本語 (Japanese)
- 🇰🇷 한국어 (Korean)
- 🇨🇳 简体中文 (Simplified Chinese)
- 🇹🇼 繁體中文 (Traditional Chinese)

System language detection is supported. Users can also manually select their preferred language.

## Controls

- ⌨️ Keyboard Controls:
  - Arrow Left/Right: Move piece
  - Arrow Down: Soft drop
  - Arrow Up: Rotate piece
  - Space: Hard drop
  - P: Force Panda block (debug)
  - F: Force flip (debug)

- 📱 Touch Controls:
  - Tap: Rotate piece
  - Swipe Left/Right: Move piece
  - Swipe Down: Hard drop
  - Long Press: Soft drop

## Technical Details

Built with Flutter, featuring:
- Clean architecture with separate logic and UI layers
- Responsive design that works across different screen sizes
- Custom painters for smooth graphics
- SharedPreferences for local storage
- Just Audio for sound management

## Getting Started

1. Ensure Flutter is installed on your system
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app
5. Run `fastlane deploy` to deploy the app

## License

This project is licensed under the MIT License - see the LICENSE file for details.
