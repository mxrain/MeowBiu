// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Meow Quotes';

  @override
  String get settings => 'Settings';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get themeSettingsDescription =>
      'Customize app theme colors and dark mode';

  @override
  String get audioSettings => 'Audio Settings';

  @override
  String get audioSettingsDescription => 'Adjust volume and playback options';

  @override
  String get languageSettings => 'Language';

  @override
  String get languageSettingsDescription =>
      'Switch application interface language';

  @override
  String get storageAndCache => 'Storage & Cache';

  @override
  String get storageAndCacheDescription =>
      'Manage audio cache and storage space';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationSettingsDescription =>
      'Manage app notifications and alerts';

  @override
  String get helpAndFeedback => 'Help & Feedback';

  @override
  String get helpAndFeedbackDescription => 'Get help or submit feedback';

  @override
  String get about => 'About';

  @override
  String get aboutDescription => 'Version, feedback, auto-update';

  @override
  String get selectLanguage => 'Select application language';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get languageChangeNotice =>
      'Note: Language settings will take effect after restarting the app';

  @override
  String get languageChanged => 'Language settings updated';
}
