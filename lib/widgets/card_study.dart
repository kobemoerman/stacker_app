import 'package:flutter/material.dart';
import 'package:stackr/widgets/button_icon.dart';
import '../model/user_inherited.dart';
import '../utils/string_operation.dart';

class StudyCard extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;
  final Function callback;

  const StudyCard({
    Key key,
    @required this.title,
    @required this.content,
    this.icon,
    this.callback,
  }) : super(key: key);

  @override
  _StudyCardState createState() => _StudyCardState();
}

class _StudyCardState extends State<StudyCard> {
  @override
  Widget build(BuildContext context) {
    final _local = UserData.of(context).local;

    String body = widget.content;
    if (body.isEmpty) body = _local.infoCardInit;

    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: _title(),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.fromLTRB(20.0, 50.0, 10.0, 20.0),
            child: _content(body),
          ),
        ),
        if (widget.icon != null)
          Align(
            alignment: Alignment.bottomRight,
            child: _icon(),
          ),
      ].where((e) => e != null).toList(),
    );
  }

  Widget _title() {
    final _text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0),
      child: Text(widget.title, style: _text.headline2),
    );
  }

  Widget _content(String body) {
    final _text = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Text(body.formatCard(), style: _text.subtitle1),
    );
  }

  Widget _icon() {
    return ButtonIcon(
      size: 18.0,
      icon: widget.icon,
      margin: const EdgeInsets.all(10.0),
      onTap: () => widget.callback(),
    );
  }
}
