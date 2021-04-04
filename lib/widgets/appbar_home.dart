import 'package:flutter/material.dart';
import 'package:stackr/decoration/round_shadow.dart';

import '../constants.dart';
import '../locale/localization.dart';
import '../model/user_inherited.dart';

class HomeAppBar extends StatefulWidget {
  final Color color;

  HomeAppBar({this.color});

  @override
  State<StatefulWidget> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  static const double EXPAND = 100.0;
  static const double OFFSET = 20.0;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      brightness: Theme.of(context).brightness,
      elevation: 5.0,
      snap: true,
      pinned: true,
      primary: true,
      floating: true,
      expandedHeight: EXPAND,
      collapsedHeight: EXPAND - OFFSET,
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
            child: Align(alignment: Alignment.bottomLeft, child: userInfo()),
          ),
        )
      ],
    );
  }

  Row userInfo() {
    TextTheme theme = Theme.of(context).textTheme;
    final user = UserData.of(context);
    AppLocalization local = AppLocalization.of(context);

    Text _greet = Text('${getGreeting()},',
        style: theme.subtitle1.copyWith(fontSize: 10.0));

    Text _name = Text('${user.user.name}!',
        style: theme.bodyText1.copyWith(fontSize: 16.0));

    return Row(
      children: [
        Container(
          decoration: RoundShadow(
            focus: true,
            brightness: Theme.of(context).brightness,
          ).shadow,
          child: CircleAvatar(
            radius: EXPAND / 6,
            backgroundImage: user.profile,
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

    // CHRISTMAS
    if (now.difference(DateTime(now.year, 12, 25)).inDays == 0)
      return 'Merry Christmas';

    // THANKSGIVING
    if (now.month == DateTime.november &&
        now.day >= 22 &&
        now.day <= 28 &&
        now.weekday == DateTime.thursday) {
      return 'Happy Thanksgiving';
    }

    // MOTHER'S DAY
    if (now.month == DateTime.may &&
        now.day >= 8 &&
        now.day <= 14 &&
        now.weekday == DateTime.sunday) {
      return "Happy Mother's Day";
    }

    // EASTER
    if ((now.month == DateTime.april || now.month == DateTime.march) &&
        now.day >= 22 &&
        now.day <= 28 &&
        now.weekday == DateTime.sunday) {
      return 'Happy Easter';
    }

    // FATHER'S DAY
    if (now.month == DateTime.june &&
        now.day >= 15 &&
        now.day <= 21 &&
        now.weekday == DateTime.sunday) {
      return "Happy Father's Day";
    }

    // HALLOWEEN
    if (now.difference(DateTime(now.year, 10, 31)).inDays == 0)
      return 'Happy Halloween';

    // VALENTINE'S
    if (now.difference(DateTime(now.year, 2, 14)).inDays == 0)
      return "Happy Valentine's Day";

    // SAINT PATRICKS
    if (now.difference(DateTime(now.year, 3, 17)).inDays == 0)
      return "Happy Saint Patrick's Day";

    // NEW YEARS
    if (now.difference(DateTime(now.year, 12, 31)).inDays == 0)
      return "Happy New Years Eve";

    // NEW YEARS
    if (now.difference(DateTime(now.year, 1, 1)).inDays == 0)
      return "Happy New Years Day";

    var hour = now.hour;

    if (hour < 4 || hour > 21) return 'Good Night';
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';

    return 'Good Evening';
  }
}
