import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
    final _theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _theme.backgroundColor,
      appBar: PageAppBar(
        blur: true,
        title: this.header,
        textColor: _theme.textSelectionColor,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        child: FutureBuilder(
          future: getFileData('assets/${this.file}'),
          builder: (context, snapshot) {
            String text;
            if (snapshot.hasData) {
              text = snapshot.data;
            }
            return text != null
                ? textLayout(context, text)
                : loadingLayout(context);
          },
        ),
      ),
    );
  }

  Widget loadingLayout(BuildContext context) {
    final _h = MediaQuery.of(context).size.height;
    return Container(
      height: _h,
      alignment: Alignment.center,
      child: Lottie.asset('assets/loading.json', width: 150, height: 150),
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
