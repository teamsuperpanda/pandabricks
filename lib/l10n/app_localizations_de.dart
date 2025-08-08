// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Panda Bricks';

  @override
  String get gameOver => 'SPIEL VORBEI';

  @override
  String get readyForAnotherRound => 'Bereit für eine neue Runde?';

  @override
  String finalScore(int score) {
    return 'Endpunktzahl: $score';
  }

  @override
  String get newHighScore => 'Neuer Rekord!';

  @override
  String previousHighScore(int score) {
    return 'Vorheriger: $score';
  }

  @override
  String get menu => 'MENÜ';

  @override
  String get retry => 'WIEDERHOLEN';

  @override
  String get paused => 'PAUSIERT';

  @override
  String get quit => 'BEENDEN';

  @override
  String get resume => 'FORTSETZEN';

  @override
  String get specialBricks => 'Spezialsteine';

  @override
  String get close => 'Schließen';

  @override
  String get pandaBrickDescription => 'Löscht zwei Spalten bei Kollision!';

  @override
  String get ghostBrickDescription => 'Hat umgekehrte Steuerung!';

  @override
  String get catBrickDescription => 'Bewegt sich unvorhersehbar!';

  @override
  String get tornadoBrickDescription => 'Dreht sich beim Fallen!';

  @override
  String get bombBrickDescription => 'Löscht eine Zeile und Spalte beim Platzieren!';

  @override
  String get backgroundMusic => 'Hintergrundmusik';

  @override
  String get soundEffects => 'Soundeffekte';

  @override
  String get easyMode => 'Einfacher Modus';

  @override
  String get normalMode => 'Normaler Modus';

  @override
  String get blitzMode => 'Bambus-Blitz-Modus';

  @override
  String get easyModeDescription => 'Entspanntes Gameplay mit konstanter Geschwindigkeit.';

  @override
  String get normalModeDescription => 'Klassischer Modus mit zunehmender Geschwindigkeit.';

  @override
  String get blitzModeDescription => 'Spezialsteine und Spielfeldrotationen.';

  @override
  String get systemLanguage => 'System';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italienisch';

  @override
  String get languagePortuguese => 'Portugiesisch';

  @override
  String get languageJapanese => 'Japanisch';

  @override
  String get languageKorean => 'Koreanisch';

  @override
  String get languageSimplifiedChinese => 'Vereinfachtes Chinesisch';

  @override
  String get languageTraditionalChinese => 'Traditionelles Chinesisch';

  @override
  String get languageDialogTitle => 'Sprache';

  @override
  String get help => 'Hilfe';

  @override
  String get language => 'Sprache';
}
