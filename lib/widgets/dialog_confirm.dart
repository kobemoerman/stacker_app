import 'package:flutter/material.dart';
import 'package:stackr/constants.dart';

import '../model/user_inherited.dart';

class ConfirmDialog extends StatelessWidget {
  final Color color;
  final String title;
  final String message;
  final String confirm;
  final String dismiss;
  final double radius;

  final Function onConfirmPress;
  final Function onDismissPress;

  ConfirmDialog({
    this.title,
    this.message,
    this.radius = 15.0,
    this.color = Colors.white,
    this.confirm,
    this.dismiss,
    this.onConfirmPress,
    this.onDismissPress,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0.0,
      title: title != null ? Text(title) : null,
      content: message != null ? Text(message) : null,
      backgroundColor: color,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      actions: <Widget>[
        if (confirm != null)
          FlatButton(
            child: Text(confirm),
            textColor: confirmColor(context),
            onPressed: () {
              Navigator.of(context).pop();
              if (onConfirmPress != null) {
                onConfirmPress();
              }
            },
          ),
        if (dismiss != null)
          FlatButton(
            child: Text(dismiss),
            textColor: UserData.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pop();
              if (onDismissPress != null) {
                onDismissPress();
              }
            },
          ),
      ],
    );
  }

  confirmColor(BuildContext context) {
    final _local = UserData.of(context).local;

    return confirm.contains(_local.delete)
        ? cRed
        : Theme.of(context).accentColor;
  }
}
