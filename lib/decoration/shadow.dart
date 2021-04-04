import 'package:flutter/material.dart';

abstract class CustomShadow {
  static const double _blur = 5.0;
  static const double _spread = 0.5;

  BoxDecoration get light;
  BoxDecoration get dark;

  List<BoxShadow> neumorphic(Color top, Color bottom, bool focus) {
    double t = focus ? -1.0 : -2.0;
    double b = focus ? 1.0 : 4.0;
    return [dropShadow(bottom, b), dropShadow(top, t)];
  }

  BoxShadow dropShadow(Color color, double d) {
    var blur = d.toInt().isEven ? _blur : 1.0;
    return BoxShadow(
      color: color,
      offset: Offset(d, d),
      blurRadius: blur,
      spreadRadius: _spread,
    );
  }
}
