import 'package:flutter/material.dart';
import 'package:stackr/constants.dart';
import 'package:stackr/model/flashcard.dart';
import 'package:stackr/widgets/card_flip.dart';

import '../locale/localization.dart';
import '../model/user_inherited.dart';
import 'card_study.dart';
import 'progress_circular.dart';
import '../utils/matrix_operation.dart';
import '../decoration/card_shadow.dart';

enum Direction { NONE, LEFT, RIGHT, UP, DOWN }

// ignore: must_be_immutable
class SwipeCard extends StatefulWidget {
  double progress;

  FlashCard card;
  final Function callback;
  final Function review;

  SwipeCard listener;
  _SwipeCardState state;

  SwipeCard(
      {Key key,
      this.listener,
      this.callback,
      this.card,
      this.progress = 0.0,
      this.review})
      : super(key: key);

  @override
  _SwipeCardState createState() => this.state = _SwipeCardState();

  setRatioX(dx) {
    this.state.setRatioX(dx);
    this.state.refresh();
  }

  setRatioY(dy) {
    this.state.setRatioY(dy);
    this.state.refresh();
  }

  setListener(dir) {
    this.listener = this.callback(dir);
    this.state.refresh();
  }
}

class _SwipeCardState extends State<SwipeCard> {
  static const double BOUNDARY = 0.15;

  double posX, posY;
  double ratioX, ratioY;

  int dir;
  double angle;

  bool isMoving;
  bool showFront;
  bool isFlipped;

  Offset initialPos;
  Offset previousPos;

  Direction dragDir;

  refresh() => setState(() {});

  setRatioX(dx) => this.ratioX = dx;
  setRatioY(dy) => this.ratioY = dy;
  offsetDelta(Offset current) => current - this.initialPos;

  swipeCard(ratio, width) {
    this.ratioX = ratio;
    this.dragDir = ratio.isNegative ? Direction.LEFT : Direction.RIGHT;
    this.angle = ratio.sign * 20.0;
    _onPanEnd(width / 2);
  }

  switchCard() {
    if (isFlipped) return;

    isFlipped = true;
    setState(() => this.showFront = !this.showFront);

    Future.delayed(Duration(milliseconds: 500)).then((_) => isFlipped = false);
  }

  @override
  void initState() {
    super.initState();
    resetValues();

    showFront = true;
    isFlipped = widget.card == null ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    final local = UserData.of(context).local;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height / 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: switchCard,
        onPanCancel: () => _onPanCancel(),
        onPanEnd: (details) => _onPanEnd(width),
        onPanStart: (details) => _onPanStart(details, height),
        onPanUpdate: (details) => _onPanUpdate(details, height, width),
        child: FlipCard(
          showFront: this.showFront,
          child: buildSwipeAnimation(
            key: ValueKey(this.showFront),
            child: widget.card == null
                ? CircularProgress(
                    percentage: widget.progress,
                    callback: widget.review,
                  )
                : StudyCard(
                    title: this.showFront
                        ? '${local.question}:'
                        : '${local.answer}:',
                    content: this.showFront
                        ? widget.card.question
                        : widget.card.answer,
                  ),
            h: height,
            w: width,
          ),
        ),
      ),
    );
  }

  Color computeColor() {
    if (!isMoving || ratioX.abs() < BOUNDARY)
      return Theme.of(context).cardColor;

    return (ratioX > 0 ? cGreen : cRed)
        .withOpacity(ratioX.abs().clamp(0.0, 1.0) - BOUNDARY);
  }

  void computeDirection(DragUpdateDetails details) {
    Offset local = details.localPosition;

    if (local.dy < previousPos.dy) {
      dragDir = Direction.UP;
    } else if (local.dy > previousPos.dy) {
      dragDir = Direction.DOWN;
    }

    if ((local.dx - previousPos.dx).abs() > (local.dy - previousPos.dy).abs()) {
      dragDir = local.dx < previousPos.dx ? Direction.LEFT : Direction.RIGHT;
    }

    previousPos = local;
  }

  Widget buildSwipeAnimation({Key key, Widget child, double h, double w}) {
    var centerOffset = Offset(h / 2, w / 2);

    double scale = widget.listener == null
        ? (90 + 10 * ratioX.abs().clamp(0.0, 1.0)) / 100
        : 1.0;

    return AnimatedContainer(
      key: key,
      curve: Curves.easeOut,
      duration: Duration(milliseconds: isMoving ? 0 : 250),
      transform: Matrix4.identity()
        ..translate(posX, posY, 0)
        ..rotateDegrees(angle, origin: centerOffset)
        ..scaleWithOrigin(scale, origin: centerOffset),
      decoration: CardDecoration(
        radius: 25.0,
        color: computeColor(),
        brightness: Theme.of(context).brightness,
      ).shadow,
      alignment: Alignment.center,
      child: child,
    );
  }

  void _onPanStart(DragStartDetails details, double height) {
    if (widget.card == null || widget.listener == null) return;

    isMoving = true;

    dir = details.localPosition.dy > (height / 2) ? -1 : 1;

    initialPos = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details, double height, double width) {
    if (widget.card == null) return;

    setState(() {
      posX += details.delta.dx;
      posY += details.delta.dy;

      ratioX = offsetDelta(details.localPosition).dx / width;
      ratioY = offsetDelta(details.localPosition).dy / height;

      angle = dir * ratioX * 25;
    });

    widget.listener?.setRatioX(ratioX);
    computeDirection(details);
  }

  void _onPanEnd(double width) {
    var hasSwiped = false;

    if (ratioX > BOUNDARY && dragDir == Direction.RIGHT) {
      hasSwiped = true;
      posX = 2 * width;
    } else if (ratioX < -BOUNDARY && dragDir == Direction.LEFT) {
      hasSwiped = true;
      posX = -2 * width;
    } else {
      _onPanCancel();
    }

    if (hasSwiped) {
      setState(() => isMoving = false);

      Future.delayed(Duration(milliseconds: 200), () {
        widget.listener?.setListener(dragDir);
      });
    }
  }

  void _onPanCancel() => setState(() => resetValues());

  void resetValues() {
    dir = 0;
    posX = posY = 0.0;
    ratioX = ratioY = 0.0;
    angle = 0.0;
    isMoving = false;
    dragDir = Direction.NONE;
    previousPos = Offset.zero;
  }
}
