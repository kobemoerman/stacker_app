import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stackr/model/studystack.dart';
import 'package:stackr/model/user_inherited.dart';

import '../widgets/card_stack.dart';

class DynamicGridView extends StatefulWidget {
  final List<StudyStack> tables;
  final Map<String, StudyStack> study;

  const DynamicGridView(this.tables, this.study);

  @override
  State<StatefulWidget> createState() => _DynamicGridViewState();
}

class _DynamicGridViewState extends State<DynamicGridView> {
  static const RAD = 20.0;

  @override
  Widget build(BuildContext context) {
    return SliverStaggeredGrid.countBuilder(
      key: Key('grid_view'),
      itemCount: widget.tables.length + 1,
      crossAxisSpacing: 15.0,
      mainAxisSpacing: 20.0,
      crossAxisCount: 2,
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
      itemBuilder: (context, index) => Container(
        height: index == 0 ? 100.0 : 250.0,
        child: index == 0 ? createStack() : studyStack(index),
      ),
    );
  }

  Widget createStack() => StackCard(
        radius: 20.0,
        color: Theme.of(context).cardColor,
        theme: Theme.of(context),
        data: UserData.of(context),
      );

  Widget studyStack(int index) {
    StudyStack table = widget.tables.elementAt(index - 1);

    return StackCard(
      table: table,
      index: index,
      study: widget.study,
      radius: 20.0,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      color: UserData.of(context).primaryColor,
      theme: Theme.of(context),
      data: UserData.of(context),
    );
  }
}
