import 'package:flutter/material.dart';

import '../decoration/card_shadow.dart';
import 'graph_stats.dart';

class StatisticsCard extends StatelessWidget {
  final double radius;

  const StatisticsCard({Key key, this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Hero(
      tag: 'stats_launch',
      child: Container(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(this.radius),
            onTap: () => Navigator.pushNamed(context, '/stats'),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              child: InfoGraphic(detailed: false),
            ),
          ),
        ),
        decoration: CardDecoration(
          radius: this.radius,
          color: _theme.cardColor,
          brightness: _theme.brightness,
        ).shadow,
      ),
    );
  }
}
