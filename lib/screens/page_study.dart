import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:stackr/utils/stopwatch_operation.dart';
import 'package:stackr/widgets/button_study.dart';

import '../model/flashcard.dart';
import '../model/studystack.dart';
import '../model/user_inherited.dart';
import '../widgets/card_swipe.dart';
import '../widgets/appbar_page.dart';
import '../screens/sheet_review.dart';
import '../decoration/card_shadow.dart';

import '../utils/list_operation.dart';
import '../utils/string_operation.dart';
import '../utils/date_operation.dart';

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

  UserDataState data;

  getCards(String table) => data.dbClient.cardList(table: table);
  double getProgress() => (_wrong + _correct) / (_total ?? double.infinity);
  double getPercentage() => (_correct) / (_total ?? double.infinity);

  void featuredStudy() async {
    /// update featured stack
    List<String> tables =
        List.generate(widget.table.length, (idx) => widget.table[idx].table);

    if (cardDesign[0].card == null && cardDesign[1].card == null) {
      widget.table.forEach((e) async {
        await data.dbClient.batchResetCard(table: e.table, length: e.cards);
      });
    }

    /// refresh context
    data.saveFeatured(tables, timer.getMilliseconds, getProgress());
    Navigator.pop(context);
  }

  void updateTimer(Timer timer) async {
    var date = DateTime.now();
    List<String> list = data.preferences.getStringList('stats_week_review');

    var time = 1;

    var val = list[0].split('-').map(int.parse).toList();

    if (date.difference(DateTime(val[0], val[1], val[2])).inDays == 0) {
      time = val[3] + 1;
      list[0] = date.convertToString() + '-$time';
    } else {
      list.removeLast();
      list.insert(0, date.convertToString() + '-$time');
    }

    data.saveToDisk('stats_week_review', list);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    timer.start();
    render = Timer.periodic(Duration(minutes: 1), updateTimer);

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

    /// update streak
    var now = DateTime.now();
    var streak = data.getFromDisk('stats_day_streak');
    var date = convertToDate(string: streak);
    if (now.compareDays(days: 1, date: date, equals: true)) {
      var value = int.parse(streak.split('-').last) + 1;
      var updated = now.convertToString() + '-$value';
      data.saveToDisk('stats_day_streak', updated);
    }
    if (!now.compareDays(days: 1, date: date)) {
      var value = now.convertToString() + '-0';
      data.saveToDisk('stats_day_streak', value);
    }

    /// retrieve all the cards
    for (var i = 0; i < widget.table.length; i++) {
      if (widget.init) {
        await data.dbClient.batchResetCard(
          table: widget.table[i].table,
          length: widget.table[i].cards,
        );
      }

      var list = await getCards(widget.table[i].table);
      cardContent.addAll(list);

      _total = (_total ?? 0) + widget.table[i].cards;
    }

    /// update swipe state
    if (!widget.init) {
      cardContent.removeWhere((e) {
        if (e.isSwipped == -1) {
          _wrong++;
          cardReview.add(e);
        }
        if (e.isSwipped == 1) _correct++;

        return e.isSwipped != 0;
      });

      var offset = data.getFromDisk('featured_time');
      if (!timer.isInitialised) timer.initialOffset = offset;
    }

    setState(() => createCards(null));
  }

  void dispose() {
    super.dispose();
    timer.stop();
    render.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final _animation = IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Lottie.asset(
          'assets/on_complete.json',
          controller: _completeCtrl,
          onLoaded: (composition) {
            if (_completeCtrl.isCompleted) _completeCtrl.reset();

            _completeCtrl
              ..duration = composition.duration
              ..forward();
          },
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PageAppBar(
        color: Theme.of(context).cardColor,
        height: 72.0,
        elevation: 7.5,
        title: _study,
        subtitle:
            '${_theme.formatDBToString()} | ${_wrong + _correct}/${_total ?? 0}',
        textColor: UserData.of(context).primaryColor,
        onPress: featuredStudy,
      ),
      body: SafeArea(
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                timerIndicator(),
                                SizedBox(width: 10.0),
                                Expanded(child: progressIndicator()),
                              ],
                            ),
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
                      callback: isComplete ? reviewCards : swipeCard,
                    ),
                    StudyButton(
                      side: Side.R,
                      value: _correct,
                      isComplete: isComplete,
                      callback: isComplete ? restartCards : swipeCard,
                    ),
                  ],
                ),
              ],
            ),
            this.isComplete && getPercentage() > 0.75 ? _animation : null,
          ].where((e) => e != null).toList(),
        ),
      ),
    );
  }

  void reviewCardSheet() {
    showBarModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewSheet(cards: cardReview),
    );
  }

  void updateStatRatio() {
    var res;
    var now = DateTime.now();
    var ratio = data.getFromDisk('stats_correct_ratio');
    var date = convertToDate(string: ratio);
    if (now.compareDays(days: 0, date: date, equals: true)) {
      var value = ratio.split('-');
      var c = int.parse(value[3]) + _correct;
      var t = int.parse(value[4]) + _total;
      res = now.convertToString() + '-$c' + '-$t';
    } else {
      res = now.convertToString() + '-$_correct' + '-$_total';
    }
    data.saveToDisk('stats_correct_ratio', res);
  }

  void updateStatBestStack() async {
    var res = 0.0;
    var table;
    var best = data.getFromDisk('stats_best_stack').split('-');

    for (var i = 0; i < widget.table.length; i++) {
      var ratio = await data.dbClient.tableRatio(table: widget.table[i].table);
      if (ratio > res) {
        table = widget.table[i].table;
        res = ratio;
      }
    }

    if (res > double.parse(best.last)) {
      data.saveToDisk('stats_best_stack', table + '-$res');
    }
  }

  void reviewCards() {
    if (cardReview.isEmpty) return;

    cardDesign = [];
    cardContent = List.from(cardReview);
    cardReview.forEach((e) {
      e.setSwipped = 0;
      data.dbClient.updateCard(e, e.theme);
    });
    cardReview = [];

    _wrong = 0;
    _correct = 0;
    _total = cardContent.length;
    isComplete = false;
    isSwipped = false;

    timer.reset();
    render = Timer.periodic(Duration(minutes: 1), updateTimer);
    timer.start();

    setState(() {
      createCards(null);
    });
  }

  void restartCards() async {
    cardDesign = [];
    cardReview = [];
    cardContent = [];

    for (var i = 0; i < widget.table.length; i++) {
      await data.dbClient.batchResetCard(
        table: widget.table[i].table,
        length: widget.table[i].cards,
      );
      var list = await getCards(widget.table[i].table);
      cardContent.addAll(list);
    }

    _wrong = 0;
    _correct = 0;
    _total = cardContent.length;
    isComplete = false;
    isSwipped = false;

    timer.reset();
    render = Timer.periodic(Duration(minutes: 1), updateTimer);
    timer.start();

    setState(() {
      createCards(null);
    });
  }

  void swipeCard(int side) {
    if (isSwipped) return;

    isSwipped = true;
    var width = MediaQuery.of(context).size.width;
    var ratio = side.isEven ? -0.3 : 0.3;
    cardDesign[1].state.swipeCard(ratio, width);
  }

  SwipeCard refreshCards(Direction dir) {
    SwipeCard oldCard = cardDesign.removeAt(cardDesign.length - 1);

    if (dir == Direction.RIGHT) _correct++;
    if (dir == Direction.LEFT) {
      _wrong++;
      cardReview.add(oldCard.card);
    }

    var newCard = SwipeCard(
      key: UniqueKey(),
      card: cardContent.isNotEmpty ? newStudyCard() : null,
      progress: 0.0,
      callback: this.refreshCards,
      review: this.reviewCardSheet,
      listener: null,
    );

    cardDesign.insert(0, newCard);

    if (oldCard.card != null) {
      oldCard.card.setSwipped = dir == Direction.RIGHT ? 1 : -1;
      data.dbClient.updateCard(oldCard.card, oldCard.card.theme);
    }

    if (cardDesign[1].card == null) {
      updateStatRatio();
      updateStatBestStack();
      timer.stop();
      render.cancel();
      cardDesign[1].progress = getPercentage();
      Future.delayed(Duration(milliseconds: 250), () {
        setState(() => isComplete = true);
      });
    } else {
      isSwipped = false;
    }

    setState(() => cardDesign);

    return cardDesign[0];
  }

  FlashCard newStudyCard() {
    this.index = Random().nextInt(cardContent.length);

    return cardContent.removeAt(this.index);
  }

  void createCards(SwipeCard card) {
    if (cardDesign.length == 2) {
      cardDesign[0].card = cardContent.length == 1 ? null : newStudyCard();
      cardDesign[1].card = newStudyCard();
      return;
    }

    cardDesign.add(SwipeCard(
      key: UniqueKey(),
      card: null,
      progress: 0.0,
      callback: this.refreshCards,
      review: this.reviewCardSheet,
      listener: card,
    ));

    return createCards(cardDesign[0]);
  }

  String formatTime(int milliseconds) {
    var secs = milliseconds ~/ 1000;
    var hours = (secs ~/ 3600).toString().padLeft(2, '0');
    var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    // var seconds = (secs % 60).toString().padLeft(2, '0');

    return '$hours:$minutes min';
  }

  Widget timerIndicator() {
    return Container(
      height: 30.0,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 7.5),
      child: Text(
        formatTime(timer.getMilliseconds),
        style: Theme.of(context).textTheme.bodyText1,
      ),
      decoration: CardDecoration(
        focus: true,
        radius: 5.0,
        brightness: Theme.of(context).brightness,
      ).shadow,
    );
  }

  Widget progressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      height: 30.0,
      alignment: Alignment.center,
      child: LinearPercentIndicator(
        lineHeight: 15.0,
        animation: true,
        animateFromLastPercent: true,
        percent: getProgress(),
        progressColor: UserData.of(context).primaryColor,
        backgroundColor: UserData.of(context).primaryColor.withAlpha(50),
        linearStrokeCap: LinearStrokeCap.butt,
      ),
      decoration: CardDecoration(
        focus: true,
        radius: 5.0,
        brightness: Theme.of(context).brightness,
      ).shadow,
    );
  }
}
