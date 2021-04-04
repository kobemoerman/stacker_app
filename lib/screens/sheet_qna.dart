import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return PageView(
      controller: _controller,
      onPageChanged: (_) => FocusScope.of(context).unfocus(),
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      children: [
        pageBuilder(
          header: 'Question',
          text: widget.question,
          controller: _qCtrl,
        ),
        pageBuilder(
          header: 'Answer',
          text: widget.answer,
          controller: _aCtrl,
        ),
      ],
    );
  }

  Widget pageBuilder({String header, String text, controller}) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: pageContent(header, text, controller),
      ),
    );
  }

  List<Widget> pageContent(header, text, controller) {
    String hint = 'Type ${header.toLowerCase()} here...';

    return [
      Text('$header:', style: Theme.of(context).textTheme.headline2),
      Platform.isIOS
          ? iosTextField(hint, controller)
          : androidTextField(hint, controller)
    ];
  }

  Widget iosTextField(hint, controller) {
    return CupertinoTextField(
      decoration: BoxDecoration(color: Colors.transparent),
      maxLength: 400,
      maxLines: null,
      autofocus: false,
      maxLengthEnforced: true,
      controller: controller,
      placeholder: hint,
      placeholderStyle: Theme.of(context).textTheme.subtitle1,
      style: Theme.of(context).textTheme.bodyText1,
      keyboardType: TextInputType.multiline,
      scrollPhysics: BouncingScrollPhysics(),
    );
  }

  Widget androidTextField(hint, controller) {
    return TextField(
      maxLength: 400,
      maxLines: null,
      maxLengthEnforced: true,
      controller: controller,
      keyboardType: TextInputType.multiline,
      scrollPhysics: BouncingScrollPhysics(),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: InputBorder.none,
      ),
    );
  }
}
