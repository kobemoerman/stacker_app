import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stackr/widgets/appbar_page.dart';

import '../locale/localization.dart';
import '../model/flashcard.dart';
import '../model/user_inherited.dart';
import '../widgets/slidable.dart';
import '../widgets/searchbar.dart';
import '../decoration/card_shadow.dart';

// ignore: must_be_immutable
class FlashCardSheet extends StatefulWidget {
  final Function callback;
  List<FlashCard> stack;

  FlashCardSheet({Key key, @required this.stack, this.callback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FlashCardSheetState();
}

class _FlashCardSheetState extends State<FlashCardSheet> {
  static const double RADIUS = 10.0;
  static const double HEADER_SIZE = 56.0;
  static const double SEARCH_SIZE = 40.0;
  static const double BOTTOM_OFFSET = 45.0;

  bool _isOpen = false;
  String filter = '';

  List<FlashCard> filterList;
  SlidableController _slideCtrl;

  get search =>
      widget.stack.where((e) => e.question.toLowerCase().contains(filter));

  void filterListener(String text) {
    filter = text;

    filterList = filter.isEmpty ? List.from(widget.stack) : search.toList();

    setState(() => filterList);
  }

  @override
  void initState() {
    super.initState();
    filterListener(filter);
    _slideCtrl = SlidableController();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final _local = UserData.of(context).local;
    var size = widget.stack.length;

    String title = '$size ${size == 1 ? _local.question : _local.questions}';

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: PageAppBar(
        blur: true,
        title: title,
        textColor: Theme.of(context).textSelectionColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: [
          /// LIST VIEW
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                  top: HEADER_SIZE, bottom: SEARCH_SIZE + BOTTOM_OFFSET),
              itemCount: filterList.length,
              itemBuilder: (_, index) => generateItem(index),
            ),
          ),

          /// SEARCH BAR
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: BOTTOM_OFFSET),
              child: SearchExpand(
                  side: Side.LEFT, callback: filterListener, radius: 10.0),
            ),
          ),

          /// SEPERATOR
          Padding(
            padding: const EdgeInsets.only(top: HEADER_SIZE),
            child: seperator,
          ),
        ],
      ),
    );
  }

  Widget get seperator => Container(
        height: 0.5,
        width: double.infinity,
        color: Theme.of(context).unselectedWidgetColor.withOpacity(0.4),
      );

  Widget generateItem(int index) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: CardDecoration(
        focus: true,
        radius: RADIUS,
        brightness: Theme.of(context).brightness,
      ).shadow,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RADIUS),
        child: SlidableAction(
          pos: index,
          isOpen: _isOpen,
          dismiss: _onDismissed,
          controller: _slideCtrl,
          child: _itemList(index),
        ),
      ),
    );
  }

  Widget _itemList(int index) {
    var item = filterList[index];
    var text = 'Q${widget.stack.indexOf(item) + 1}: ${item.question}';

    return Container(
      padding: const EdgeInsets.all(15.0),
      height: 50.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(RADIUS),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyText2,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _onDismissed(SlideActionType actionType, int index) {
    var idx = widget.stack.indexOf(filterList[index]);
    var _removed = widget.stack.removeAt(idx);

    if (actionType == SlideActionType.primary) {
      Navigator.pop(context);
      widget.callback(_removed);
    } else {
      filterListener(filter);
      _undoSnackBar(context, _removed, idx);
    }
  }

  void _undoSnackBar(BuildContext context, FlashCard item, int index) {
    final _local = UserData.of(context).local;
    var snackbar = SnackBar(
      content: Text('${_local.deleted} ${_local.question} ${index + 1}'),
      action: SnackBarAction(
        label: _local.undo,
        onPressed: () {
          widget.stack.insert(index, item);
          filterListener(filter);
        },
      ),
    );

    _scaffoldKey.currentState
      ..removeCurrentSnackBar()
      ..showSnackBar(snackbar);
  }
}
