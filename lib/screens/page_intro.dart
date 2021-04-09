import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/model/user_inherited.dart';

class IntroductionPage extends StatefulWidget {
  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  static const _color = Color(0xFF7986CB);

  final introKey = GlobalKey<IntroductionScreenState>();

  Widget _buildImage(String assetName) {
    return Center(
      child: Container(
        decoration: CardDecoration(
          focus: true,
          radius: 15.0,
        ).shadow,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Image.asset('assets/$assetName', fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initPreferences(context);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(fontSize: 16.0),
      imageFlex: 2,
      imagePadding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 25.0),
      contentPadding: const EdgeInsets.all(10.0),
      titlePadding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Welcome to Stackr",
          body: "",
          image: _buildImage('profile.jpeg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Create a new stack",
          body: "Make your own flashcards to be ready for your next big exam!",
          image: _buildImage('create.gif'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Download available stacks",
          body: "Download pre-made stacks to study offline.",
          image: _buildImage('download.gif'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Select the stacks you want to study",
          body:
              "Start studying by selecting all the stacks of interest. You can resume this selection at any time.",
          image: _buildImage('study.gif'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Study your flashcards",
          body:
              "Flashcards have never been easier to use.\n\nRead the question, tap to see the answer, swipe to the matching side.",
          image: _buildImage('swipe.gif'),
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
      done: const Text('Done',
          style: TextStyle(
              fontSize: 18.0, fontWeight: FontWeight.w600, color: _color)),
      dotsDecorator: const DotsDecorator(
        activeColor: _color,
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
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
}
