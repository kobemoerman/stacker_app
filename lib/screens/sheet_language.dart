import 'package:flutter/material.dart';

import '../constants.dart';
import '../model/user_inherited.dart';

class LanguageSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  _updateLanguage(UserDataState data, tag, subtag) {
    var currentTag = data.getFromDisk('lang_tag');

    if (currentTag != tag) data.updateLanguage(tag, subtag);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final data = UserData.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text("English"),
          trailing: arrowRight,
          onTap: () => _updateLanguage(data, 'en', 'UK'),
        ),
        ListTile(
          title: Text("Nederlands"),
          trailing: arrowRight,
          onTap: () => _updateLanguage(data, 'nl', 'NL'),
        )
      ],
    );
  }
}
