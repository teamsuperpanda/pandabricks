// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Panda Bricks';

  @override
  String get gameOver => 'PARTIE TERMINÉE';

  @override
  String get readyForAnotherRound => 'Prêt pour une autre partie?';

  @override
  String finalScore(int score) {
    return 'Score final: $score';
  }

  @override
  String get newHighScore => 'Nouveau record!';

  @override
  String previousHighScore(int score) {
    return 'Précédent: $score';
  }

  @override
  String get menu => 'MENU';

  @override
  String get retry => 'RÉESSAYER';

  @override
  String get paused => 'PAUSE';

  @override
  String get quit => 'QUITTER';

  @override
  String get resume => 'REPRENDRE';

  @override
  String get specialBricks => 'Briques spéciales';

  @override
  String get close => 'Fermer';

  @override
  String get pandaBrickDescription => 'Efface deux colonnes lors de la collision!';

  @override
  String get ghostBrickDescription => 'A des contrôles inversés!';

  @override
  String get catBrickDescription => 'Se déplace de façon imprévisible!';

  @override
  String get tornadoBrickDescription => 'Tourne en tombant!';

  @override
  String get bombBrickDescription => 'Efface une ligne et une colonne quand placée!';

  @override
  String get backgroundMusic => 'Musique de fond';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get easyMode => 'Mode facile';

  @override
  String get normalMode => 'Mode normal';

  @override
  String get blitzMode => 'Mode Bambou Blitz';

  @override
  String get easyModeDescription => 'Gameplay détendu à vitesse constante.';

  @override
  String get normalModeDescription => 'Mode classique qui accélère progressivement.';

  @override
  String get blitzModeDescription => 'Briques spéciales et rotations du plateau.';

  @override
  String get systemLanguage => 'Système';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languagePortuguese => 'Portugais';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get languageKorean => 'Coréen';

  @override
  String get languageSimplifiedChinese => 'Chinois simplifié';

  @override
  String get languageTraditionalChinese => 'Chinois traditionnel';

  @override
  String get languageDialogTitle => 'Langue';
  
  @override
  String get help => 'Aide';
  
  @override
  String get language => 'Langue';
}
