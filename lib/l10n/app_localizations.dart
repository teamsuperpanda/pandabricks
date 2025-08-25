import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_ur.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('ur'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Panda Bricks'**
  String get appTitle;

  /// No description provided for @gameModes.
  ///
  /// In en, this message translates to:
  /// **'Game Modes'**
  String get gameModes;

  /// No description provided for @classicMode.
  ///
  /// In en, this message translates to:
  /// **'Classic Mode'**
  String get classicMode;

  /// No description provided for @classicModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Classic falling blocks.'**
  String get classicModeDescription;

  /// No description provided for @timeChallenge.
  ///
  /// In en, this message translates to:
  /// **'Time Challenge'**
  String get timeChallenge;

  /// No description provided for @timeChallengeDescription.
  ///
  /// In en, this message translates to:
  /// **'Beat the clock. Go fast!'**
  String get timeChallengeDescription;

  /// No description provided for @blitzMode.
  ///
  /// In en, this message translates to:
  /// **'Blitz Mode'**
  String get blitzMode;

  /// No description provided for @blitzModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Chaos with special bricks'**
  String get blitzModeDescription;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @specialBricks.
  ///
  /// In en, this message translates to:
  /// **'Special Bricks'**
  String get specialBricks;

  /// No description provided for @pandaBrick.
  ///
  /// In en, this message translates to:
  /// **'Panda Brick'**
  String get pandaBrick;

  /// No description provided for @pandaBrickDescription.
  ///
  /// In en, this message translates to:
  /// **'Clears entire column when it lands!'**
  String get pandaBrickDescription;

  /// No description provided for @ghostBrick.
  ///
  /// In en, this message translates to:
  /// **'Ghost Brick'**
  String get ghostBrick;

  /// No description provided for @ghostBrickDescription.
  ///
  /// In en, this message translates to:
  /// **'Has inverted controls!'**
  String get ghostBrickDescription;

  /// No description provided for @catBrick.
  ///
  /// In en, this message translates to:
  /// **'Cat Brick'**
  String get catBrick;

  /// No description provided for @catBrickDescription.
  ///
  /// In en, this message translates to:
  /// **'Moves unpredictably as it falls!'**
  String get catBrickDescription;

  /// No description provided for @tornadoBrick.
  ///
  /// In en, this message translates to:
  /// **'Tornado Brick'**
  String get tornadoBrick;

  /// No description provided for @tornadoBrickDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically rotates as it falls!'**
  String get tornadoBrickDescription;

  /// No description provided for @bombBrick.
  ///
  /// In en, this message translates to:
  /// **'Bomb Brick'**
  String get bombBrick;

  /// No description provided for @bombBrickDescription.
  ///
  /// In en, this message translates to:
  /// **'Clears entire row and column when placed!'**
  String get bombBrickDescription;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get mainMenu;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time Left'**
  String get timeLeft;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'Final Score'**
  String get finalScore;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @lines.
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get lines;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @returnToMainMenu.
  ///
  /// In en, this message translates to:
  /// **'Return to Main Menu?'**
  String get returnToMainMenu;

  /// No description provided for @progressWillBeLost.
  ///
  /// In en, this message translates to:
  /// **'Your current game progress will be lost.'**
  String get progressWillBeLost;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @gamePaused.
  ///
  /// In en, this message translates to:
  /// **'Game Paused'**
  String get gamePaused;

  /// No description provided for @yourGameIsPaused.
  ///
  /// In en, this message translates to:
  /// **'Your game is currently paused'**
  String get yourGameIsPaused;

  /// No description provided for @restartGame.
  ///
  /// In en, this message translates to:
  /// **'Restart Game?'**
  String get restartGame;

  /// No description provided for @areYouSureYouWantToRestart.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restart?\nYour current progress will be lost.'**
  String get areYouSureYouWantToRestart;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @sfx.
  ///
  /// In en, this message translates to:
  /// **'SFX'**
  String get sfx;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'ko',
    'ru',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
