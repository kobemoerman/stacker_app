import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/model/user_inherited.dart';
import 'package:stackr/widgets/appbar_page.dart';
import 'package:stackr/widgets/graph_stats.dart';

import '../constants.dart';
import '../utils/date_operation.dart';
import '../utils/string_operation.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  _cardDecoration(focus) => CardDecoration(
        focus: focus,
        radius: 20.0,
        color: Theme.of(context).cardColor,
        brightness: Theme.of(context).brightness,
      ).shadow;

  @override
  Widget build(BuildContext context) {
    final _local = UserData.of(context).local;

    return Scaffold(
      appBar: PageAppBar(
        color: Theme.of(context).cardColor,
        height: 72.0,
        elevation: 7.5,
        title: _local.statsHeader,
        textColor: UserData.of(context).primaryColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Hero(
              tag: 'stats_launch',
              child: weekReview(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                statCards(bestStack(), dayStreak()),
                statCards(correctCards(), hourStudied()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget weekReview() {
    final theme = Theme.of(context).textTheme;
    final local = UserData.of(context).local;

    var header = Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 15.0),
      child: Text('7 ${local.statsWeekReview}:', style: theme.bodyText1),
    );

    return Container(
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(20.0),
      height: 200.0,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [header, Expanded(child: InfoGraphic(detailed: true))],
      ),
      decoration: _cardDecoration(false),
    );
  }

  Widget statCards(Widget child1, Widget child2) {
    return Expanded(
      child: Column(children: [child1, child2]),
    );
  }

  Widget bestStack() {
    final theme = Theme.of(context).textTheme;
    final data = UserData.of(context);

    String study = data.getFromDisk('stats_best_stack').split('-').first;

    var header = Text(data.local.statsBestStack, style: theme.bodyText1);
    var content = Text(study.formatTable().last, style: theme.subtitle1);

    return Container(
      margin: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
      height: 80.0,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [header, content],
      ),
      decoration: _cardDecoration(true),
    );
  }

  Widget dayStreak() {
    final theme = Theme.of(context).textTheme;
    final data = UserData.of(context);
    final day = DateTime.now();

    var count;
    var streak = data.getFromDisk('stats_day_streak');
    var streakDay = convertToDate(string: streak);

    if (day.compareDays(days: 1, date: streakDay)) {
      count = streak.split('-').last;
    } else {
      count = '0';
    }

    var header = Text(data.local.statsStreak, style: theme.bodyText1);
    var content = Text(count,
        style: theme.bodyText1
            .copyWith(fontSize: 80, height: 0.75, color: data.primaryColor));
    var subtitle = Text(data.local.days.toLowerCase(),
        style: theme.bodyText1.copyWith(fontSize: 20));

    return Container(
      margin: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
      height: 150.0,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [content, subtitle],
          ),
        ],
      ),
      decoration: _cardDecoration(true),
    );
  }

  Widget correctCards() {
    final theme = Theme.of(context).textTheme;
    final data = UserData.of(context);
    final day = DateTime.now();

    var ratio;
    var cards = data.getFromDisk('stats_correct_ratio');
    var ratioDay = convertToDate(string: cards);

    if (day.compareDays(days: 0, date: ratioDay, equals: true)) {
      List<String> list = cards.split('-');
      ratio = double.parse(list[3]) / double.parse(list[4]);
    } else {
      ratio = 0.0;
    }

    var header = Text(data.local.statsCorrectCards, style: theme.bodyText1);
    var content = CircularPercentIndicator(
      radius: 80.0,
      lineWidth: 5.0,
      animation: true,
      percent: ratio,
      center: Text(
        '${(ratio * 100).toStringAsFixed(0)}%',
        style: theme.headline2,
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: cRed,
      progressColor: cGreen,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
      height: 130.0,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [header, const SizedBox(height: 5.0), content],
      ),
      decoration: _cardDecoration(true),
    );
  }

  Widget hourStudied() {
    final theme = Theme.of(context).textTheme;
    final data = UserData.of(context);

    List<String> week = data.getFromDisk('stats_week_review');

    var sum = 0.0;
    week.forEach((e) {
      var value = e.split('-').last;
      sum += double.parse(value);
    });
    sum /= 60;

    var header = Text(data.local.statsHoursStudied, style: theme.bodyText1);
    var content = Text(sum.round().toString(),
        style: theme.headline1
            .copyWith(fontSize: 45, height: 0.8, color: data.primaryColor));

    return Container(
      margin: const EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
      height: 100.0,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [header, content],
      ),
      decoration: _cardDecoration(true),
    );
  }
}
