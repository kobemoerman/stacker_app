import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../constants.dart';
import '../model/user_inherited.dart';

class TextFieldPlatform extends StatefulWidget {
  final String hint;

  final FocusNode focusNode;

  final int maxLength;
  final int maxLines;
  final TextEditingController controller;

  const TextFieldPlatform(
      {Key key,
      this.maxLength,
      this.maxLines,
      this.controller,
      this.hint,
      this.focusNode})
      : super(key: key);

  @override
  _TextFieldPlatformState createState() => _TextFieldPlatformState();
}

class _TextFieldPlatformState extends State<TextFieldPlatform> {
  Color _decorationColor;

  void maxLengthListener() {
    _decorationColor =
        widget.controller.text.length < widget.maxLength ? null : cRed;

    setState(() => _decorationColor);
  }

  @override
  void initState() {
    super.initState();
    if (widget.maxLength != null) {
      widget.controller.addListener(maxLengthListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Platform.isIOS ? _iosTextField : _androidTextField,
        if (widget.maxLength != null) _bottomDecoration,
      ].where((e) => e != null).toList(),
    );
  }

  Widget get _bottomDecoration {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 2.0, width: double.infinity, decoration: _decoration),
          const SizedBox(height: 3.0),
          Container(height: 2.0, width: 50.0, decoration: _decoration),
        ],
      ),
    );
  }

  BoxDecoration get _decoration {
    if (_decorationColor == null)
      _decorationColor = Theme.of(context).shadowColor;

    return BoxDecoration(
      color: _decorationColor,
      borderRadius: BorderRadius.circular(7.5),
    );
  }

  Widget get _iosTextField {
    final _client = Theme.of(context);
    final _style = Theme.of(context).textTheme;

    return CupertinoTextField(
      autofocus: false,
      focusNode: widget.focusNode,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      maxLengthEnforced: widget.maxLength == null ? false : true,
      controller: widget.controller,
      placeholder: widget.hint,
      placeholderStyle: _style.subtitle2,
      style: _style.bodyText2,
      cursorColor: _client.primaryColor,
      keyboardType: widget.maxLines == null
          ? TextInputType.multiline
          : TextInputType.text,
      scrollPhysics: BouncingScrollPhysics(),
      decoration: BoxDecoration(color: Colors.transparent),
    );
  }

  Widget get _androidTextField {
    final _client = Theme.of(context);
    final _style = Theme.of(context).textTheme;

    return TextField(
      autofocus: false,
      focusNode: widget.focusNode,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      buildCounter: (context, {currentLength, isFocused, maxLength}) => null,
      maxLengthEnforced: widget.maxLength == null ? false : true,
      controller: widget.controller,
      style: _style.bodyText2,
      cursorColor: _client.primaryColor,
      keyboardType: widget.maxLines == null
          ? TextInputType.multiline
          : TextInputType.text,
      scrollPhysics: BouncingScrollPhysics(),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: _style.subtitle2,
        isDense: true,
        border: InputBorder.none,
      ),
    );
  }
}
