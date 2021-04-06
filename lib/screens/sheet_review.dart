import 'package:flutter/material.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/model/flashcard.dart';
import 'package:stackr/widgets/appbar_page.dart';
import 'package:stackr/widgets/tile_simple.dart';
import '../locale/localization.dart';
import '../model/user_inherited.dart';
import '../utils/string_operation.dart';

class CardModel {
  bool expanded;
  String title;
  String subtitle;

  CardModel(this.title, this.subtitle) {
    expanded = false;
  }
}

class ReviewSheet extends StatefulWidget {
  final List<FlashCard> cards;

  const ReviewSheet({Key key, this.cards}) : super(key: key);

  @override
  _ReviewSheetState createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  static const double HEADER_SIZE = 56.0;

  String title;

  List<CardModel> items;

  double cardHeight;

  @override
  void initState() {
    super.initState();
    items = widget.cards
        .map<CardModel>((c) => CardModel(c.question, c.answer))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final _local = UserData.of(context).local;

    if (title == null) {
      var size = widget.cards.length;
      title =
          '$size ${_local.wrong} ${(size == 1 ? _local.question : _local.questions).toLowerCase()}';
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PageAppBar(
        blur: true,
        title: title,
        textColor: Theme.of(context).textSelectionColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: HEADER_SIZE + 5.0),
              itemCount: widget.cards.length,
              itemBuilder: (context, index) => generateItem(context, index),
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
        color: Theme.of(context).unselectedWidgetColor.withOpacity(0.2),
      );

  Widget generateItem(BuildContext context, int index) {
    CardModel card = items.elementAt(index);

    final title = TextSpan(
      text: 'Q: ${card.title}',
      style: Theme.of(context).textTheme.bodyText2,
    );

    final subtitle = TextSpan(
      text: 'A: ${card.subtitle}',
      style: Theme.of(context).textTheme.subtitle2,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(10.0, 2.5, 10.0, 2.5),
      decoration: CardDecoration(
        focus: true,
        radius: 15.0,
        color: Theme.of(context).cardColor,
        brightness: Theme.of(context).brightness,
      ).shadow,
      child: ListTileTheme(
        dense: true,
        child: SimpleExpansionTile(
          radius: 15.0,
          title: title.text.formatCard(),
          initiallyExpanded: false,
          maintainState: false,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: seperator,
            ),
            Container(
              child: Text(subtitle.text.formatCard(),
                  style: subtitle.style, textAlign: TextAlign.start),
            ),
          ],
        ),
      ),
    );
  }
}
