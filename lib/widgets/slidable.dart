import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../constants.dart';

class SlidableAction extends StatefulWidget {
  final int pos;
  final bool isOpen;
  final Widget child;
  final Function dismiss;
  final SlidableController controller;

  const SlidableAction(
      {Key key,
      this.dismiss,
      this.controller,
      this.pos,
      this.child,
      this.isOpen})
      : super(key: key);

  @override
  _SlidableActionState createState() => _SlidableActionState();
}

class _SlidableActionState extends State<SlidableAction> {
  @override
  Widget build(BuildContext context) {
    return Slidable.builder(
      key: UniqueKey(),
      controller: widget.controller,
      direction: Axis.horizontal,
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        onDismissed: (action) => widget.dismiss(action, widget.pos),
      ),
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.20,
      child: slideChild(child: widget.child),
      actionDelegate: SlideActionBuilderDelegate(
        actionCount: 1,
        builder: _actionBuilder,
      ),
      secondaryActionDelegate: SlideActionBuilderDelegate(
        actionCount: 1,
        builder: _secondaryActionBuilder,
      ),
    );
  }

  Widget _actionBuilder(BuildContext context, int index,
      Animation<double> animation, SlidableRenderingMode renderingMode) {
    return _slideAction(context, SlideActionType.primary, Icons.edit, cYellow);
  }

  Widget _secondaryActionBuilder(BuildContext context, int index,
      Animation<double> animation, SlidableRenderingMode renderingMode) {
    return _slideAction(context, SlideActionType.secondary, Icons.delete, cRed);
  }

  Widget _slideAction(context, type, icon, color) {
    return IconSlideAction(
      closeOnTap: false,
      color: color,
      icon: icon,
      foregroundColor: Colors.white,
      onTap: () => Slidable.of(context).dismiss(actionType: type),
    );
  }

  Widget slideChild({Widget child}) {
    var colors = [cYellow, cRed];

    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(2, (index) {
            return Container(
              width: 25.0,
              height: 50.0,
              color: colors[index],
            );
          }),
        ),
        Align(alignment: Alignment.center, child: child),
      ],
    );
  }
}
