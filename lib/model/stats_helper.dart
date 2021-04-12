import 'package:flutter/material.dart';
import 'package:stackr/model/studystack.dart';
import 'package:stackr/model/user_inherited.dart';

import '../utils/date_operation.dart';

class StatsHelper {
  final BuildContext context;

  const StatsHelper(this.context);

  static StatsHelper of(BuildContext context) => StatsHelper(context);

  /// HOURS STUDIED
  double getWeeklyHours() {
    final data = UserData.of(context);

    List<String> week = data.getFromDisk('stats_week_review');

    var sum = 0.0;
    week.forEach((e) {
      var value = e.split('-').last;
      sum += double.parse(value);
    });

    return sum / 60;
  }

  /// DAILY RATIO
  double getDailyRatio() {
    final data = UserData.of(context);
    final now = DateTime.now();

    var ratio;
    var cards = data.getFromDisk('stats_correct_ratio');
    var ratioDay = convertToDate(string: cards);

    if (now.compareDays(days: 0, date: ratioDay, equals: true)) {
      List<String> list = cards.split('-');
      ratio = double.parse(list[3]) / double.parse(list[4]);
    } else {
      ratio = 0.0;
    }

    return ratio;
  }

  updateDailyRatio(int correct, int total) {
    final data = UserData.of(context);
    final now = DateTime.now();

    var res;
    var ratio = data.getFromDisk('stats_correct_ratio');
    var date = convertToDate(string: ratio);
    if (now.compareDays(days: 0, date: date, equals: true)) {
      var value = ratio.split('-');
      var c = int.parse(value[3]) + correct;
      var t = int.parse(value[4]) + total;
      res = now.convertToString() + '-$c' + '-$t';
    } else {
      res = now.convertToString() + '-$correct' + '-$total';
    }
    data.saveToDisk('stats_correct_ratio', res);
  }

  /// BEST STACK
  String getBestStack() {
    final data = UserData.of(context);

    return data.getFromDisk('stats_best_stack').split('-').first;
  }

  updateBestStack(List<StudyStack> tables) async {
    final data = UserData.of(context);

    var table;
    var res = 0.0;
    var best = data.getFromDisk('stats_best_stack').split('-');

    for (var i = 0; i < tables.length; i++) {
      var ratio = await data.dbClient.tableRatio(name: tables[i].table);
      if (ratio >= res) {
        table = tables[i].table;
        res = ratio;
      }
    }

    if (res >= double.parse(best.last)) {
      data.saveToDisk('stats_best_stack', table + '-$res');
    }
  }

  /// WEEK OVERVIEW
  List<double> getOverview() {
    final _pref = UserData.of(context).preferences;

    List<double> values = List.filled(7, 0.0, growable: false);
    List<String> list = _pref.getStringList('stats_week_review');

    var idx = 0;
    for (var i = 0; i < list.length; i++) {
      var val = list[idx].split('-').map(int.parse).toList();

      if (differenceOfDays(i, val)) {
        idx = idx + 1;
        values[i] = val[3].toDouble();
      }
    }

    return values.reversed.toList();
  }

  updateOverview() {
    final data = UserData.of(context);
    final day = DateTime.now();

    List<String> list = data.preferences.getStringList('stats_week_review');

    var time = 1;
    var val = list[0].split('-').map(int.parse).toList();
    if (day.difference(DateTime(val[0], val[1], val[2])).inDays == 0) {
      time = val[3] + 1;
      list[0] = day.convertToString() + '-$time';
    } else {
      list.removeLast();
      list.insert(0, day.convertToString() + '-$time');
    }

    data.saveToDisk('stats_week_review', list);
  }

  /// STREAK
  String getStreak() {
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

    return count;
  }

  updateStreak() {
    final data = UserData.of(context);

    var now = DateTime.now();
    var streak = data.getFromDisk('stats_day_streak');
    var date = convertToDate(string: streak);
    if (now.compareDays(days: 1, date: date, equals: true)) {
      var value = int.parse(streak.split('-').last) + 1;
      var updated = now.convertToString() + '-$value';
      data.saveToDisk('stats_day_streak', updated);
    }
    if (!now.compareDays(days: 1, date: date)) {
      var value = now.convertToString() + '-0';
      data.saveToDisk('stats_day_streak', value);
    }
  }

  /// HELPER
  bool differenceOfDays(int dx, List<int> arr) {
    var n = DateTime.now();
    var d = DateTime(arr[0], arr[1], arr[2]);

    return n.subtract(Duration(days: dx)).difference(d).inDays == 0;
  }
}
