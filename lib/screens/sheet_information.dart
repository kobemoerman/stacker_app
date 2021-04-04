import 'package:flutter/material.dart';
import 'package:stackr/widgets/appbar_page.dart';

class InformationSheet extends StatelessWidget {
  final String header;

  const InformationSheet({Key key, this.header}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PageAppBar(
        blur: true,
        title: 'Information',
        textColor: Theme.of(context).textSelectionColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Center(
          child: Text(
            'Some information',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
