import 'package:animations/animations.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:stackr/model/studystack.dart';
import 'package:stackr/model/user_inherited.dart';
import 'package:stackr/screens/page_study.dart';

import '../utils/string_operation.dart';

class FeaturedCard extends StatelessWidget {
  final double percent;
  final String cards;
  final String study;
  final List<StudyStack> tables;

  const FeaturedCard(
      {Key key, this.percent, this.cards, this.study, this.tables})
      : super(key: key);

  void _showInformationBar(message, context) {
    Flushbar(
      message: message,
      isDismissible: true,
      duration: Duration(seconds: 3),
      flushbarStyle: FlushbarStyle.GROUNDED,
      icon: Icon(Icons.info_outline, size: 28.0, color: Colors.white),
      leftBarIndicatorColor: UserData.of(context).primaryColor,
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: Duration(milliseconds: 600),
      closedColor: Theme.of(context).cardColor,
      openColor: Theme.of(context).cardColor,
      transitionType: ContainerTransitionType.fade,
      closedElevation: 0.0,
      closedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      openBuilder: (context, closeContainer) =>
          StudyPage(init: false, table: this.tables),
      closedBuilder: (context, openContainer) {
        return Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => tables.isEmpty
                ? _showInformationBar('No study to continue.', context)
                : openContainer(),
            child: Container(
              padding: const EdgeInsets.all(15.0),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          this.study.formatDBToString(),
                          style: Theme.of(context).textTheme.headline2.copyWith(
                              color: UserData.of(context).primaryColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        Text(
                          '$cards questions',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: LinearPercentIndicator(
                      lineHeight: 5.0,
                      animation: true,
                      animateFromLastPercent: true,
                      percent: this.percent,
                      progressColor: UserData.of(context).primaryColor,
                      backgroundColor:
                          UserData.of(context).primaryColor.withAlpha(50),
                      linearStrokeCap: LinearStrokeCap.roundAll,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
