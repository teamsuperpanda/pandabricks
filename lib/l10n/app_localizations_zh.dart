// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '熊猫方块';

  @override
  String get gameOver => '游戏结束';

  @override
  String get readyForAnotherRound => '准备再来一局？';

  @override
  String finalScore(int score) {
    return '最终得分：$score';
  }

  @override
  String get newHighScore => '新纪录！';

  @override
  String previousHighScore(int score) {
    return '之前：$score';
  }

  @override
  String get menu => '菜单';

  @override
  String get retry => '重试';

  @override
  String get paused => '已暂停';

  @override
  String get quit => '退出';

  @override
  String get resume => '继续';

  @override
  String get specialBricks => '特殊方块';

  @override
  String get close => '关闭';

  @override
  String get pandaBrickDescription => '碰撞时清除两列！';

  @override
  String get ghostBrickDescription => '控制反转！';

  @override
  String get catBrickDescription => '移动不可预测！';

  @override
  String get tornadoBrickDescription => '下落时旋转！';

  @override
  String get bombBrickDescription => '放置时清除一行一列！';

  @override
  String get backgroundMusic => '背景音乐';

  @override
  String get soundEffects => '音效';

  @override
  String get easyMode => '简单模式';

  @override
  String get normalMode => '普通模式';

  @override
  String get blitzMode => '竹子闪电模式';

  @override
  String get easyModeDescription => '恒定速度的轻松游戏';

  @override
  String get normalModeDescription => '逐渐加速的经典模式';

  @override
  String get blitzModeDescription => '特殊方块和棋盘翻转';

  @override
  String get systemLanguage => '系统';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languageFrench => '法语';

  @override
  String get languageGerman => '德语';

  @override
  String get languageItalian => '意大利语';

  @override
  String get languagePortuguese => '葡萄牙语';

  @override
  String get languageJapanese => '日语';

  @override
  String get languageKorean => '韩语';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁体中文';

  @override
  String get languageDialogTitle => '语言';

  @override
  String get help => '帮助';

  @override
  String get language => '语言';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw(): super('zh_TW');

  @override
  String get appTitle => '熊貓方塊';

  @override
  String get gameOver => '遊戲結束';

  @override
  String get readyForAnotherRound => '準備再來一局？';

  @override
  String finalScore(int score) {
    return '最終得分：$score';
  }

  @override
  String get newHighScore => '新紀錄！';

  @override
  String previousHighScore(int score) {
    return '之前：$score';
  }

  @override
  String get menu => '選單';

  @override
  String get retry => '重試';

  @override
  String get paused => '已暫停';

  @override
  String get quit => '退出';

  @override
  String get resume => '繼續';

  @override
  String get specialBricks => '特殊方塊';

  @override
  String get close => '關閉';

  @override
  String get pandaBrickDescription => '碰撞時清除兩列！';

  @override
  String get ghostBrickDescription => '控制反轉！';

  @override
  String get catBrickDescription => '移動不可預測！';

  @override
  String get tornadoBrickDescription => '下落時旋轉！';

  @override
  String get bombBrickDescription => '放置時清除一行一列！';

  @override
  String get backgroundMusic => '背景音樂';

  @override
  String get soundEffects => '音效';

  @override
  String get easyMode => '簡單模式';

  @override
  String get normalMode => '普通模式';

  @override
  String get blitzMode => '竹子閃電模式';

  @override
  String get easyModeDescription => '恆定速度的輕鬆遊戲';

  @override
  String get normalModeDescription => '逐漸加速的經典模式';

  @override
  String get blitzModeDescription => '特殊方塊和棋盤翻轉';

  @override
  String get systemLanguage => '系統';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageSpanish => '西班牙語';

  @override
  String get languageFrench => '法語';

  @override
  String get languageGerman => '德語';

  @override
  String get languageItalian => '意大利語';

  @override
  String get languagePortuguese => '葡萄牙語';

  @override
  String get languageJapanese => '日語';

  @override
  String get languageKorean => '韓語';

  @override
  String get languageSimplifiedChinese => '簡體中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageDialogTitle => '語言';

  @override
  String get help => '說明';

  @override
  String get language => '語言';
}
