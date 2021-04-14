import 'package:flutter/material.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/model/user_inherited.dart';

import '../constants.dart';

enum Side { L, R }

const double _kHeight = 64.0;
const Duration _dStudy = Duration(milliseconds: 250);
const Duration _dComplete = Duration(milliseconds: 750);

// ignore: must_be_immutable
class StudyButton extends StatefulWidget {
  final bool isComplete;
  int value;
  final Side side;
  final Function callback;

  StudyButton({Key key, this.value, this.side, this.isComplete, this.callback})
      : super(key: key);

  @override
  _StudyButtonState createState() => _StudyButtonState();
}

class _StudyButtonState extends State<StudyButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _dComplete,
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.ease,
      layoutBuilder: transitionLayout,
      transitionBuilder: transitionAnimation,
      child: Container(
        key: ValueKey<bool>(widget.isComplete),
        margin: EdgeInsets.fromLTRB(widget.isComplete ? 25.0 : 0.0, 20.0,
            widget.isComplete ? 25.0 : 0.0, 20.0),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => widget.isComplete
                ? widget.callback()
                : widget.callback(widget.side.index),
            child: widget.isComplete ? _completeState() : _studyState(),
            borderRadius: widget.isComplete ? completeInk() : studyInk(),
          ),
        ),
        decoration:
            widget.isComplete ? completeDecoration() : studyDecoration(),
      ),
    );
  }

  Widget transitionLayout(Widget currentChild, List<Widget> previousChildren) {
    List<Widget> children = previousChildren;
    AlignmentGeometry align = this.widget.side == Side.L
        ? Alignment.centerLeft
        : Alignment.centerRight;

    if (currentChild != null) children = children.toList()..add(currentChild);
    return Stack(children: children, alignment: align);
  }

  Widget transitionAnimation(Widget child, Animation<double> animation) {
    Offset end = Offset(0.0, 0.0);
    Offset begin = Offset(0.0, 1.5);

    final steps = Tween<Offset>(begin: begin, end: end).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: steps, child: child),
    );
  }

  Container _completeState() {
    final _local = UserData.of(context).local;
    final _color = UserData.of(context).primaryColor;
    final _text = Theme.of(context).textTheme.bodyText1;

    String text = widget.side == Side.R
        ? _local.studyCompleteRepeat
        : _local.studyCompleteReview;

    return Container(
      height: _kHeight,
      width: 125.0,
      alignment: Alignment.center,
      child: Text(text, style: _text.copyWith(color: _color)),
    );
  }

  Container _studyState() {
    final _text = Theme.of(context).textTheme.bodyText1;

    return Container(
      height: _kHeight,
      width: 54.0,
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: _dStudy,
        transitionBuilder: (child, animation) {
          return ScaleTransition(child: child, scale: animation);
        },
        child: Text(
          widget.value.toString(),
          key: ValueKey<int>(widget.value),
          style: _text.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  BorderRadius completeInk() => BorderRadius.circular(10.0);

  BorderRadius studyInk() => BorderRadius.horizontal(
        right: Radius.circular(widget.side == Side.R ? 0.0 : 10.0),
        left: Radius.circular(widget.side == Side.L ? 0.0 : 10.0),
      );

  Decoration completeDecoration() => CardDecoration(
        radius: 10.0,
        brightness: Theme.of(context).brightness,
      ).shadow;

  Decoration studyDecoration() => CardDecoration(
        bottomLeft: widget.side == Side.R ? 10.0 : 0.0,
        bottomRight: widget.side == Side.L ? 10.0 : 0.0,
        topLeft: widget.side == Side.R ? 10.0 : 0.0,
        topRight: widget.side == Side.L ? 10.0 : 0.0,
        brightness: Theme.of(context).brightness,
        color: widget.side == Side.L ? cRed : cGreen,
      ).shadow;
}
