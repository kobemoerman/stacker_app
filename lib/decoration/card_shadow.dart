import 'package:flutter/material.dart';

import 'shadow.dart';

class CardDecoration extends CustomShadow {
  bool focus;

  final double radius;
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  final Color color;

  final Brightness brightness;

  CardDecoration({
    this.bottomLeft = 0.0,
    this.bottomRight = 0.0,
    this.topLeft = 0.0,
    this.topRight = 0.0,
    this.radius,
    this.focus = false,
    this.color,
    this.brightness = Brightness.light,
  }) : assert(brightness != null);

  BoxDecoration get shadow {
    return this.brightness == Brightness.light ? light : dark;
  }

  @override
  BoxDecoration get dark => BoxDecoration(
        color: this.color ?? Colors.grey[850],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(this.radius ?? this.bottomLeft),
          bottomRight: Radius.circular(this.radius ?? this.bottomRight),
          topLeft: Radius.circular(this.radius ?? this.topLeft),
          topRight: Radius.circular(this.radius ?? this.topRight),
        ),
        boxShadow: super.neumorphic(Colors.grey[800], Colors.grey[900], focus),
      );

  @override
  BoxDecoration get light => BoxDecoration(
        color: this.color ?? Colors.grey[200],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(this.radius ?? this.bottomLeft),
          bottomRight: Radius.circular(this.radius ?? this.bottomRight),
          topLeft: Radius.circular(this.radius ?? this.topLeft),
          topRight: Radius.circular(this.radius ?? this.topRight),
        ),
        boxShadow: super.neumorphic(Colors.grey[50], Colors.grey[500], focus),
      );
}
