import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:stackr/model/user_inherited.dart';

class IntroductionPage extends StatefulWidget {
  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/$assetName.gif'),
      alignment: Alignment.bottomCenter,
    );
  }

  void initPreferences(context) {
    final data = UserData.of(context);
    final day = DateTime.now();

    /// USER
    data.saveToDisk('profile_name', 'Student');

    /// FEATURED
    data.saveToDisk('featured_stack', []);
    data.saveToDisk('featured_progress', 0.0);
    data.saveToDisk('featured_time', 0);

    /// LANGUAGE
    data.saveToDisk('lang_tag', 'en');
    data.saveToDisk('lang_subtag', 'UK');

    /// THEME
    data.saveToDisk('theme_color', 0);

    /// STATS
    // review
    List<String> list = [];
    for (var i = 0; i < 7; i++) {
      DateTime init = day.subtract(Duration(days: i));
      list.add('${init.year}-${init.month}-${init.day}-0');
    }
    data.saveToDisk('stats_week_review', list);
    // streak
    var streak = '${day.year}-${day.month}-${day.day}-0';
    data.saveToDisk('stats_day_streak', streak);
    // correct cards
    var ratio = '${day.year}-${day.month}-${day.day}-0-1';
    data.saveToDisk('stats_correct_ratio', ratio);
    // best stack
    data.saveToDisk('stats_best_stack', 'Start_studying-0.0');
  }

  @override
  Widget build(BuildContext context) {
    initPreferences(context);

    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Welcome",
          body: "Here we only display the logo with welcome text!",
          //image: _buildImage('img1'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Create a new stack",
          body: "Whatever we want to explain.",
          image: _buildImage('create'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Download available stacks",
          body: "Whatever we want to explain.",
          image: _buildImage('download'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Select stacks you want to study",
          body: "Whatever we want to explain.",
          image: _buildImage('study'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Study your flashcards",
          body: "Whatever we want to explain.",
          image: _buildImage('swipe'),
          decoration: pageDecoration,
        ),
      ],
      showNextButton: false,
      globalBackgroundColor: Theme.of(context).backgroundColor,
      onDone: () => Navigator.pushReplacementNamed(context, '/home'),
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
