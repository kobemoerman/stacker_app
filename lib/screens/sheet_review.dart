import 'package:flutter/material.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/model/flashcard.dart';
import 'package:stackr/widgets/appbar_page.dart';
import 'package:stackr/widgets/tile_simple.dart';
import '../model/user_inherited.dart';
import '../utils/string_operation.dart';

const double _kHeader = 56.0;

class ReviewSheet extends StatefulWidget {
  final List<FlashCard> cards;

  const ReviewSheet({Key key, this.cards}) : super(key: key);

  @override
  _ReviewSheetState createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  String title;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _local = UserData.of(context).local;

    if (title == null) {
      var size = widget.cards.length;
      title =
          '$size ${_local.wrong} ${(size == 1 ? _local.question : _local.questions).toLowerCase()}';
    }

    return Scaffold(
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
              padding: const EdgeInsets.symmetric(vertical: _kHeader + 5.0),
              itemCount: widget.cards.length,
              itemBuilder: (context, index) => _buildItem(context, index),
            ),
          ),

          /// SEPERATOR
          Padding(
            padding: const EdgeInsets.only(top: _kHeader),
            child: seperator,
          ),
        ],
      ),
    );
  }

  Widget get seperator => Container(
        height: 0.5,
        width: double.infinity,
        color: Theme.of(context).unselectedWidgetColor.withOpacity(0.2),
      );

  Widget _buildItem(BuildContext context, int index) {
    final _theme = Theme.of(context);

    String _answer = widget.cards.elementAt(index).answer.formatCard();
    String _question = widget.cards.elementAt(index).question.formatCard();

    final title = 'Q: $_question';
    final subtitle = Text('A: $_answer',
        style: _theme.textTheme.subtitle2, textAlign: TextAlign.start);

    return Container(
      margin: const EdgeInsets.fromLTRB(10.0, 2.5, 10.0, 2.5),
      child: SimpleExpansionTile(
        radius: 15.0,
        title: title,
        initiallyExpanded: false,
        maintainState: false,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: seperator,
          ),
          subtitle,
        ],
      ),
      decoration: CardDecoration(
        focus: true,
        radius: 15.0,
        color: _theme.cardColor,
        brightness: _theme.brightness,
      ).shadow,
    );
  }
}
