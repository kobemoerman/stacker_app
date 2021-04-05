import 'package:flutter/material.dart';
import 'package:stackr/widgets/button_icon.dart';
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
    String body = widget.content;

    if (body.isEmpty) {
      body = 'Tap card for more information.\nTap edit to set content.';
    }

    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.fromLTRB(20.0, 50.0, 10.0, 20.0),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Text(
                body.formatCard(),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ),
        ),
        if (widget.icon != null)
          Align(
            alignment: Alignment.bottomRight,
            child: ButtonIcon(
              size: 18.0,
              icon: widget.icon,
              margin: const EdgeInsets.all(10.0),
              onTap: () => widget.callback(),
            ),
          ),
      ],
    );
  }
}
