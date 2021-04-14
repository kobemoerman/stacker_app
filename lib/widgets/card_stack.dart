import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/main.dart';
import 'package:stackr/model/studystack.dart';
import 'package:stackr/model/user_inherited.dart';
import 'package:stackr/screens/page_stack.dart';
import '../utils/string_operation.dart';

const Duration _kOpen = Duration(milliseconds: 250);
const Duration _dSelect = Duration(milliseconds: 400);

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
    final _theme = Theme.of(context);

    return Container(
      decoration: CardDecoration(
        focus: true,
        radius: this.radius,
        color: _theme.cardColor,
        brightness: _theme.brightness,
      ).shadow,
      child: OpenContainer(
        transitionDuration: _kOpen,
        closedElevation: 0.0,
        closedColor: _theme.cardColor,
        openColor: _theme.cardColor,
        transitionType: ContainerTransitionType.fade,
        closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(this.radius)),
        openBuilder: _openBuilder,
        closedBuilder: _closedBuilder,
      ),
    );
  }

  Widget _openBuilder(BuildContext context, _) {
    return CreateStack();
  }

  Widget _closedBuilder(BuildContext context, void Function() openContainer) {
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
  }

  Widget body(context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        /// CONTENT WIDGET
        this.table == null ? _stackCreate() : _stackTitle(context),

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
                  _stackEdit(context),
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                    ),
                    child: _isSelected(),
                  ),
                ],
              ),
            ),
          ),
      ].where((c) => c != null).toList(),
    );
  }

  Widget _stackCreate() => Stack(
        alignment: Alignment.center,
        children: [Icon(Icons.add, size: 70.0, color: data.primaryColor)],
      );

  Widget _stackTitle(BuildContext context) {
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

  Widget _isSelected() {
    return AnimatedOpacity(
      curve: Curves.decelerate,
      duration: _dSelect,
      opacity: study.containsKey(table.table) ? 1.0 : 0.0,
      child: Icon(Icons.school, color: Colors.white),
    );
  }

  Widget _stackEdit(BuildContext context) {
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
