// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Panda Bricks';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get readyForAnotherRound => 'Ready for Another Round?';

  @override
  String finalScore(int score) {
    return 'Final Score: $score';
  }

  @override
  String get newHighScore => 'New High Score!';

  @override
  String previousHighScore(int score) {
    return 'Previous: $score';
  }

  @override
  String get menu => 'MENU';

  @override
  String get retry => 'RETRY';

  @override
  String get paused => 'PAUSED';

  @override
  String get quit => 'QUIT';

  @override
  String get resume => 'RESUME';

  @override
  String get specialBricks => 'Special Bricks';

  @override
  String get close => 'Close';

  @override
  String get pandaBrickDescription => 'Clears two columns when it collides!';

  @override
  String get ghostBrickDescription => 'Has reversed controls!';

  @override
  String get catBrickDescription => 'Moves unpredictably!';

  @override
  String get tornadoBrickDescription => 'Spins as it falls!';

  @override
  String get bombBrickDescription => 'Clears a row and column when placed!';

  @override
  String get backgroundMusic => 'Background Music';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get easyMode => 'Easy Mode';

  @override
  String get normalMode => 'Normal Mode';

  @override
  String get blitzMode => 'Bamboo Blitz Mode';

  @override
  String get easyModeDescription => 'Relaxed gameplay with constant speed.';

  @override
  String get normalModeDescription => 'Classic mode that gradually speeds up.';

  @override
  String get blitzModeDescription => 'Special bricks and board flips.';

  @override
  String get systemLanguage => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';
}
