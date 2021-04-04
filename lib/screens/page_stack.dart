import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackr/decoration/textfield_border.dart';
import 'package:stackr/model/studystack.dart';
import 'package:stackr/screens/sheet_qna.dart';
import 'package:stackr/widgets/appbar_page.dart';
import 'package:stackr/widgets/card_study.dart';
import 'package:stackr/widgets/dialog_confirm.dart';
import 'package:stackr/widgets/button_icon.dart';

import 'sheet_flashcards.dart';
import '../constants.dart';
import '../model/flashcard.dart';
import '../model/user_inherited.dart';
import '../widgets/card_flip.dart';
import '../decoration/card_shadow.dart';
import '../utils/string_operation.dart';

const double OFFSET = 30.0;

class StackPage extends StatefulWidget {
  final String study;
  final String theme;
  final List<FlashCard> cards;

  final Function callback;

  StackPage({Key key, this.study, this.theme, this.cards, this.callback})
      : super(key: key);

  @override
  _StackPageState createState() => _StackPageState();
}

class _StackPageState extends State<StackPage> {
  final _name = TextEditingController();
  final _theme = TextEditingController();

  bool isFlipped;
  bool showFront;
  String answer = '';
  String question = '';

  setQuestion(String text) => setState(() => this.question = text);
  setAnswer(String text) => setState(() => this.answer = text);

  switchCard() {
    if (isFlipped) return;

    isFlipped = true;
    setState(() => this.showFront = !this.showFront);

    Future.delayed(Duration(milliseconds: 500)).then((_) => isFlipped = false);
  }

  @override
  void initState() {
    super.initState();
    showFront = true;
    isFlipped = false;

    _name.text = widget.study.formatDBToString();
    _theme.text = widget.theme.formatDBToString();
  }

  @override
  void dispose() {
    _name.dispose();
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                  children: [
                    headerField(hint: 'Stack name', controller: _name),
                    headerField(hint: 'Study theme', controller: _theme),
                  ],
                ),
              ),
              ButtonIcon(
                size: 32.5,
                icon: Icons.check,
                margin: const EdgeInsets.all(20.0),
                onTap: () => createDBTable(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),

        /// QUESTION INFO
        Flexible(
          fit: FlexFit.tight,
          child: LayoutBuilder(
            builder: (BuildContext ctx, BoxConstraints constraints) {
              return Column(
                children: [
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: cardInformation(
                        constraints.maxHeight,
                        constraints.maxWidth,
                      ),
                    ),
                    onTap: switchCard,
                  ),
                ],
              );
            },
          ),
        ),

        /// PAGE ACTIONS
        bottomActions()
      ],
    );
  }

  void editCardContent() {
    showBarModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionAnswerSheet(
        setQuestion: setQuestion,
        question: this.question,
        setAnswer: setAnswer,
        answer: this.answer,
        side: this.showFront,
      ),
    );
  }

  void seeAllCards() {
    showBarModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          FlashCardSheet(stack: widget.cards, callback: editQuestion),
    );
  }

  void createDBTable() async {
    if (_name.text.isEmpty || _theme.text.isEmpty) {
      _showInformationBar('Missing stack name or theme');
      return;
    }

    if (_name.text.startsWith(new RegExp('[0-9]'))) {
      _showInformationBar('Stack name must start with letter');
      return;
    }

    if (_theme.text.startsWith(new RegExp('[0-9]'))) {
      _showInformationBar('Stack theme must start with letter');
      return;
    }

    if (widget.cards.length < 1) {
      _showInformationBar('Stack must contain at least one questions');
      return;
    }

    var name =
        '${_name.text[0].toUpperCase()}${_name.text.substring(1).toLowerCase().replaceAll(' ', '_')}';

    var theme =
        '${_theme.text[0].toUpperCase()}${_theme.text.substring(1).toLowerCase().replaceAll(' ', '_')}';

    var table = '$name$theme'.formatStrinToDB();

    widget.callback(table, theme);
  }

  void addQuestion() {
    String message = 'Missing ';

    if (question.isNotEmpty && answer.isNotEmpty) {
      widget.cards.add(FlashCard(question: this.question, answer: this.answer));

      showFront = true;

      setQuestion('');
      setAnswer('');

      return;
    }

    if (question.isEmpty) message = message + 'question';
    if (answer.isEmpty)
      message = message + '${question.isEmpty ? ' and ' : ''}' + 'answer';

    _showInformationBar(message);
  }

  void editQuestion(FlashCard card) {
    setState(() {
      question = card?.question;
      answer = card?.answer;
    });
  }

  Widget cardInformation(double height, double width) {
    var child = Container(
      key: ValueKey(this.showFront),
      height: height,
      width: width,
      decoration: CardDecoration(
        radius: 10.0,
        brightness: Theme.of(context).brightness,
      ).shadow,
      child: StudyCard(
        title: this.showFront ? 'Question:' : 'Answer:',
        content: this.showFront ? this.question : this.answer,
        maxLines: 10,
        icon: Icons.edit,
        callback: editCardContent,
      ),
    );

    return FlipCard(
      showFront: this.showFront,
      child: child,
    );
  }

  Widget headerField({String hint, TextEditingController controller}) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0),
      child: TextField(
        autofocus: false,
        controller: controller,
        maxLines: 1,
        maxLength: 50,
        buildCounter: (_, {currentLength, maxLength, isFocused}) {
          return TextFieldBorder(
              current: currentLength, max: maxLength, theme: Theme.of(context));
        },
        decoration: InputDecoration(
          hintText: hint.formatDBToString(),
          isDense: true,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Row bottomActions() {
    var color = [UserData.of(context).primaryColor, cGreen];
    var icon = [Icons.menu, Icons.add];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List<Widget>.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 20.0),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => index == 0 ? seeAllCards() : addQuestion(),
              child: Container(
                height: 56.0,
                width: 56.0,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child:
                      FittedBox(child: Icon(icon[index], color: Colors.white)),
                ),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(index == 0 ? 0.0 : 10.0),
                bottomRight: Radius.circular(index == 0 ? 10.0 : 0.0),
                topLeft: Radius.circular(index == 0 ? 0.0 : 10.0),
                topRight: Radius.circular(index == 0 ? 10.0 : 0.0),
              ),
            ),
          ),
          decoration: CardDecoration(
            color: color[index],
            bottomLeft: index == 0 ? 0.0 : 10.0,
            bottomRight: index == 0 ? 10.0 : 0.0,
            topLeft: index == 0 ? 0.0 : 10.0,
            topRight: index == 0 ? 10.0 : 0.0,
            brightness: Theme.of(context).brightness,
          ).shadow,
        );
      }),
    );
  }

  void _showInformationBar(String message) {
    final color = UserData.of(context).primaryColor;

    Flushbar(
      message: message,
      isDismissible: true,
      duration: Duration(seconds: 3),
      flushbarStyle: FlushbarStyle.GROUNDED,
      icon: Icon(Icons.info_outline, size: 28.0, color: color),
      leftBarIndicatorColor: color,
    )..show(context);
  }
}

class EditStack extends StatefulWidget {
  final StudyStack table;

  const EditStack({Key key, this.table}) : super(key: key);

  @override
  _EditStackState createState() => _EditStackState(table.table);
}

class _EditStackState extends State<EditStack> {
  String _study;
  String _theme;

  List<FlashCard> _cards = [];

  final String table;

  _EditStackState(this.table);

  getCards(table) => UserData.of(context).dbClient.cardList(table: table);

  dropTable() async {
    var data = UserData.of(context);
    await data.dbClient.dropStack(name: this.table);
    data.generateTableList();

    List<String> list = data.featured.map((e) => e.table).toList();

    if (list.contains(this.table)) {
      list.remove(this.table);
      data.saveFeatured(list, 0, 0.0);
    }

    await data.refresh();
    Navigator.pop(context);
  }

  updateStack(String name, String theme) async {
    var data = UserData.of(context);

    if (this.table != name) {
      if (await data.dbClient.tableExist(table: name)) {
        _showInformationBar('This stack already exists');
        return;
      }
    }

    await data.dbClient.dropStack(name: this.table);
    await data.dbClient.createStack(name: name);

    _cards = data.dbClient.initStack(table: name, cards: _cards);
    data.dbClient.batchInsertCard(table: name, cards: _cards);
    data.generateTableList();

    List<String> list = data.featured.map((e) => e.table).toList();
    if (list.contains(this.table)) {
      list.remove(this.table);
      list.add(name);
      data.saveFeatured(list, 0, 0.0);
    }

    data.refresh();
    Navigator.pop(context);
  }

  void initState() {
    super.initState();
    _study = this.table.formatTable().first;
    _theme = this.table.formatTable().last;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_cards.isEmpty) {
      _cards = await getCards(this.table);
      setState(() => _cards);
    }
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PageAppBar(
        color: Theme.of(context).cardColor,
        height: 72.0,
        elevation: 7.5,
        title: 'Edit Stack',
        textColor: Theme.of(context).textSelectionColor,
        action: appBarAction(),
      ),
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: StackPage(
              study: _study,
              theme: _theme,
              cards: _cards,
              callback: updateStack,
            ),
          ),
        ),
      ),
    );
  }

  void _showInformationBar(String message) {
    final color = UserData.of(context).primaryColor;

    Flushbar(
      message: message,
      isDismissible: true,
      duration: Duration(seconds: 3),
      flushbarStyle: FlushbarStyle.GROUNDED,
      icon: Icon(Icons.info_outline, size: 28.0, color: color),
      leftBarIndicatorColor: color,
    )..show(context);
  }

  Widget appBarAction() {
    return IconButton(
      icon: Icon(Icons.delete, color: cRed, size: 24),
      onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) => ConfirmDialog(
          color: Theme.of(context).cardColor,
          title: 'Delete stack?',
          message: 'Are you sure you want to proceed with this action?',
          confirm: 'Delete',
          onConfirmPress: dropTable,
          dismiss: 'Cancel',
          radius: 15.0,
        ),
      ),
    );
  }
}

class CreateStack extends StatefulWidget {
  @override
  _CreateStackState createState() => _CreateStackState();
}

class _CreateStackState extends State<CreateStack> {
  List<FlashCard> _cards = [];

  createStack(String name, String theme) async {
    var data = UserData.of(context);

    if (await data.dbClient.tableExist(table: name)) {
      _showInformationBar('This stack already exists');
      return;
    }

    await data.dbClient.createStack(name: name);

    _cards = data.dbClient.initStack(table: name, cards: _cards);
    data.dbClient.batchInsertCard(table: name, cards: _cards);
    data.generateTableList();

    data.refresh();
    Navigator.pop(context);
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PageAppBar(
        color: Theme.of(context).cardColor,
        height: 72.0,
        elevation: 7.5,
        title: 'Create Stack',
        textColor: Theme.of(context).textSelectionColor,
      ),
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: StackPage(
              study: '',
              theme: '',
              cards: _cards,
              callback: createStack,
            ),
          ),
        ),
      ),
    );
  }

  void _showInformationBar(String message) {
    final color = UserData.of(context).primaryColor;

    Flushbar(
      message: message,
      isDismissible: true,
      duration: Duration(seconds: 3),
      flushbarStyle: FlushbarStyle.GROUNDED,
      icon: Icon(Icons.info_outline, size: 28.0, color: color),
      leftBarIndicatorColor: color,
    )..show(context);
  }
}
