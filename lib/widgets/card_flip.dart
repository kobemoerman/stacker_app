import 'dart:math';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FlipCard extends StatefulWidget {
  bool showFront;
  final Widget child;

  FlipCard({Key key, @required this.child, @required this.showFront})
      : super(key: key);

  @override
  _FlipCardState createState() => _FlipCardState(showFront);
}

class _FlipCardState extends State<FlipCard> {
  bool showFront;

  _FlipCardState(this.showFront);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      transitionBuilder: this.transitionBuilder,
      layoutBuilder: (widget, list) => Stack(children: [widget, ...list]),
      child: widget.child,
      switchInCurve: Curves.easeInBack,
      switchOutCurve: Curves.easeInBack.flipped,
    );
  }

  Widget transitionBuilder(Widget widget, Animation<double> animation) {
    final rotate = Tween(begin: pi, end: 0.0).animate(animation);

    return AnimatedBuilder(
      animation: rotate,
      child: widget,
      builder: (context, widget) {
        final isUnder = ValueKey(showFront) != widget.key;
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }
}
