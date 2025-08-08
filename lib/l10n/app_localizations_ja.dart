// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'パンダブリックス';

  @override
  String get gameOver => 'ゲームオーバー';

  @override
  String get readyForAnotherRound => 'もう一度プレイしますか？';

  @override
  String finalScore(int score) {
    return '最終スコア：$score';
  }

  @override
  String get newHighScore => '新記録！';

  @override
  String previousHighScore(int score) {
    return '前回：$score';
  }

  @override
  String get menu => 'メニュー';

  @override
  String get retry => 'リトライ';

  @override
  String get paused => '一時停止';

  @override
  String get quit => '終了';

  @override
  String get resume => '再開';

  @override
  String get specialBricks => '特殊ブロック';

  @override
  String get close => '閉じる';

  @override
  String get pandaBrickDescription => '衝突時に2列消去！';

  @override
  String get ghostBrickDescription => '操作が反転！';

  @override
  String get catBrickDescription => '予測不能な動き！';

  @override
  String get tornadoBrickDescription => '落下中に回転！';

  @override
  String get bombBrickDescription => '設置時に行と列を消去！';

  @override
  String get backgroundMusic => 'BGM';

  @override
  String get soundEffects => '効果音';

  @override
  String get easyMode => 'イージーモード';

  @override
  String get normalMode => 'ノーマルモード';

  @override
  String get blitzMode => 'バンブーブリッツモード';

  @override
  String get easyModeDescription => '一定速度のリラックスプレイ';

  @override
  String get normalModeDescription => '徐々に加速するクラシックモード';

  @override
  String get blitzModeDescription => '特殊ブロックと盤面回転';

  @override
  String get systemLanguage => 'システム';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageSpanish => 'スペイン語';

  @override
  String get languageFrench => 'フランス語';

  @override
  String get languageGerman => 'ドイツ語';

  @override
  String get languageItalian => 'イタリア語';

  @override
  String get languagePortuguese => 'ポルトガル語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageKorean => '韓国語';

  @override
  String get languageSimplifiedChinese => '簡体字中国語';

  @override
  String get languageTraditionalChinese => '繁体字中国語';

  @override
  String get languageDialogTitle => '言語';

  @override
  String get help => 'ヘルプ';

  @override
  String get language => '言語';
}
