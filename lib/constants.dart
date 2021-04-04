import 'package:flutter/material.dart';

import 'locale/localization.dart';

Color cRed = Color(0xFFD6737B);
Color cYellow = Color(0xFFE2C421);
Color cGreen = Color(0xFF80A78A);

Icon settings = Icon(Icons.settings, size: 30);
Icon close = Icon(Icons.close, size: 30, color: Colors.black54);
Icon edit = Icon(Icons.edit, color: Colors.white);
Icon arrowRight = Icon(Icons.keyboard_arrow_right);

Icon language = Icon(Icons.language);
Icon dark = Icon(Icons.bedtime);
Icon notification = Icon(Icons.notifications);
Icon help = Icon(Icons.help);
Icon privacy = Icon(Icons.lock);
Icon terms = Icon(Icons.file_copy);

Icon camera = Icon(Icons.camera_alt, color: Colors.white);
Icon gallery = Icon(Icons.image, color: Colors.white);

Icon sendY = Icon(Icons.send, color: Colors.white);
Icon sendN = Icon(Icons.send, color: Colors.red);

List<Color> themeDarkColor = [
  Colors.blue[300],
  Colors.indigo[300],
  Colors.blueGrey[300],
  Colors.teal[300],
  Colors.green[300],
  Colors.amber[200],
  Colors.orange[300],
  Colors.red[300],
  Colors.pink[300],
  Colors.deepPurple[300],
];

List<Color> themeLightColor = [
  Colors.blue[400],
  Colors.indigo[400],
  Colors.blueGrey[400],
  Colors.teal[400],
  Colors.green[400],
  Colors.amber[400],
  Colors.orange[400],
  Colors.red[400],
  Colors.pink[400],
  Colors.deepPurple[400],
];

Color getThemeColor(int index, Brightness brightness) =>
    brightness == Brightness.light
        ? themeLightColor[index]
        : themeDarkColor[index];

String getDayOfWeek(BuildContext context, String day) {
  if (day == 'Monday') return AppLocalization.of(context).mond;
  if (day == 'Tuesday') return AppLocalization.of(context).tues;
  if (day == 'Wednesday') return AppLocalization.of(context).wed;
  if (day == 'Thursday') return AppLocalization.of(context).thur;
  if (day == 'Friday') return AppLocalization.of(context).fri;
  if (day == 'Saturday') return AppLocalization.of(context).sat;
  if (day == 'Sunday') return AppLocalization.of(context).sun;

  return '';
}
