import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stackr/widgets/textfield_platform.dart';

class QuestionAnswerSheet extends StatefulWidget {
  final String question;
  final Function setQuestion;

  final String answer;
  final Function setAnswer;

  final bool side;

  const QuestionAnswerSheet({
    Key key,
    this.question,
    this.setQuestion,
    this.answer,
    this.setAnswer,
    this.side,
  }) : super(key: key);

  @override
  _QuestionAnswerState createState() => _QuestionAnswerState();
}

class _QuestionAnswerState extends State<QuestionAnswerSheet> {
  PageController _controller;
  final _qCtrl = TextEditingController();
  final _aCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.side ? 0 : 1);

    if (widget.question.isNotEmpty) {
      _qCtrl.text = widget.question;
    }

    if (widget.answer.isNotEmpty) {
      _aCtrl.text = widget.answer;
    }
  }

  @override
  void deactivate() {
    widget.setQuestion(_qCtrl.text);
    widget.setAnswer(_aCtrl.text);
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
        },
        child: PageView(
          controller: _controller,
          onPageChanged: (_) => FocusScope.of(context).unfocus(),
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: [
            pageBuilder(header: 'Question', controller: _qCtrl),
            pageBuilder(header: 'Answer', controller: _aCtrl),
          ],
        ),
      ),
    );
  }

  Widget pageBuilder({String header, controller}) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: pageContent(header, controller),
      ),
    );
  }

  List<Widget> pageContent(header, controller) {
    String hint = 'Type ${header.toLowerCase()} here...';

    return [
      Text('$header:', style: Theme.of(context).textTheme.headline2),
      Expanded(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: TextFieldPlatform(controller: controller, hint: hint),
        ),
      ),
    ];
  }
}
