import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:stackr/decoration/round_shadow.dart';
import 'package:stackr/model/user_inherited.dart';

import '../constants.dart';
import '../locale/localization.dart';
import 'button_icon.dart';

class CircularProgress extends StatefulWidget {
  final Function callback;
  final double percentage;

  const CircularProgress({Key key, this.percentage, this.callback})
      : assert(percentage <= 1.0 && percentage >= 0.0),
        super(key: key);

  @override
  _CircularProgressState createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress> {
  @override
  Widget build(BuildContext context) {
    final _local = UserData.of(context).local;
    return Stack(
      children: [
        Align(
          alignment: Alignment(0.9, 0.9),
          child: ButtonIcon(
            margin: const EdgeInsets.all(2.5),
            icon: Icons.info_outline_rounded,
            size: 24,
            onTap: () => widget.callback(),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: CircularPercentIndicator(
            radius: 120.0,
            lineWidth: 13.0,
            animation: true,
            percent: widget.percentage,
            center: Text(
              '${(widget.percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            header: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                _local.studyCompleteHeader,
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            footer: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                _local.studyCompleteSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: cRed,
            progressColor: cGreen,
          ),
        ),
      ],
    );
  }
}
