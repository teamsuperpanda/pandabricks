import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Panda Bricks';

  @override
  String get gameOver => 'FIN DEL JUEGO';

  @override
  String get readyForAnotherRound => '¿Listo para otra ronda?';

  @override
  String finalScore(int score) {
    return 'Puntuación final: $score';
  }

  @override
  String get newHighScore => '¡Nueva puntuación máxima!';

  @override
  String previousHighScore(int score) {
    return 'Anterior: $score';
  }

  @override
  String get menu => 'MENÚ';

  @override
  String get retry => 'REINTENTAR';

  @override
  String get paused => 'PAUSADO';

  @override
  String get quit => 'SALIR';

  @override
  String get resume => 'CONTINUAR';

  @override
  String get specialBricks => 'Bloques especiales';

  @override
  String get close => 'Cerrar';

  @override
  String get pandaBrickDescription => '¡Limpia dos columnas al colisionar!';

  @override
  String get ghostBrickDescription => '¡Tiene controles invertidos!';

  @override
  String get catBrickDescription => '¡Se mueve de forma impredecible!';

  @override
  String get tornadoBrickDescription => '¡Gira mientras cae!';

  @override
  String get bombBrickDescription => '¡Limpia una fila y columna al colocarse!';

  @override
  String get backgroundMusic => 'Música de fondo';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get easyMode => 'Modo fácil';

  @override
  String get normalMode => 'Modo normal';

  @override
  String get blitzMode => 'Modo Bambú Blitz';

  @override
  String get easyModeDescription => 'Juego relajado con velocidad constante.';

  @override
  String get normalModeDescription => 'Modo clásico que aumenta gradualmente la velocidad.';

  @override
  String get blitzModeDescription => 'Bloques especiales y giros del tablero.';

  @override
  String get systemLanguage => 'Sistema';
}
