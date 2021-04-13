import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stackr/widgets/appbar_page.dart';
import 'package:stackr/widgets/dialog_information.dart';

import '../model/flashcard.dart';
import '../model/user_inherited.dart';
import '../widgets/slidable.dart';
import '../widgets/searchbar.dart';
import '../decoration/card_shadow.dart';

const double _kRadius = 10.0;
const double _sHeader = 56.0;
const double _sSearch = 40.0;

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
  bool _isOpen = false;
  String _filter = '';

  List<FlashCard> filterList;
  SlidableController _slideCtrl;

  get search =>
      widget.stack.where((e) => e.question.toLowerCase().contains(_filter));

  _filterListener(String text) {
    _filter = text;
    filterList = _filter.isEmpty ? List.from(widget.stack) : search.toList();
    setState(() => filterList);
  }

  @override
  void initState() {
    super.initState();
    _filterListener(_filter);
    _slideCtrl = SlidableController();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _local = UserData.of(context).local;
    var size = widget.stack.length;

    String title = '$size ${size == 1 ? _local.question : _local.questions}';

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      backgroundColor: _theme.backgroundColor,
      appBar: PageAppBar(
        blur: true,
        title: title,
        textColor: _theme.textSelectionColor,
      ),
      body: Stack(
        children: [
          /// LIST VIEW
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: _sHeader, bottom: 2 * _sSearch),
              itemCount: filterList.length,
              itemBuilder: (_, index) => generateItem(index),
            ),
          ),

          /// SEARCH BAR
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: _sSearch),
              child: SearchExpand(
                  side: Side.LEFT, callback: _filterListener, radius: 10.0),
            ),
          ),

          /// SEPERATOR
          Padding(
            padding: const EdgeInsets.only(top: _sHeader),
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
    final _slide = SlidableAction(
      pos: index,
      isOpen: _isOpen,
      dismiss: _onDismissed,
      controller: _slideCtrl,
      child: _itemList(index),
    );

    return Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_kRadius),
        child: _slide,
      ),
      decoration: CardDecoration(
        focus: true,
        radius: _kRadius,
        brightness: Theme.of(context).brightness,
      ).shadow,
    );
  }

  Widget _itemList(int index) {
    final _theme = Theme.of(context);

    var item = filterList[index];
    var text = 'Q${widget.stack.indexOf(item) + 1}: ${item.question}';

    final _content = Text(
      text,
      style: _theme.textTheme.bodyText2,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Container(
      padding: const EdgeInsets.all(15.0),
      height: 50.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _theme.cardColor,
        borderRadius: BorderRadius.circular(_kRadius),
      ),
      child: _content,
    );
  }

  void _onDismissed(SlideActionType actionType, int index) {
    var idx = widget.stack.indexOf(filterList[index]);
    var _removed = widget.stack.removeAt(idx);

    if (actionType == SlideActionType.primary) {
      Navigator.pop(context);
      widget.callback(_removed);
    } else {
      _filterListener(_filter);
      _undoAction(context, _removed, idx);
    }
  }

  void _undoAction(BuildContext context, FlashCard item, int index) {
    final _local = UserData.of(context).local;

    InfoDialog.of(context, _scaffoldKey).undoSnackBar(
      text: '${_local.deleted} ${_local.question} ${index + 1}',
      onPressed: () {
        widget.stack.insert(index, item);
        _filterListener(_filter);
      },
    );
  }
}
