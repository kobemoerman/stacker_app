import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:stackr/model/stats_helper.dart';
import 'package:stackr/utils/stopwatch_operation.dart';
import 'package:stackr/widgets/button_study.dart';
import 'package:stackr/widgets/dialog_information.dart';

import '../model/flashcard.dart';
import '../model/studystack.dart';
import '../model/user_inherited.dart';
import '../widgets/card_swipe.dart';
import '../widgets/appbar_page.dart';
import '../screens/sheet_review.dart';
import '../decoration/card_shadow.dart';

import '../utils/list_operation.dart';
import '../utils/string_operation.dart';

const _dSwipe = Duration(milliseconds: 250);
const _dTime = Duration(minutes: 1);

class StudyPage extends StatefulWidget {
  final bool init;
  final List<StudyStack> table;

  const StudyPage({Key key, this.table, this.init}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> with TickerProviderStateMixin {
  AnimationController _completeCtrl;

  String _study;
  String _theme;

  int _wrong = 0;
  int _correct = 0;
  int _total;

  int index = 0;

  bool isComplete = false;
  bool isSwipped = false;

  Timer render;
  StudyTimer timer = StudyTimer();

  List<SwipeCard> cardDesign = [];
  List<FlashCard> cardContent = [];
  List<FlashCard> cardReview = [];

  StatsHelper stat;
  UserDataState data;

  _getCards(String table) => data.dbClient.cardList(name: table);
  double getProgress() => (_wrong + _correct) / (_total ?? double.infinity);
  double getPercentage() => _correct / (_total ?? double.infinity);

  _initStudy({int w = 0, int c = 0, int t = 1}) {
    _wrong = w;
    _correct = c;
    _total = t;
    isComplete = false;
    isSwipped = false;

    timer.reset();
    render = Timer.periodic(_dTime, _updateTimer);
    timer.start();

    setState(() => buildCardStack());
  }

  _updateTimer(Timer timer) {
    setState(() => stat.updateOverview());
  }

  _updateFeatured() async {
    /// update featured stack
    List<String> tables =
        List.generate(widget.table.length, (idx) => widget.table[idx].table);

    if (cardDesign[0].card == null && cardDesign[1].card == null) {
      widget.table.forEach((e) async {
        await data.dbClient.batchResetCard(name: e.table, length: e.cards);
      });
    }

    /// refresh context
    data.saveFeatured(tables, timer.getMilliseconds, getProgress());
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    _completeCtrl = AnimationController(vsync: this);

    _study = widget.table
        .map((e) => e.table.formatTable().first)
        .toList()
        .getOccurences()
        .join(', ')
        .formatDBToString();

    _theme = widget.table
        .map((e) => e.table.formatTable().last)
        .toList()
        .getOccurences()
        .join(', ')
        .formatDBToString();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (cardDesign.isNotEmpty || data != null) return;

    data = UserData.of(context);
    stat = StatsHelper.of(context);
    stat.updateStreak();

    int wrong = 0, correct = 0, total = 0;

    /// retrieve all the cards
    for (var i = 0; i < widget.table.length; i++) {
      if (widget.init) {
        await data.dbClient.batchResetCard(
          name: widget.table[i].table,
          length: widget.table[i].cards,
        );
      }

      var list = await _getCards(widget.table[i].table);
      cardContent.addAll(list);

      total = total + widget.table[i].cards;
    }

    /// update swipe state
    if (!widget.init) {
      cardContent.removeWhere((e) {
        if (e.isSwipped == -1) {
          wrong++;
          cardReview.add(e);
        }
        if (e.isSwipped == 1) correct++;

        return e.isSwipped != 0;
      });

      var offset = data.getFromDisk('featured_time');
      if (!timer.isInitialised) timer.initialOffset = offset;
    }

    _initStudy(w: wrong, c: correct, t: total);
  }

  void dispose() {
    timer.stop();
    render.cancel();
    _completeCtrl.dispose();
    super.dispose();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var _prog = '${_wrong + _correct}/${_total ?? 0}';

    var _indicators = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _timeIndicator(),
        SizedBox(width: 10.0),
        Expanded(child: _progressIndicator()),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PageAppBar(
        color: Theme.of(context).cardColor,
        height: 72.0,
        elevation: 7.5,
        title: _study,
        subtitle: '${_theme.formatDBToString()} | $_prog',
        textColor: UserData.of(context).primaryColor,
        onPress: _updateFeatured,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext ctx, BoxConstraints constraints) {
                      return Column(
                        children: [
                          /// PROGRESS INFORMATION
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 0.15 * constraints.maxHeight,
                            alignment: Alignment.center,
                            child: _indicators,
                          ),

                          /// QUESTION SHEET
                          Container(
                            height: 0.85 * constraints.maxHeight,
                            child: Stack(children: cardDesign),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StudyButton(
                      side: Side.L,
                      value: _wrong,
                      isComplete: isComplete,
                      callback: isComplete ? _reviewCards : swipeCard,
                    ),
                    StudyButton(
                      side: Side.R,
                      value: _correct,
                      isComplete: isComplete,
                      callback: isComplete ? _restartCards : swipeCard,
                    ),
                  ],
                ),
              ],
            ),

            /// COMPLETE ANIMATION
            this.isComplete && getPercentage() > 0.75
                ? _completeAnimation()
                : null,
          ].where((e) => e != null).toList(),
        ),
      ),
    );
  }

  _reviewCardSheet() {
    showBarModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewSheet(cards: cardReview),
    );
  }

  _onStackComplete() async {
    timer.stop();
    render.cancel();

    cardDesign[1].progress = getPercentage();
    cardDesign[0].progress = getPercentage();

    Future.delayed(_dSwipe, () => setState(() => isComplete = true));

    stat.updateDailyRatio(_correct, _total);
    await stat.updateBestStack(widget.table);
  }

  _reviewCards() {
    if (cardReview.isEmpty) {
      InfoDialog.of(context, _scaffoldKey)
          .displaySnackBar(text: 'No cards to review.');
      return;
    }

    cardDesign = [];
    cardContent = List.from(cardReview);

    cardReview.forEach((e) {
      e.setSwipped = 0;
      data.dbClient.updateCard(e, e.theme);
    });
    cardReview = [];

    _initStudy(t: cardContent.length);
  }

  _restartCards() async {
    cardDesign = [];
    cardReview = [];
    cardContent = [];

    for (var i = 0; i < widget.table.length; i++) {
      await data.dbClient.batchResetCard(
        name: widget.table[i].table,
        length: widget.table[i].cards,
      );
      var list = await _getCards(widget.table[i].table);
      cardContent.addAll(list);
    }

    _initStudy(t: cardContent.length);
  }

  void swipeCard(int side) {
    if (isSwipped) return;

    isSwipped = true;
    var width = MediaQuery.of(context).size.width;
    var ratio = side.isEven ? -0.3 : 0.3;
    cardDesign[1].state.swipeCard(ratio, width);
  }

  SwipeCard onSwipeAction(Direction dir) {
    SwipeCard oldCard = cardDesign.removeAt(cardDesign.length - 1);

    if (dir == Direction.RIGHT) _correct++;
    if (dir == Direction.LEFT) {
      _wrong++;
      cardReview.add(oldCard.card);
    }

    var newCard = SwipeCard(
      key: UniqueKey(),
      card: cardContent.isNotEmpty ? newStudyCard() : null,
      callback: this.onSwipeAction,
      review: this._reviewCardSheet,
      listener: null,
    );

    cardDesign.insert(0, newCard);

    if (oldCard.card != null) {
      oldCard.card.setSwipped = dir == Direction.RIGHT ? 1 : -1;
      data.dbClient.updateCard(oldCard.card, oldCard.card.theme);
    }

    if (cardDesign[1].card == null) {
      _onStackComplete();
    } else
      isSwipped = false;

    setState(() => cardDesign);

    return cardDesign[0];
  }

  FlashCard newStudyCard() {
    this.index = Random().nextInt(cardContent.length);

    return cardContent.removeAt(this.index);
  }

  void buildCardStack({SwipeCard card}) {
    if (cardDesign.length == 2) {
      cardDesign[0].card = cardContent.length == 1 ? null : newStudyCard();
      cardDesign[1].card = newStudyCard();
      return;
    }

    cardDesign.add(SwipeCard(
      key: UniqueKey(),
      callback: this.onSwipeAction,
      review: this._reviewCardSheet,
      listener: card,
    ));

    return buildCardStack(card: cardDesign[0]);
  }

  String formatTime(int milliseconds) {
    var secs = milliseconds ~/ 1000;
    var hours = (secs ~/ 3600).toString().padLeft(2, '0');
    var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    // var seconds = (secs % 60).toString().padLeft(2, '0');

    return '$hours:$minutes min';
  }

  Widget _completeAnimation() {
    var _lottie = Lottie.asset(
      'assets/on_complete.json',
      controller: _completeCtrl,
      onLoaded: (composition) {
        if (_completeCtrl.isCompleted) _completeCtrl.reset();

        _completeCtrl
          ..duration = composition.duration
          ..forward();
      },
    );

    return IgnorePointer(
      child: Align(alignment: Alignment.bottomCenter, child: _lottie),
    );
  }

  Widget _timeIndicator() {
    final _theme = Theme.of(context);

    var _indicator = Text(
      formatTime(timer.getMilliseconds),
      style: _theme.textTheme.bodyText1,
    );

    return Container(
      height: 30.0,
      padding: const EdgeInsets.symmetric(horizontal: 7.5),
      alignment: Alignment.center,
      child: _indicator,
      decoration: CardDecoration(
        focus: true,
        radius: 5.0,
        brightness: _theme.brightness,
      ).shadow,
    );
  }

  Widget _progressIndicator() {
    final _theme = Theme.of(context);
    final _color = UserData.of(context).primaryColor;

    var _indicator = LinearPercentIndicator(
      lineHeight: 15.0,
      animation: true,
      animateFromLastPercent: true,
      percent: getProgress(),
      progressColor: _color,
      backgroundColor: _color.withAlpha(50),
      linearStrokeCap: LinearStrokeCap.butt,
    );

    return Container(
      height: 30.0,
      padding: EdgeInsets.symmetric(vertical: 5.0),
      alignment: Alignment.center,
      child: _indicator,
      decoration: CardDecoration(
        focus: true,
        radius: 5.0,
        brightness: _theme.brightness,
      ).shadow,
    );
  }
}
