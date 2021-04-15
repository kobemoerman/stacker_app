import 'package:flutter/material.dart';
import 'package:stackr/constants.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/widgets/textfield_platform.dart';

import '../model/user_inherited.dart';

enum Side { LEFT, RIGHT }

const double _kHeight = 56.0;
const Duration _kExpand = Duration(milliseconds: 250);

class SearchExpand extends StatefulWidget {
  final Side side;
  final double radius;
  final Function callback;

  const SearchExpand({
    Key key,
    this.side = Side.LEFT,
    @required this.radius,
    this.callback,
  })  : assert(side != null),
        assert(radius != null),
        super(key: key);

  @override
  _SearchExpandState createState() => _SearchExpandState();
}

class _SearchExpandState extends State<SearchExpand> {
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
      duration: _kExpand,
      width: isFolded ? _kHeight : 3 * width / 4,
      height: _kHeight,
      child: Row(
        children: [_searchField(), _searchIcon()],
      ),
      decoration: CardDecoration(
        focus: true,
        color: cRed,
        bottomLeft: widget.side == Side.LEFT ? 0.0 : widget.radius,
        bottomRight: widget.side == Side.RIGHT ? 0.0 : widget.radius,
        topLeft: widget.side == Side.LEFT ? 0.0 : widget.radius,
        topRight: widget.side == Side.RIGHT ? 0.0 : widget.radius,
        brightness: Theme.of(context).brightness,
      ).shadow,
    );
  }

  Widget _searchIcon() {
    var icon = Icon(isFolded ? Icons.search : Icons.close, color: Colors.white);

    return AnimatedContainer(
      duration: _kExpand,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => setState(() => isFolded = !isFolded),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: icon,
          ),
          splashColor: cRed,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(isFolded ? widget.radius : 0.0),
            right: Radius.circular(widget.radius),
          ),
        ),
      ),
    );
  }

  Widget _searchField() {
    final _local = UserData.of(context).local;
    Widget child;

    if (!isFolded) {
      child = TextFieldPlatform(
        maxLines: 1,
        hint: _local.search,
        controller: _textCtrl,
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
    final _theme = Theme.of(context);
    final _width = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: _kExpand,
      height: widget.isSearching ? 40.0 : 0.0,
      width: _width,
      margin: EdgeInsets.only(bottom: widget.isSearching ? 10.0 : 0.0),
      child: FittedBox(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          width: _width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _searchField(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _searchClear(),
              ),
            ],
          ),
          decoration: CardDecoration(
            focus: true,
            radius: 7.5,
            color: _theme.cardColor,
            brightness: _theme.brightness,
          ).shadow,
        ),
      ),
    );
  }

  Widget _searchField() {
    return TextFieldPlatform(
      maxLines: 1,
      hint: UserData.of(context).local.stacksSearch,
      controller: widget.controller,
      focusNode: widget.focus,
    );
  }

  Widget _searchClear() {
    return InkWell(
      onTap: () => widget.controller.clear(),
      child: Icon(Icons.close, color: UserData.of(context).primaryColor),
    );
  }
}
