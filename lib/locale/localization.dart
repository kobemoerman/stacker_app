import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../l10n/messages_all.dart';

// https://medium.com/@puneetsethi25/flutter-internationalization-switching-locales-manually-f182ec9b8ff0

class AppLocalization {
  static Future<AppLocalization> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalization();
    });
  }

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  // list of locales
  String get editStackHeader {
    return Intl.message(
      "Edit Stack",
      name: 'edit_stack_header',
      desc: 'Edit Stack Title',
    );
  }

  String get createStackHeader {
    return Intl.message(
      "Create Stack",
      name: 'create_stack_header',
      desc: 'Create Stack Title',
    );
  }

  String get settingsHeader {
    return Intl.message(
      "Settings",
      name: 'settings_header',
      desc: 'settings title',
    );
  }

  String get preferencesHeader {
    return Intl.message(
      "Preferences",
      name: 'preferences_header',
      desc: 'preferences title',
    );
  }

  String get downloadHeader {
    return Intl.message(
      "Download",
      name: 'download_header',
      desc: 'download header',
    );
  }

  String get notificationHeader {
    return Intl.message(
      "Notifications",
      name: 'notifications_header',
      desc: 'notifications title',
    );
  }

  String get supportHeader {
    return Intl.message(
      "Support",
      name: 'support_header',
      desc: 'support title',
    );
  }

  String get settingsLanguage {
    return Intl.message(
      "Languages",
      name: 'settings_languages',
      desc: 'change languages',
    );
  }

  String get settingsDark {
    return Intl.message(
      "Dark Mode",
      name: 'settings_dark',
      desc: 'enable dark mode',
    );
  }

  String get settingsDownload {
    return Intl.message(
      "Find a Stack",
      name: 'settings_download',
      desc: 'download a stack online',
    );
  }

  String get settingsNotification {
    return Intl.message(
      "Allow Notifications",
      name: 'settings_notifications',
      desc: 'allow notifications',
    );
  }

  String get settingsTerms {
    return Intl.message(
      "Terms of Use",
      name: 'settings_terms',
      desc: 'terms of use',
    );
  }

  String get settingsPrivacy {
    return Intl.message(
      "Privacy Policy",
      name: 'settings_privacy',
      desc: 'check privacy policy',
    );
  }

  String get settingsHelp {
    return Intl.message(
      "Help",
      name: 'settings_help',
      desc: 'check help',
    );
  }

  String get avilableStackHeader {
    return Intl.message(
      "Available Stacks",
      name: 'available_stacks_header',
      desc: 'header to download available stacks',
    );
  }

  String get editThemeHeader {
    return Intl.message(
      "Theme",
      name: 'edit_theme_header',
      desc: 'change your user color theme',
    );
  }

  String get editNameHeader {
    return Intl.message(
      "Name",
      name: 'edit_name_header',
      desc: 'change your name header',
    );
  }

  String get editPicHeader {
    return Intl.message(
      "Picture",
      name: 'edit_pic_header',
      desc: 'change picture header',
    );
  }

  String get editPicCamera {
    return Intl.message(
      "Camera",
      name: 'edit_pic_camera',
      desc: 'change picture with camera',
    );
  }

  String get editPicGallery {
    return Intl.message(
      "Gallery",
      name: 'edit_pic_gallery',
      desc: 'change picture with gallery',
    );
  }

  String get editUsername {
    return Intl.message(
      "Edit Username",
      name: 'edit_username',
      desc: 'change profile username',
    );
  }

  String get stacksHeader {
    return Intl.message(
      "STACKS",
      name: 'stacks_header',
      desc: 'header for stack gridview',
    );
  }

  String get stacksSearch {
    return Intl.message(
      "Search for a stack...",
      name: 'stacks_search',
      desc: 'search for stack gridview',
    );
  }

  String get featuredEmptyHeader {
    return Intl.message(
      "Start studying",
      name: 'featured_empty_header',
      desc: 'content inside empty featured card',
    );
  }

  String get featuredEmptyInfo {
    return Intl.message(
      "No study to continue",
      name: 'featured_empty_info',
      desc: 'Message to display when user tries to continue studying',
    );
  }

  String get missing {
    return Intl.message(
      "Missing",
      name: 'missing',
      desc: 'missing text',
    );
  }

  String get undo {
    return Intl.message(
      "Undo",
      name: 'undo',
      desc: 'undo text',
    );
  }

  String get delete {
    return Intl.message(
      "Delete",
      name: 'delete',
      desc: 'delete text',
    );
  }

  String get deleted {
    return Intl.message(
      "Deleted",
      name: 'deleted',
      desc: 'deleted text',
    );
  }

  String get cancel {
    return Intl.message(
      "Cancel",
      name: 'cancel',
      desc: 'cancel text',
    );
  }

  String get search {
    return Intl.message(
      "Search",
      name: 'search',
      desc: 'search text',
    );
  }

  String get questions {
    return Intl.message(
      "Questions",
      name: 'questions',
      desc: 'questions text',
    );
  }

  String get question {
    return Intl.message(
      "Question",
      name: 'question',
      desc: 'question text',
    );
  }

  String get answer {
    return Intl.message(
      "Answer",
      name: 'answer',
      desc: 'answer text',
    );
  }

  String get tableName {
    return Intl.message(
      "Study",
      name: 'table_name',
      desc: 'table name',
    );
  }

  String get tableTheme {
    return Intl.message(
      "Stack name",
      name: 'table_theme',
      desc: 'table theme',
    );
  }

  String get merryChristmas {
    return Intl.message(
      "Merry Christmas",
      name: 'merry_christmas',
      desc: 'christmas greeting',
    );
  }

  String get happyThanksgiving {
    return Intl.message(
      "Happy Thanksgiving",
      name: 'happy_thanksgiving',
      desc: 'thanksgiving greeting',
    );
  }

  String get happyEaster {
    return Intl.message(
      "Happy Easter",
      name: 'happy_easter',
      desc: 'easter greeting',
    );
  }

  String get mothersDay {
    return Intl.message(
      "Happy Mothers Day",
      name: 'mothers_day',
      desc: 'mothers day greeting',
    );
  }

  String get fathersDay {
    return Intl.message(
      "Happy Fathers Day",
      name: 'fathers_day',
      desc: 'fathers day greeting',
    );
  }

  String get happyHalloween {
    return Intl.message(
      "Happy Halloween",
      name: 'happy_halloween',
      desc: 'halloween greeting',
    );
  }

  String get happyValentines {
    return Intl.message(
      "Happy Valentine's Day",
      name: 'happy_valentines',
      desc: 'valentines greeting',
    );
  }

  String get happyPatricks {
    return Intl.message(
      "Happy Saint Patrick's Day",
      name: 'happy_patricks',
      desc: 'patricks greeting',
    );
  }

  String get happyNYE {
    return Intl.message(
      "Happy New Years Eve",
      name: 'happy_nye',
      desc: 'nye greeting',
    );
  }

  String get happyNYD {
    return Intl.message(
      "Happy New Years Day",
      name: 'happy_nyd',
      desc: 'nyd greeting',
    );
  }

  String get goodNight {
    return Intl.message(
      "Good Night",
      name: 'good_night',
      desc: 'good night greeting',
    );
  }

  String get goodEvening {
    return Intl.message(
      "Good Evening",
      name: 'good_evening',
      desc: 'good evening greeting',
    );
  }

  String get goodAfternoon {
    return Intl.message(
      "Good Afternoon",
      name: 'good_afternoon',
      desc: 'good afternoon greeting',
    );
  }

  String get goodMorning {
    return Intl.message(
      "Good Morning",
      name: 'good_morning',
      desc: 'good morning greeting',
    );
  }

  String get infoMissingNameTheme {
    return Intl.message(
      "Missing stack name or theme",
      name: 'info_missing_name_theme',
      desc: 'info dialogue',
    );
  }

  String get infoNameLetterStart {
    return Intl.message(
      "Study name must start with letter",
      name: 'info_name_letter_start',
      desc: 'info dialogue',
    );
  }

  String get infoThemeLetterStart {
    return Intl.message(
      "Stack name must start with letter",
      name: 'info_theme_letter_start',
      desc: 'info dialogue',
    );
  }

  String get infoMoreQuestion {
    return Intl.message(
      "Stack must contain at least one questions",
      name: 'info_more_question',
      desc: 'info dialogue',
    );
  }

  String get infoStackExists {
    return Intl.message(
      "This stack already exists.",
      name: 'info_stack_exists',
      desc: 'info dialogue',
    );
  }

  String get infoDeleteHeader {
    return Intl.message(
      "Delete Stack?",
      name: 'info_delete_header',
      desc: 'info dialogue',
    );
  }

  String get infoDeleteStack {
    return Intl.message(
      "Are you sure you want to proceed with this action?",
      name: 'info_delete_stack',
      desc: 'info dialogue',
    );
  }

  String get infoCardInit {
    return Intl.message(
      "Tap the card to flip it.\nTap the edit icon to set content.",
      name: 'info_card_init',
      desc: 'info dialogue',
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  final Locale overriddenLocale;

  const AppLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) => ['en', 'nl'].contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) => AppLocalization.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) => false;
}
