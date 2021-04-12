import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'button_icon.dart';

class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool blur;
  final Color color;
  final Color textColor;
  final String title;
  final String subtitle;
  final double height;
  final double elevation;

  final Widget action;

  final Function onPress;

  const PageAppBar(
      {Key key,
      this.elevation = 0.0,
      this.blur = false,
      this.height = 56.0,
      this.title,
      this.color,
      this.action,
      this.onPress,
      @required this.textColor,
      this.subtitle})
      : assert(color != null || blur != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      brightness: Theme.of(context).brightness,
      shape: bottomShape,
      elevation: this.elevation,
      automaticallyImplyLeading: false,
      backgroundColor: this.blur ? Colors.transparent : this.color,
      title: Padding(
        padding: EdgeInsets.only(top: pow(2, this.height / 22), right: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            leadingAction(context),
            Expanded(child: textHeader(context)),
          ],
        ),
      ),
      titleSpacing: -10.0,
      flexibleSpace: this.blur ? ClipRect(child: backgroundBlur) : null,
      actions: [
        Padding(
          padding: EdgeInsets.only(top: pow(2, this.height / 22), right: 5.0),
          child: this.action,
        )
      ].where((e) => e != null).toList(),
    );
  }

  Widget textHeader(context) {
    var sub;
    if (this.subtitle != null) sub = this.subtitle.split(' | ');

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            this.title,
            style: TextStyle(fontSize: height / 3, color: this.textColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (this.subtitle != null)
            Row(
              children: [
                Text(
                  '${sub[1]} | ',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                Expanded(
                  child: Text(
                    sub[0],
                    style: Theme.of(context).textTheme.subtitle2,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget leadingAction(context) => ButtonIcon(
        icon: Icons.arrow_back_ios_sharp,
        size: 24,
        onTap: () => onPress == null ? Navigator.pop(context) : onPress(),
      );

  Widget get backgroundBlur => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 5.0),
        child: Container(color: Colors.transparent),
      );

  ShapeBorder get bottomShape => this.blur
      ? null
      : ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0)),
        );

  @override
  Size get preferredSize => Size.fromHeight(this.height);
}
