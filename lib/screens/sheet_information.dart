import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:stackr/widgets/appbar_page.dart';

class InformationSheet extends StatelessWidget {
  final String header;
  final String file;

  const InformationSheet({Key key, @required this.header, @required this.file})
      : super(key: key);

  Future<String> getFileData(String path) async {
    return rootBundle.loadString(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PageAppBar(
        blur: true,
        title: this.header,
        textColor: Theme.of(context).textSelectionColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        child: FutureBuilder(
          future: getFileData('assets/${this.file}'),
          builder: (context, snapshot) {
            String text = 'Could not find requested file...';
            if (snapshot.hasData) {
              text = snapshot.data;
            }

            return textLayout(context, text);
          },
        ),
      ),
    );
  }

  Widget textLayout(BuildContext context, String text) {
    final _theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(10.0, 56.0, 10.0, 0.0),
      child: Text(text, style: _theme.bodyText2),
    );
  }
}
