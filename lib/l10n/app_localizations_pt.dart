// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Panda Bricks';

  @override
  String get gameOver => 'FIM DE JOGO';

  @override
  String get readyForAnotherRound => 'Pronto para outra rodada?';

  @override
  String finalScore(int score) {
    return 'Pontuação final: $score';
  }

  @override
  String get newHighScore => 'Novo recorde!';

  @override
  String previousHighScore(int score) {
    return 'Anterior: $score';
  }

  @override
  String get menu => 'MENU';

  @override
  String get retry => 'TENTAR NOVAMENTE';

  @override
  String get paused => 'PAUSADO';

  @override
  String get quit => 'SAIR';

  @override
  String get resume => 'CONTINUAR';

  @override
  String get specialBricks => 'Blocos especiais';

  @override
  String get close => 'Fechar';

  @override
  String get pandaBrickDescription => 'Limpa duas colunas ao colidir!';

  @override
  String get ghostBrickDescription => 'Tem controles invertidos!';

  @override
  String get catBrickDescription => 'Move-se de forma imprevisível!';

  @override
  String get tornadoBrickDescription => 'Gira enquanto cai!';

  @override
  String get bombBrickDescription => 'Limpa uma linha e coluna quando colocado!';

  @override
  String get backgroundMusic => 'Música de fundo';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get easyMode => 'Modo fácil';

  @override
  String get normalMode => 'Modo normal';

  @override
  String get blitzMode => 'Modo Bambú Blitz';

  @override
  String get easyModeDescription => 'Gameplay relaxado com velocidade constante.';

  @override
  String get normalModeDescription => 'Modo clássico que acelera gradualmente.';

  @override
  String get blitzModeDescription => 'Blocos especiais e rotações do tabuleiro.';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageGerman => 'Alemão';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageJapanese => 'Japonês';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageSimplifiedChinese => 'Chinês simplificado';

  @override
  String get languageTraditionalChinese => 'Chinês tradicional';
}
