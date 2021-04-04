import 'package:flutter/material.dart';

class TextFieldBorder extends StatelessWidget {
  static const double OFFSET = 2.0;

  final int current;
  final int max;
  final ThemeData theme;

  const TextFieldBorder(
      {Key key,
      @required this.current,
      @required this.max,
      @required this.theme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(height: OFFSET, decoration: bottomDecoration()),
                const SizedBox(height: 2.0),
                Container(
                  height: OFFSET,
                  width: 50.0,
                  decoration: bottomDecoration(),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              this.current.toString() + "/" + this.max.toString(),
              style: TextStyle(color: theme.shadowColor),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration bottomDecoration({double size}) {
    return BoxDecoration(
      color: theme.shadowColor,
      borderRadius: BorderRadius.circular(7.5),
    );
  }
}
