// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '喵喵语录';

  @override
  String get settings => '设置';

  @override
  String get themeSettings => '主题设置';

  @override
  String get themeSettingsDescription => '自定义应用主题颜色和深色模式';

  @override
  String get audioSettings => '音频设置';

  @override
  String get audioSettingsDescription => '调整音量和播放选项';

  @override
  String get languageSettings => '语言';

  @override
  String get languageSettingsDescription => '切换应用界面语言';

  @override
  String get storageAndCache => '存储与缓存';

  @override
  String get storageAndCacheDescription => '管理音频缓存和存储空间';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get notificationSettingsDescription => '管理应用通知和提醒';

  @override
  String get helpAndFeedback => '帮助与反馈';

  @override
  String get helpAndFeedbackDescription => '获取帮助或提交问题反馈';

  @override
  String get about => '关于';

  @override
  String get aboutDescription => '版本、意见反馈、自动更新';

  @override
  String get selectLanguage => '选择应用界面语言';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get languageChangeNotice => '注意：语言设置将在应用重启后生效';

  @override
  String get languageChanged => '语言设置已更改';
}
