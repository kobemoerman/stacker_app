import 'package:flutter/material.dart';
import 'package:stackr/constants.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/widgets/textfield_platform.dart';

import '../model/user_inherited.dart';

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
    final _local = UserData.of(context).local;
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

class SearchHidden extends StatefulWidget {
  final bool isSearching;
  final FocusNode focus;
  final TextEditingController controller;

  const SearchHidden({
    Key key,
    @required this.isSearching,
    @required this.controller,
    @required this.focus,
  }) : super(key: key);

  @override
  _SearchHiddenState createState() => _SearchHiddenState();
}

class _SearchHiddenState extends State<SearchHidden> {
  @override
  Widget build(BuildContext context) {
    final _local = UserData.of(context).local;
    final _width = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      height: widget.isSearching ? 40.0 : 0.0,
      width: _width,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: FittedBox(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          width: _width,
          decoration: CardDecoration(
            focus: true,
            radius: 7.5,
            color: Theme.of(context).cardColor,
            brightness: Theme.of(context).brightness,
          ).shadow,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextFieldPlatform(
                  maxLines: 1,
                  hint: _local.stacksSearch,
                  controller: widget.controller,
                  focusNode: widget.focus,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => widget.controller.clear(),
                  child: Icon(Icons.close,
                      color: UserData.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
