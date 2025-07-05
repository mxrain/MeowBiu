import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
/// import 'generated/app_localizations.dart';
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
    Locale('en'),
    Locale('zh'),
  ];

  /// 应用标题
  ///
  /// In zh, this message translates to:
  /// **'喵喵语录'**
  String get appTitle;

  /// 设置标题
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// 主题设置选项
  ///
  /// In zh, this message translates to:
  /// **'主题设置'**
  String get themeSettings;

  /// 主题设置描述
  ///
  /// In zh, this message translates to:
  /// **'自定义应用主题颜色和深色模式'**
  String get themeSettingsDescription;

  /// 音频设置选项
  ///
  /// In zh, this message translates to:
  /// **'音频设置'**
  String get audioSettings;

  /// 音频设置描述
  ///
  /// In zh, this message translates to:
  /// **'调整音量和播放选项'**
  String get audioSettingsDescription;

  /// 语言设置选项
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get languageSettings;

  /// 语言设置描述
  ///
  /// In zh, this message translates to:
  /// **'切换应用界面语言'**
  String get languageSettingsDescription;

  /// 存储与缓存选项
  ///
  /// In zh, this message translates to:
  /// **'存储与缓存'**
  String get storageAndCache;

  /// 存储与缓存描述
  ///
  /// In zh, this message translates to:
  /// **'管理音频缓存和存储空间'**
  String get storageAndCacheDescription;

  /// 通知设置选项
  ///
  /// In zh, this message translates to:
  /// **'通知设置'**
  String get notificationSettings;

  /// 通知设置描述
  ///
  /// In zh, this message translates to:
  /// **'管理应用通知和提醒'**
  String get notificationSettingsDescription;

  /// 帮助与反馈选项
  ///
  /// In zh, this message translates to:
  /// **'帮助与反馈'**
  String get helpAndFeedback;

  /// 帮助与反馈描述
  ///
  /// In zh, this message translates to:
  /// **'获取帮助或提交问题反馈'**
  String get helpAndFeedbackDescription;

  /// 关于选项
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// 关于描述
  ///
  /// In zh, this message translates to:
  /// **'版本、意见反馈、自动更新'**
  String get aboutDescription;

  /// 选择语言提示文本
  ///
  /// In zh, this message translates to:
  /// **'选择应用界面语言'**
  String get selectLanguage;

  /// 简体中文选项
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get simplifiedChinese;

  /// 英文选项
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  /// 语言更改提示
  ///
  /// In zh, this message translates to:
  /// **'注意：语言设置将在应用重启后生效'**
  String get languageChangeNotice;

  /// 语言已更改提示
  ///
  /// In zh, this message translates to:
  /// **'语言设置已更改'**
  String get languageChanged;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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
