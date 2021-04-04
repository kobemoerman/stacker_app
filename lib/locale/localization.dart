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

  String get userHeader {
    return Intl.message(
      "Good Morning,",
      name: 'user_header',
      desc: 'home page header',
    );
  }

  String get statsHeader {
    return Intl.message(
      "STATS",
      name: 'stats_header',
      desc: 'statistics title',
    );
  }

  String get stackHeader {
    return Intl.message(
      "STACKS:",
      name: 'stack_header',
      desc: 'stack list title',
    );
  }

  String get statStreak {
    return Intl.message(
      "Streak",
      name: 'stat_streak',
      desc: 'stat day streak',
    );
  }

  String get statAverage {
    return Intl.message(
      "Last 7 days",
      name: 'stat_average',
      desc: 'stat 7 day average',
    );
  }

  String get statExam {
    return Intl.message(
      "Next exam",
      name: 'stat_exam',
      desc: 'stat next exam',
    );
  }

  String get streakInfo {
    return Intl.message(
      "days",
      name: 'streak_info',
      desc: 'streak number of days',
    );
  }

  String get averageInfo {
    return Intl.message(
      "minutes",
      name: 'average_info',
      desc: 'average minutes studied',
    );
  }

  String get examInfo {
    return Intl.message(
      "days",
      name: 'exam_info',
      desc: 'days until next exam',
    );
  }

  String get mond {
    return Intl.message(
      "M",
      name: 'mond',
      desc: 'Monday',
    );
  }

  String get tues {
    return Intl.message(
      "T",
      name: 'tues',
      desc: 'Tuesday',
    );
  }

  String get wed {
    return Intl.message(
      "W",
      name: 'wed',
      desc: 'Wednesday',
    );
  }

  String get thur {
    return Intl.message(
      "T",
      name: 'thur',
      desc: 'Thursday',
    );
  }

  String get fri {
    return Intl.message(
      "F",
      name: 'fri',
      desc: 'Friday',
    );
  }

  String get sat {
    return Intl.message(
      "S",
      name: 'sat',
      desc: 'Saturday',
    );
  }

  String get sun {
    return Intl.message(
      "S",
      name: 'sun',
      desc: 'Sunday',
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

  String get editNameHeader {
    return Intl.message(
      "Change Name",
      name: 'edit_name_header',
      desc: 'change your name header',
    );
  }

  String get editPicHeader {
    return Intl.message(
      "Change Profile Picture",
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

  String get editCancel {
    return Intl.message(
      "Cancel",
      name: 'edit_cancel',
      desc: 'cancel edit profile',
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
