// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Panda Bricks';

  @override
  String get gameOver => 'PARTITA FINITA';

  @override
  String get readyForAnotherRound => 'Pronto per un altro round?';

  @override
  String finalScore(int score) {
    return 'Punteggio finale: $score';
  }

  @override
  String get newHighScore => 'Nuovo record!';

  @override
  String previousHighScore(int score) {
    return 'Precedente: $score';
  }

  @override
  String get menu => 'MENU';

  @override
  String get retry => 'RIPROVA';

  @override
  String get paused => 'IN PAUSA';

  @override
  String get quit => 'ESCI';

  @override
  String get resume => 'RIPRENDI';

  @override
  String get specialBricks => 'Mattoni speciali';

  @override
  String get close => 'Chiudi';

  @override
  String get pandaBrickDescription => 'Cancella due colonne quando collide!';

  @override
  String get ghostBrickDescription => 'Ha i controlli invertiti!';

  @override
  String get catBrickDescription => 'Si muove in modo imprevedibile!';

  @override
  String get tornadoBrickDescription => 'Ruota mentre cade!';

  @override
  String get bombBrickDescription => 'Cancella una riga e una colonna quando posizionato!';

  @override
  String get backgroundMusic => 'Musica di sottofondo';

  @override
  String get soundEffects => 'Effetti sonori';

  @override
  String get easyMode => 'Modalità facile';

  @override
  String get normalMode => 'Modalità normale';

  @override
  String get blitzMode => 'Modalità Bambù Blitz';

  @override
  String get easyModeDescription => 'Gameplay rilassato a velocità costante.';

  @override
  String get normalModeDescription => 'Modalità classica che accelera gradualmente.';

  @override
  String get blitzModeDescription => 'Mattoni speciali e rotazioni del campo.';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languageGerman => 'Tedesco';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Portoghese';

  @override
  String get languageJapanese => 'Giapponese';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageSimplifiedChinese => 'Cinese semplificato';

  @override
  String get languageTraditionalChinese => 'Cinese tradizionale';

  @override
  String get languageDialogTitle => 'Lingua';

  @override
  String get help => 'Aiuto';

  @override
  String get language => 'Lingua';
}
