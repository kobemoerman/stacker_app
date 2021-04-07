import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale/localization.dart';
import 'screens/page_stats.dart';
import 'theme.dart';
import 'model/studystack.dart';
import 'model/user_inherited.dart';
import 'screens/page_home.dart';
import 'screens/page_study.dart';
import 'screens/page_stack.dart';
import 'screens/page_intro.dart';
import 'screens/page_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();

    final pref = await SharedPreferences.getInstance();

    final intro = pref.getBool('intro') ?? true;
    if (intro) pref.setBool('intro', false);

    final tag = pref.getString('lang_tag') ?? 'en';
    final subtag = pref.getString('lang_subtag') ?? 'UK';
    final local = await AppLocalization.load(Locale(tag, subtag));

    runApp(
      ChangeNotifierProvider<ThemeState>(
        create: (context) => ThemeState(),
        child: UserData(
          local: local,
          preferences: pref,
          child: BuildApp(intro),
        ),
      ),
    );
  } catch (error) {
    print(error);
  }
}

class BuildApp extends StatelessWidget {
  final bool intro;

  BuildApp(this.intro);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeState>(context).theme == ThemeType.DARK
          ? ThemeDark().view
          : ThemeLight().view,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [const Locale('en', 'UK'), const Locale('nl', 'NL')],
      onGenerateRoute: (settings) =>
          RouteGenerator.generateRoute(settings, this.intro),
    );
  }
}

class PageArguments {
  final bool init;
  final List<StudyStack> table;

  PageArguments({this.init, this.table});
}

class RouteGenerator {
  static const ROUTE_HOME = "/home";
  static const ROUTE_STUDY = "/study";
  static const ROUTE_EDIT = "/edit";
  static const ROUTE_STATS = "/stats";
  static const ROUTE_CREATE = "/create";
  static const ROUTE_SETTINGS = "/settings";

  static Route<dynamic> generateRoute(settings, intro) {
    switch (settings.name) {
      case ROUTE_HOME:
        final page = HomePage();
        return MaterialPageRoute(builder: (context) => page);

      case ROUTE_STUDY:
        PageArguments args = settings.arguments;
        final page = StudyPage(table: args.table, init: args.init);
        return MaterialPageRoute(builder: (context) => page);

      case ROUTE_SETTINGS:
        final page = SettingsPage();
        return MaterialPageRoute(builder: (context) => page);

      case ROUTE_STATS:
        final page = StatisticsPage();
        return MaterialPageRoute(builder: (context) => page);

      case ROUTE_CREATE:
        final page = CreateStack();
        return MaterialPageRoute(builder: (context) => page);

      case ROUTE_EDIT:
        PageArguments args = settings.arguments;
        final page = EditStack(table: args.table.first);
        return MaterialPageRoute(builder: (context) => page);

      default:
        final page = intro ? IntroductionPage() : HomePage();
        return MaterialPageRoute(builder: (context) => page);
    }
  }
}
