import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackr/model/studystack.dart';
import 'package:stackr/screens/sheet_qna.dart';
import 'package:stackr/widgets/appbar_page.dart';
import 'package:stackr/widgets/card_study.dart';
import 'package:stackr/widgets/dialog_confirm.dart';
import 'package:stackr/widgets/button_icon.dart';
import 'package:stackr/widgets/dialog_information.dart';
import 'package:stackr/widgets/textfield_platform.dart';

import 'sheet_flashcards.dart';
import '../constants.dart';
import '../model/flashcard.dart';
import '../model/user_inherited.dart';
import '../widgets/card_flip.dart';
import '../decoration/card_shadow.dart';
import '../utils/string_operation.dart';

class CreateBuilder extends StatelessWidget {
  final String table;
  final List<FlashCard> cards;

  final Function callback;
  final Widget actionBar;

  CreateBuilder({
    Key key,
    this.table,
    this.cards,
    this.callback,
    this.actionBar,
  }) : super(key: key);

  _onCompleteCallback(BuildContext context, String name, String theme) async {
    final data = UserData.of(context);
    final _local = UserData.of(context).local;
    final _dialog = InfoDialog.of(context, _scaffoldKey);

    if (this.table != name) {
      if (await data.dbClient.tableExist(name: name)) {
        _dialog.displaySnackBar(text: _local.infoStackExists);
        return;
      }
    }

    await this.callback(name, theme);

    var list = data.dbClient.initStack(name: name, cards: cards);
    data.dbClient.batchInsertCard(name: name, cards: list);
    data.generateTableList();

    data.refresh();
    Navigator.pop(context);
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _local = UserData.of(context).local;

    var studyName, themeName;
    if (this.table.isEmpty) {
      studyName = themeName = '';
    } else {
      studyName = this.table.formatTable()?.first;
      themeName = this.table.formatTable()?.last;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: PageAppBar(
        color: _theme.cardColor,
        height: 72.0,
        elevation: 7.5,
        title: _local.editStackHeader,
        textColor: _theme.textSelectionColor,
        action: this.actionBar,
      ),
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: StackPage(
            scaffold: _scaffoldKey,
            study: studyName,
            theme: themeName,
            cards: this.cards,
            callback: _onCompleteCallback,
          ),
        ),
      ),
    );
  }
}

class StackPage extends StatefulWidget {
  final String study;
  final String theme;
  final List<FlashCard> cards;

  final Function callback;

  final GlobalKey<ScaffoldState> scaffold;

  const StackPage({
    Key key,
    this.study,
    this.theme,
    this.cards,
    this.callback,
    @required this.scaffold,
  }) : super(key: key);

  @override
  _StackPageState createState() => _StackPageState();
}

class _StackPageState extends State<StackPage> {
  TextEditingController _name;
  TextEditingController _theme;

  bool isFlipped;
  bool showFront;
  String answer = '';
  String question = '';

  setQuestion(String text) => setState(() => this.question = text);
  setAnswer(String text) => setState(() => this.answer = text);

  flipCard() {
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

    _name = TextEditingController();
    _theme = TextEditingController();

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
    final _local = UserData.of(context).local;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// NAME & THEME TEXTFIELDS
              Flexible(
                child: Column(
                  children: [
                    headerField(hint: _local.tableName, controller: _name),
                    const SizedBox(height: 10.0),
                    headerField(hint: _local.tableTheme, controller: _theme),
                  ],
                ),
              ),

              /// COMPLETE ACTION
              ButtonIcon(
                size: 32.5,
                icon: Icons.check,
                margin: const EdgeInsets.all(20.0),
                onTap: () => _createDBTable(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),

        /// QUESTION INFO
        Flexible(
          fit: FlexFit.tight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTap: flipCard,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: cardBuilder(
                    constraints.maxHeight,
                    constraints.maxWidth,
                  ),
                ),
              );
            },
          ),
        ),

        /// PAGE ACTIONS
        _bottomActions()
      ],
    );
  }

  _editCardSheet() {
    showBarModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionAnswerSheet(
        question: this.question,
        setQuestion: setQuestion,
        answer: this.answer,
        setAnswer: setAnswer,
        side: this.showFront,
      ),
    );
  }

  _overviewCardSheet() {
    showBarModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          FlashCardSheet(stack: widget.cards, callback: _editQuestion),
    );
  }

  _editQuestion(FlashCard card) {
    setState(() {
      question = card?.question;
      answer = card?.answer;
    });
  }

  _addQuestion() {
    if (question.isNotEmpty && answer.isNotEmpty) {
      widget.cards.add(FlashCard(question: this.question, answer: this.answer));

      showFront = true;

      setQuestion('');
      setAnswer('');

      return;
    }

    final _local = UserData.of(context).local;

    String message = '${_local.missing} ';
    if (question.isEmpty) {
      message = message + _local.question.toLowerCase();
    }
    if (answer.isEmpty) {
      var concat = question.isEmpty ? ' ${_local.and} ' : '';
      message = message + concat + _local.answer.toLowerCase();
    }

    InfoDialog.of(context, widget.scaffold).displaySnackBar(text: message);
  }

  _createDBTable() async {
    final _regex = RegExp('[0-9]');
    final _local = UserData.of(context).local;

    var msg;
    if (_name.text.isEmpty || _theme.text.isEmpty)
      msg = _local.infoMissingNameTheme;

    if (_name.text.startsWith(_regex)) msg = _local.infoNameLetterStart;

    if (_theme.text.startsWith(_regex)) msg = _local.infoThemeLetterStart;

    if (widget.cards.length < 1) msg = _local.infoMoreQuestion;

    if (msg != null) {
      InfoDialog.of(context, widget.scaffold).displaySnackBar(text: msg);
      return;
    }

    var name = _name.text.simplify();
    var theme = _theme.text.simplify();
    var table = '$name$theme'.formatStringToDB();

    widget.callback(context, table, theme);
  }

  Widget cardBuilder(double height, double width) {
    final _theme = Theme.of(context);
    final _local = UserData.of(context).local;

    var _card = StudyCard(
      title: this.showFront ? '${_local.question}:' : '${_local.answer}:',
      content: this.showFront ? this.question : this.answer,
      icon: Icons.edit,
      callback: _editCardSheet,
    );

    var _decoration = CardDecoration(
      radius: 10.0,
      brightness: _theme.brightness,
    ).shadow;

    return FlipCard(
      showFront: this.showFront,
      child: Container(
        key: ValueKey(this.showFront),
        height: height,
        width: width,
        child: _card,
        decoration: _decoration,
      ),
    );
  }

  Widget headerField({String hint, TextEditingController controller}) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0),
      child: TextFieldPlatform(
        controller: controller,
        maxLines: 1,
        maxLength: 50,
        hint: hint.formatDBToString(),
      ),
    );
  }

  Row _bottomActions() {
    final _theme = Theme.of(context);
    final _client = UserData.of(context);

    Widget _overview = Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _overviewCardSheet(),
          child: Container(
            height: 56.0,
            width: 56.0,
            padding: const EdgeInsets.all(15.0),
            child: FittedBox(child: Icon(Icons.menu, color: Colors.white)),
          ),
          borderRadius: _splashRadius(10.0, 0.0),
        ),
      ),
      decoration: CardDecoration(
        topRight: 10.0,
        bottomRight: 10.0,
        color: _client.primaryColor,
        brightness: _theme.brightness,
      ).shadow,
    );

    Widget _add = Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _addQuestion(),
          child: Container(
            height: 56.0,
            width: 56.0,
            padding: const EdgeInsets.all(15.0),
            child: FittedBox(child: Icon(Icons.add, color: Colors.white)),
          ),
          borderRadius: _splashRadius(0.0, 10.0),
        ),
      ),
      decoration: CardDecoration(
        topLeft: 10.0,
        bottomLeft: 10.0,
        color: cGreen,
        brightness: _theme.brightness,
      ).shadow,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_overview, _add],
    );
  }

  BorderRadius _splashRadius(double r, double l) {
    return BorderRadius.horizontal(
        right: Radius.circular(r), left: Radius.circular(l));
  }
}

class EditStack extends StatefulWidget {
  final StudyStack table;

  const EditStack({Key key, this.table}) : super(key: key);

  @override
  _EditStackState createState() => _EditStackState(table.table);
}

class _EditStackState extends State<EditStack> {
  List<FlashCard> _cards = [];

  final String table;

  _EditStackState(this.table);

  get tableCards => UserData.of(context).dbClient.cardList(name: this.table);

  _updateFeatured(UserDataState client) {
    List<String> list = client.featured.map((e) => e.table).toList();
    if (list.contains(this.table)) {
      list.remove(this.table);
      client.saveFeatured(list, 0, 0.0);
    }
  }

  _dropTable() async {
    var _client = UserData.of(context);

    await _client.dbClient.dropStack(name: this.table);
    _client.generateTableList();

    _updateFeatured(_client);

    await _client.refresh();
    Navigator.pop(context);
  }

  updateStack(String name, String theme) async {
    final _client = UserData.of(context);

    await _client.dbClient.dropStack(name: this.table);
    await _client.dbClient.createStack(name: name);

    _updateFeatured(_client);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_cards.isEmpty) {
      _cards = await tableCards;
      setState(() => _cards);
    }
  }

  @override
  Widget build(BuildContext context) => CreateBuilder(
        table: this.table,
        cards: _cards,
        callback: updateStack,
        actionBar: _onActionConfirm(),
      );

  Widget _onActionConfirm() {
    final _local = UserData.of(context).local;

    final _dialog = ConfirmDialog(
      color: Theme.of(context).cardColor,
      title: _local.infoDeleteHeader,
      message: _local.infoDeleteStack,
      confirm: _local.delete,
      onConfirmPress: _dropTable,
      dismiss: _local.cancel,
      radius: 15.0,
    );

    return IconButton(
      icon: Icon(Icons.delete, color: cRed, size: 24),
      onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) => _dialog,
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
    final data = UserData.of(context);

    await data.dbClient.createStack(name: name);
  }

  @override
  Widget build(BuildContext context) =>
      CreateBuilder(table: '', cards: _cards, callback: createStack);
}
