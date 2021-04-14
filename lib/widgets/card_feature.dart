import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:stackr/model/studystack.dart';
import 'package:stackr/model/user_inherited.dart';
import 'package:stackr/screens/page_study.dart';

import '../utils/string_operation.dart';
import 'dialog_information.dart';

const Duration _kOpen = Duration(milliseconds: 250);

class FeaturedCard extends StatelessWidget {
  final double percent;
  final String cards;
  final String study;
  final List<StudyStack> tables;
  final GlobalKey<ScaffoldState> scaffold;

  FeaturedCard({
    Key key,
    this.percent,
    this.cards,
    this.study,
    this.tables,
    @required this.scaffold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return OpenContainer(
      transitionDuration: _kOpen,
      closedColor: _theme.cardColor,
      openColor: _theme.cardColor,
      transitionType: ContainerTransitionType.fade,
      closedElevation: 0.0,
      closedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      openBuilder: _openBuilder,
      closedBuilder: _closedBuilder,
    );
  }

  Widget _openBuilder(BuildContext context, _) {
    return StudyPage(init: false, table: this.tables);
  }

  Widget _closedBuilder(BuildContext context, void Function() openContainer) {
    final _dialog = InfoDialog.of(context, this.scaffold);
    final _local = UserData.of(context).local;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => tables.isEmpty
            ? _dialog.displaySnackBar(text: _local.featuredEmptyInfo)
            : openContainer(),
        child: _containerBuilder(context),
      ),
    );
  }

  Widget _containerBuilder(BuildContext context) {
    var _text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_cardHeader(context), _cardContent(context)],
    );

    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: _text,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _progressIndicator(context),
          ),
        ],
      ),
    );
  }

  Widget _cardHeader(context) {
    final _color = UserData.of(context).primaryColor;
    final _theme = Theme.of(context).textTheme;

    return Text(
      this.study.formatDBToString(),
      style: _theme.headline2.copyWith(color: _color),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }

  Widget _cardContent(context) {
    final _local = UserData.of(context).local;
    final _theme = Theme.of(context).textTheme;

    var text = cards.length == 1 ? _local.question : _local.questions;

    return Text('$cards ${text.toLowerCase()}', style: _theme.subtitle1);
  }

  Widget _progressIndicator(context) {
    final _color = UserData.of(context).primaryColor;

    return LinearPercentIndicator(
      lineHeight: 5.0,
      animation: true,
      animateFromLastPercent: true,
      percent: this.percent,
      progressColor: _color,
      backgroundColor: _color.withAlpha(50),
      linearStrokeCap: LinearStrokeCap.roundAll,
    );
  }
}
