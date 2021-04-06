import 'package:flutter/material.dart';

import '../decoration/card_shadow.dart';
import 'graph_stats.dart';

class StatisticsCard extends StatelessWidget {
  final double radius;

  const StatisticsCard({Key key, this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(this.radius),
          onTap: () => Navigator.pushNamed(context, '/stats'),
          child: Hero(
            tag: 'stats_launch',
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 30.0),
              child: InfoGraphic(detailed: false),
            ),
          ),
        ),
      ),
      decoration: CardDecoration(
        radius: this.radius,
        color: Theme.of(context).cardColor,
        brightness: Theme.of(context).brightness,
      ).shadow,
    );
  }
}
