import 'package:flutter/material.dart';

import '../model/user_inherited.dart';

class InfoDialog {
  final GlobalKey<ScaffoldState> key;
  final BuildContext context;

  const InfoDialog(this.key, this.context)
      : assert(key is GlobalKey<ScaffoldState>);

  static InfoDialog of(BuildContext context, GlobalKey key) =>
      InfoDialog(key, context);

  undoSnackBar({@required void Function() onPressed, @required String text}) {
    final _data = UserData.of(context);
    final _theme = Theme.of(context).brightness == Brightness.light
        ? ThemeData.dark()
        : ThemeData.light();

    var _snackbar = SnackBar(
      backgroundColor: _theme.cardColor,
      content: Text(text, style: _theme.textTheme.bodyText2),
      action: SnackBarAction(
        label: _data.local.undo,
        onPressed: onPressed,
        textColor: _data.primaryColor,
      ),
    );

    _buildSnackBar(_snackbar);
  }

  displaySnackBar({@required String text}) {
    final _theme = Theme.of(context).brightness == Brightness.light
        ? ThemeData.dark()
        : ThemeData.light();

    var _snackbar = SnackBar(
      backgroundColor: _theme.cardColor,
      content: Text(text, style: _theme.textTheme.bodyText2),
    );

    _buildSnackBar(_snackbar);
  }

  _buildSnackBar(snackbar) {
    this.key.currentState
      ..removeCurrentSnackBar()
      ..showSnackBar(snackbar);
  }
}
