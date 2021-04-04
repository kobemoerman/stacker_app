import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:stackr/screens/page_stats.dart';

import 'graph_stats.dart';

class StatisticsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: Duration(milliseconds: 600),
      closedColor: Theme.of(context).cardColor,
      openColor: Theme.of(context).cardColor,
      transitionType: ContainerTransitionType.fade,
      closedElevation: 0.0,
      closedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      openBuilder: (context, closeContainer) => StatisticsPage(),
      closedBuilder: (context, openContainer) {
        return Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: openContainer,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 30.0),
              child: InfoGraphic(detailed: false),
            ),
          ),
        );
      },
    );
  }
}
