import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const Duration _kExpand = Duration(milliseconds: 200);

class SimpleExpansionTile extends StatefulWidget {
  const SimpleExpansionTile({
    Key key,
    @required this.title,
    this.children = const <Widget>[],
    /*this.trailing,*/
    this.initiallyExpanded = false,
    this.maintainState = false,
    this.radius = 0.0,
  })  : assert(initiallyExpanded != null),
        assert(maintainState != null),
        super(key: key);

  final double radius;
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
  final bool maintainState;

  @override
  _SimpleExpansionTileState createState() => _SimpleExpansionTileState();
}

class _SimpleExpansionTileState extends State<SimpleExpansionTile>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);

  AnimationController _controller;
  Animation<double> _heightFactor;

  int _maxLines = 1;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);

    _isExpanded = PageStorage.of(context)?.readState(context) as bool ??
        widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _maxLines = 100;
        _controller.forward();
      } else {
        _maxLines = 1;
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: _isExpanded
                  ? BorderRadius.vertical(top: Radius.circular(widget.radius))
                  : BorderRadius.circular(widget.radius),
              onTap: () => _handleTap(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  widget.title,
                  maxLines: this._maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              heightFactor: _heightFactor.value,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    final bool shouldRemoveChildren = closed && !widget.maintainState;

    final Widget result = Offstage(
      child: TickerMode(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.children,
        ),
        enabled: !closed,
      ),
      offstage: closed,
    );

    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: shouldRemoveChildren ? null : result,
    );
  }
}
