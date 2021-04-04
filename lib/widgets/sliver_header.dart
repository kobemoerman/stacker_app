import 'package:flutter/material.dart';

class PersistentHeader extends SliverPersistentHeaderDelegate {
  final Color color;
  final Widget widget;
  final double height;

  PersistentHeader({@required this.widget, this.color, @required this.height});

  @override
  Widget build(BuildContext context, double shrink, bool overlap) {
    return Container(
      color: this.color,
      height: this.height,
      width: double.infinity,
      child: widget,
    );
  }

  @override
  double get maxExtent => this.height;

  @override
  double get minExtent => this.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
