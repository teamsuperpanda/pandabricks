import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('zh'),
    Locale('zh', 'TW')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Panda Bricks'**
  String get appTitle;

  /// Text shown when the game ends
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get gameOver;

  /// Question asked after game over
  ///
  /// In en, this message translates to:
  /// **'Ready for Another Round?'**
  String get readyForAnotherRound;

  /// Shows the final score
  ///
  /// In en, this message translates to:
  /// **'Final Score: {score}'**
  String finalScore(int score);

  /// Shown when player achieves a new high score
  ///
  /// In en, this message translates to:
  /// **'New High Score!'**
  String get newHighScore;

  /// Shows the previous high score
  ///
  /// In en, this message translates to:
  /// **'Previous: {score}'**
  String previousHighScore(int score);

  /// Menu button text
  ///
  /// In en, this message translates to:
  /// **'MENU'**
  String get menu;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// Shown when game is paused
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get paused;

  /// Quit button text
  ///
  /// In en, this message translates to:
  /// **'QUIT'**
  String get quit;

  /// Resume button text
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resume;

  /// Title for special bricks help section
  ///
  /// In en, this message translates to:
  /// **'Special Bricks'**
  String get specialBricks;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Description of panda brick
  ///
  /// In en, this message translates to:
  /// **'Clears two columns when it collides!'**
  String get pandaBrickDescription;

  /// Description of ghost brick
  ///
  /// In en, this message translates to:
  /// **'Has reversed controls!'**
  String get ghostBrickDescription;

  /// Description of cat brick
  ///
  /// In en, this message translates to:
  /// **'Moves unpredictably!'**
  String get catBrickDescription;

  /// Description of tornado brick
  ///
  /// In en, this message translates to:
  /// **'Spins as it falls!'**
  String get tornadoBrickDescription;

  /// Description of bomb brick
  ///
  /// In en, this message translates to:
  /// **'Clears a row and column when placed!'**
  String get bombBrickDescription;

  /// Background music toggle label
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get backgroundMusic;

  /// Sound effects toggle label
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// Easy mode title
  ///
  /// In en, this message translates to:
  /// **'Easy Mode'**
  String get easyMode;

  /// Normal mode title
  ///
  /// In en, this message translates to:
  /// **'Normal Mode'**
  String get normalMode;

  /// Blitz mode title
  ///
  /// In en, this message translates to:
  /// **'Bamboo Blitz Mode'**
  String get blitzMode;

  /// Description of easy mode
  ///
  /// In en, this message translates to:
  /// **'Relaxed gameplay with constant speed.'**
  String get easyModeDescription;

  /// Description of normal mode
  ///
  /// In en, this message translates to:
  /// **'Classic mode that gradually speeds up.'**
  String get normalModeDescription;

  /// Description of blitz mode
  ///
  /// In en, this message translates to:
  /// **'Special bricks and board flips.'**
  String get blitzModeDescription;

  /// System language option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// Italian language option
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// Portuguese language option
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// Japanese language option
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// Korean language option
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// Simplified Chinese language option
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageSimplifiedChinese;

  /// Traditional Chinese language option
  ///
  /// In en, this message translates to:
  /// **'繁體中文'**
  String get languageTraditionalChinese;

  /// Title for the language selection dialog
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageDialogTitle;

  /// Help label
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Language label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'ja', 'ko', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.countryCode) {
    case 'TW': return AppLocalizationsZhTw();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'pt': return AppLocalizationsPt();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
