// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '판다 브릭스';

  @override
  String get gameOver => '게임 오버';

  @override
  String get readyForAnotherRound => '다시 도전하시겠습니까?';

  @override
  String finalScore(int score) {
    return '최종 점수: $score';
  }

  @override
  String get newHighScore => '신기록!';

  @override
  String previousHighScore(int score) {
    return '이전: $score';
  }

  @override
  String get menu => '메뉴';

  @override
  String get retry => '재시도';

  @override
  String get paused => '일시정지';

  @override
  String get quit => '종료';

  @override
  String get resume => '계속하기';

  @override
  String get specialBricks => '특수 블록';

  @override
  String get close => '닫기';

  @override
  String get pandaBrickDescription => '충돌 시 두 열 제거!';

  @override
  String get ghostBrickDescription => '반전된 조작!';

  @override
  String get catBrickDescription => '예측불가한 움직임!';

  @override
  String get tornadoBrickDescription => '낙하 중 회전!';

  @override
  String get bombBrickDescription => '배치 시 행과 열 제거!';

  @override
  String get backgroundMusic => '배경음악';

  @override
  String get soundEffects => '효과음';

  @override
  String get easyMode => '쉬움 모드';

  @override
  String get normalMode => '일반 모드';

  @override
  String get blitzMode => '대나무 블리츠 모드';

  @override
  String get easyModeDescription => '일정한 속도의 편안한 게임플레이';

  @override
  String get normalModeDescription => '점차 가속되는 클래식 모드';

  @override
  String get blitzModeDescription => '특수 블록과 보드 회전';

  @override
  String get systemLanguage => '시스템';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageSpanish => '스페인어';

  @override
  String get languageFrench => '프랑스어';

  @override
  String get languageGerman => '독일어';

  @override
  String get languageItalian => '이탈리아어';

  @override
  String get languagePortuguese => '포르투갈어';

  @override
  String get languageJapanese => '일본어';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageSimplifiedChinese => '중국어 간체';

  @override
  String get languageTraditionalChinese => '중국어 번체';

  @override
  String get languageDialogTitle => '언어';

  @override
  String get help => '도움말';

  @override
  String get language => '언어';
}
