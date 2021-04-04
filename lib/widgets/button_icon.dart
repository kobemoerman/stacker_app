import 'package:flutter/material.dart';
import 'package:stackr/decoration/round_shadow.dart';
import 'package:stackr/model/user_inherited.dart';

class ButtonIcon extends StatelessWidget {
  final double size;
  final IconData icon;
  final Function onTap;
  final EdgeInsets margin;

  const ButtonIcon({
    Key key,
    this.size,
    this.icon,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 30.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: this.margin,
      child: ClipOval(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: this.onTap,
            child: FittedBox(
              child: Container(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  this.icon,
                  size: this.size,
                  color: UserData.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
      decoration: RoundShadow(
        focus: true,
        brightness: Theme.of(context).brightness,
      ).shadow,
    );
  }
}
