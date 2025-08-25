// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Панда Брикс';

  @override
  String get gameModes => 'Режимы игры';

  @override
  String get classicMode => 'Классический режим';

  @override
  String get classicModeDescription => 'Классические падающие блоки.';

  @override
  String get timeChallenge => 'Испытание на время';

  @override
  String get timeChallengeDescription => 'Побейте часы. Быстрее!';

  @override
  String get blitzMode => 'Блиц-режим';

  @override
  String get blitzModeDescription =>
      'Хаос, особые кирпичи и переворачивание стола!';

  @override
  String get audio => 'Аудио';

  @override
  String get help => 'Помощь';

  @override
  String get language => 'Язык';

  @override
  String get specialBricks => 'Особые кирпичи';

  @override
  String get pandaBrick => 'Кирпич-панда';

  @override
  String get pandaBrickDescription =>
      'Очищает всю колонку, когда приземляется!';

  @override
  String get ghostBrick => 'Кирпич-призрак';

  @override
  String get ghostBrickDescription => 'Имеет обратное управление!';

  @override
  String get catBrick => 'Кирпич-кошка';

  @override
  String get catBrickDescription => 'Движется непредсказуемо при падении!';

  @override
  String get tornadoBrick => 'Кирпич-торнадо';

  @override
  String get tornadoBrickDescription => 'Вращается автоматически при падении!';

  @override
  String get bombBrick => 'Кирпич-бомба';

  @override
  String get bombBrickDescription =>
      'Очищает всю строку и столбец при размещении!';

  @override
  String get close => 'Закрыть';

  @override
  String get mainMenu => 'Главное меню';

  @override
  String get restart => 'Перезапустить';

  @override
  String get pause => 'Пауза';

  @override
  String get resume => 'Продолжить';

  @override
  String get next => 'Далее';

  @override
  String get timeLeft => 'Оставшееся время';

  @override
  String get gameOver => 'Игра окончена';

  @override
  String get finalScore => 'Итоговый счет';

  @override
  String get score => 'Счет';

  @override
  String get level => 'Уровень';

  @override
  String get lines => 'Линии';

  @override
  String get playAgain => 'Играть снова';

  @override
  String get returnToMainMenu => 'Вернуться в главное меню?';

  @override
  String get progressWillBeLost =>
      'Ваш текущий игровой прогресс будет потерян.';

  @override
  String get cancel => 'Отмена';

  @override
  String get gamePaused => 'Игра на паузе';

  @override
  String get yourGameIsPaused => 'Ваша игра в настоящее время на паузе';

  @override
  String get restartGame => 'Перезапустить игру?';

  @override
  String get areYouSureYouWantToRestart =>
      'Вы уверены, что хотите перезапустить?\nВаш текущий прогресс будет потерян.';

  @override
  String get music => 'Музыка';

  @override
  String get sfx => 'Звуковые эффекты';
}
