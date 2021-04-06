import 'package:flutter/material.dart';
import 'package:stackr/constants.dart';
import 'package:stackr/decoration/card_shadow.dart';

import '../locale/localization.dart';

enum Side { LEFT, RIGHT }

class SearchExpand extends StatefulWidget {
  final Function callback;
  final double radius;
  final Side side;

  const SearchExpand(
      {Key key, @required this.side, @required this.radius, this.callback})
      : assert(side != null),
        assert(radius != null),
        super(key: key);

  @override
  _SearchExpandState createState() => _SearchExpandState();
}

class _SearchExpandState extends State<SearchExpand> {
  static const int DUR = 250;
  static const double DIM = 56.0;

  bool isFolded = true;
  final _textCtrl = TextEditingController();

  textListener() => widget?.callback(_textCtrl.text.toLowerCase());

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(textListener);
  }

  @override
  void dispose() {
    super.dispose();
    _textCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: Duration(milliseconds: DUR),
      width: isFolded ? DIM : 3 * width / 4,
      height: DIM,
      decoration: CardDecoration(
        focus: true,
        color: cRed,
        bottomLeft: widget.side == Side.LEFT ? 0.0 : widget.radius,
        bottomRight: widget.side == Side.RIGHT ? 0.0 : widget.radius,
        topLeft: widget.side == Side.LEFT ? 0.0 : widget.radius,
        topRight: widget.side == Side.RIGHT ? 0.0 : widget.radius,
        brightness: Theme.of(context).brightness,
      ).shadow,
      child: Row(
        children: [
          _searchField(),
          _searchIcon(),
        ],
      ),
    );
  }

  Widget _searchIcon() {
    var icon = Icon(isFolded ? Icons.search : Icons.close, color: Colors.white);

    return AnimatedContainer(
      duration: Duration(milliseconds: DUR),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: icon,
          ),
          splashColor: cRed,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFolded ? widget.radius : 0.0),
            topRight: Radius.circular(widget.radius),
            bottomLeft: Radius.circular(isFolded ? widget.radius : 0.0),
            bottomRight: Radius.circular(widget.radius),
          ),
          onTap: () => setState(() => isFolded = !isFolded),
        ),
      ),
    );
  }

  Widget _searchField() {
    final _local = AppLocalization.of(context);
    Widget child;

    if (!isFolded) {
      child = TextField(
        style: TextStyle(color: Colors.white),
        controller: _textCtrl,
        decoration: InputDecoration(
          hintText: _local.search,
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      );
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(left: 16.0),
        child: child,
      ),
    );
  }
}

class SearchOverride extends StatefulWidget {
  final Offset begin;

  final Widget child;

  const SearchOverride({Key key, this.begin, this.child}) : super(key: key);

  @override
  _SearchOverrideState createState() => _SearchOverrideState();
}

class _SearchOverrideState extends State<SearchOverride> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 50.0,
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: ClipRect(
          child: AnimatedSwitcher(
            duration: Duration(seconds: 1),
            layoutBuilder: transitionLayout,
            transitionBuilder: transitionAnimation,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget transitionLayout(Widget currentChild, List<Widget> previousChildren) {
    List<Widget> children = previousChildren;
    if (currentChild != null) children = children.toList()..add(currentChild);
    return Stack(
      children: children,
      alignment:
          widget.begin.dx < 0.0 ? Alignment.centerLeft : Alignment.centerRight,
    );
  }

  Widget transitionAnimation(Widget child, Animation<double> animation) {
    Offset end = Offset(0.0, 0.0);
    Offset begin = widget.begin;

    final steps = Tween<Offset>(begin: begin, end: end).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: steps, child: child),
    );
  }
}
