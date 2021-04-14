import 'package:flutter/material.dart';
import 'package:stackr/decoration/round_shadow.dart';

import '../constants.dart';
import '../model/user_inherited.dart';

const double _kExpand = 100.0;
const double _kOffset = 20.0;

class HomeAppBar extends StatefulWidget {
  final Color color;

  HomeAppBar({this.color});

  @override
  State<StatefulWidget> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      brightness: Theme.of(context).brightness,
      elevation: 5.0,
      snap: true,
      pinned: true,
      primary: true,
      floating: true,
      expandedHeight: _kExpand,
      collapsedHeight: _kExpand - _kOffset,
      backgroundColor: widget.color,
      actions: [actionSettings],
      flexibleSpace: userStack,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0)),
      ),
    );
  }

  IconButton get actionSettings {
    return IconButton(
      icon: settings,
      color: Theme.of(context).unselectedWidgetColor,
      onPressed: () => Navigator.pushNamed(context, '/settings'),
    );
  }

  Stack get userStack {
    return Stack(
      children: [
        FlexibleSpaceBar(
          centerTitle: true,
          collapseMode: CollapseMode.parallax,
          title: Container(
            margin: const EdgeInsets.only(left: 10.0),
            height: double.infinity,
            width: double.infinity,
            child: Align(alignment: Alignment.bottomLeft, child: _userInfo()),
          ),
        )
      ],
    );
  }

  Row _userInfo() {
    final _theme = Theme.of(context);
    final _client = UserData.of(context);

    Text _greet = Text('${getGreeting()},',
        style: _theme.textTheme.subtitle2.copyWith(fontSize: 11.0));

    Text _name =
        Text('${_client.user.name}!', style: _theme.textTheme.bodyText2);

    return Row(
      children: [
        Container(
          decoration:
              RoundShadow(focus: true, brightness: _theme.brightness).shadow,
          child: CircleAvatar(
            radius: _kExpand / 6,
            backgroundImage: _client.image,
          ),
        ),
        SizedBox(width: 10.0),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_greet, SizedBox(height: 2.0), _name],
        ),
      ],
    );
  }

  String getGreeting() {
    var now = DateTime.now();
    final _local = UserData.of(context).local;

    // CHRISTMAS
    if (now.difference(DateTime(now.year, 12, 25)).inDays == 0)
      return _local.merryChristmas;

    // THANKSGIVING
    if (now.month == DateTime.november &&
        now.day >= 22 &&
        now.day <= 28 &&
        now.weekday == DateTime.thursday) {
      return _local.happyThanksgiving;
    }

    // MOTHER'S DAY
    if (now.month == DateTime.may &&
        now.day >= 8 &&
        now.day <= 14 &&
        now.weekday == DateTime.sunday) {
      return _local.mothersDay;
    }

    // EASTER
    if ((now.month == DateTime.april || now.month == DateTime.march) &&
        now.day >= 22 &&
        now.day <= 28 &&
        now.weekday == DateTime.sunday) {
      return _local.happyEaster;
    }

    // FATHER'S DAY
    if (now.month == DateTime.june &&
        now.day >= 15 &&
        now.day <= 21 &&
        now.weekday == DateTime.sunday) {
      return _local.fathersDay;
    }

    // HALLOWEEN
    if (now.difference(DateTime(now.year, 10, 31)).inDays == 0)
      return _local.happyHalloween;

    // VALENTINE'S
    if (now.difference(DateTime(now.year, 2, 14)).inDays == 0)
      return _local.happyValentines;

    // SAINT PATRICKS
    if (now.difference(DateTime(now.year, 3, 17)).inDays == 0)
      return _local.happyPatricks;

    // NEW YEARS
    if (now.difference(DateTime(now.year, 12, 31)).inDays == 0)
      return _local.happyNYE;

    // NEW YEARS
    if (now.difference(DateTime(now.year, 1, 1)).inDays == 0)
      return _local.happyNYD;

    var hour = now.hour;

    if (hour < 4 || hour > 21) return _local.goodNight;
    if (hour < 12) return _local.goodMorning;
    if (hour < 18) return _local.goodAfternoon;

    return _local.goodEvening;
  }
}
