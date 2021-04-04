import 'package:flutter/material.dart';

import 'shadow.dart';

class RoundShadow extends CustomShadow {
  final bool focus;

  final Brightness brightness;

  final Color color;

  RoundShadow({
    this.color,
    this.focus = false,
    this.brightness = Brightness.light,
  }) : assert(color != null || brightness != null);

  BoxDecoration get shadow {
    return this.brightness == Brightness.light ? light : dark;
  }

  @override
  BoxDecoration get dark => BoxDecoration(
        color: this.color ?? Colors.grey[850],
        shape: BoxShape.circle,
        boxShadow: super.neumorphic(Colors.grey[800], Colors.grey[900], focus),
      );

  @override
  BoxDecoration get light => BoxDecoration(
        color: this.color ?? Colors.grey[200],
        shape: BoxShape.circle,
        boxShadow: super.neumorphic(Colors.grey[50], Colors.grey[500], focus),
      );
}
