import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/main.dart';
import 'package:stackr/model/studystack.dart';
import 'package:stackr/model/user_inherited.dart';
import 'package:stackr/screens/page_stack.dart';
import '../utils/string_operation.dart';

class StackCard extends StatelessWidget {
  final int index;

  final StudyStack table;

  final Color color;
  final double radius;
  final EdgeInsets padding;

  final UserDataState data;
  final ThemeData theme;

  final Map<String, StudyStack> study;

  StackCard({
    Key key,
    this.table,
    this.padding,
    this.radius,
    this.color,
    this.index,
    this.study,
    @required this.data,
    @required this.theme,
  }) : super(key: key);

  selectStudy(BuildContext context, int index) {
    this.study.containsKey(table.table)
        ? this.study.remove(table.table)
        : this.study[table.table] = table;

    UserData.of(context).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CardDecoration(
        focus: true,
        radius: this.radius,
        color: Theme.of(context).cardColor,
        brightness: Theme.of(context).brightness,
      ).shadow,
      child: OpenContainer(
        transitionDuration: Duration(milliseconds: 250),
        closedElevation: 0.0,
        closedColor: Theme.of(context).cardColor,
        openColor: Theme.of(context).cardColor,
        transitionType: ContainerTransitionType.fade,
        closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(this.radius)),
        openBuilder: (context, closeContainer) => CreateStack(),
        closedBuilder: (context, openContainer) {
          InkWell action;

          if (this.table == null) {
            action = InkWell(onTap: openContainer, child: body(context));
          } else {
            action = InkWell(
              onTap: () => selectStudy(context, this.index),
              child: body(context),
            );
          }

          return Material(type: MaterialType.transparency, child: action);
        },
      ),
    );
  }

  Widget body(context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        /// CONTENT WIDGET
        this.table == null ? createStack() : studyStack(context),

        /// BOTTOM ACTION
        if (this.table != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              height: 50,
              color:
                  color.withOpacity(study.containsKey(table.table) ? 1.0 : 0.5),
              duration: Duration(milliseconds: 250),
              padding: this.padding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  editStack(context),
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                    ),
                    child: isSelected(),
                  ),
                ],
              ),
            ),
          ),
      ].where((c) => c != null).toList(),
    );
  }

  Widget createStack() => Stack(
        alignment: Alignment.center,
        children: [Icon(Icons.add, size: 70.0, color: data.primaryColor)],
      );

  Widget studyStack(BuildContext context) {
    final _local = UserData.of(context).local;
    String text = this.table.table.formatTable().last;

    return Container(
      width: double.infinity,
      padding: this.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            text.formatDBToString(),
            maxLines: 3,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyText2,
          ),
          Text(
            '${this.table.cards} ${_local.cards}',
            style: theme.textTheme.subtitle2,
          ),
        ],
      ),
    );
  }

  Widget isSelected() {
    return AnimatedOpacity(
      curve: Curves.decelerate,
      duration: Duration(milliseconds: 400),
      opacity: study.containsKey(table.table) ? 1.0 : 0.0,
      child: Icon(Icons.school, color: Colors.white),
    );
  }

  Widget editStack(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/edit',
              arguments: PageArguments(table: [table])),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
