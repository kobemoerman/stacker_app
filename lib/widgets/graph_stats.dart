import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stackr/constants.dart';
import 'package:stackr/model/user_inherited.dart';

class InfoGraphic extends StatefulWidget {
  final bool detailed;
  final double width;
  final double height;

  const InfoGraphic({Key key, @required this.detailed, this.width, this.height})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _InfoGraphicState();
}

class _InfoGraphicState extends State<InfoGraphic> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: LineChart(chart),
    );
  }

  LineChartData get chart {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.white,
          getTooltipItems: (List<LineBarSpot> lineSpot) {
            return lineSpot
                .map((spot) => LineTooltipItem(
                    '${spot.y.round()} min', TextStyle(color: Colors.black)))
                .toList();
          },
        ),
        handleBuiltInTouches: true,
        enabled: widget.detailed,
      ),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: false,
        drawVerticalLine: true,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          getTitles: (value) {
            if (value == 0 || value == 8) return '';
            return retrieveTitles(value.round() - 1);
          },
          getTextStyles: (value) => Theme.of(context).textTheme.bodyText2,
          margin: 10.0,
        ),
        leftTitles: SideTitles(showTitles: false),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 8,
      minY: 0,
      lineBarsData: [populate],
    );
  }

  LineChartBarData get populate {
    List<double> values = retrieveStats();

    return LineChartBarData(
      preventCurveOverShooting: true,
      spots: [
        FlSpot(1, values[0]),
        FlSpot(2, values[1]),
        FlSpot(3, values[2]),
        FlSpot(4, values[3]),
        FlSpot(5, values[4]),
        FlSpot(6, values[5]),
        FlSpot(7, values[6])
      ],
      isCurved: true,
      colors: [UserData.of(context).primaryColor],
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, barData) => widget.detailed ? true : spot.x == 7,
      ),
    );
  }

  String retrieveTitles(int index) {
    var now = DateTime.now().subtract(Duration(days: 6 - index));

    return DateFormat('EEEE').format(now)[0].toUpperCase();
  }

  List<double> retrieveStats() {
    List<double> values = List.filled(7, 0.0, growable: false);
    List<String> list =
        UserData.of(context).preferences.getStringList('stats_week_review');

    var idx = 0;
    for (var i = 0; i < list.length; i++) {
      var val = list[idx].split('-').map(int.parse).toList();

      if (differenceOfDays(i, val)) {
        idx = idx + 1;
        values[i] = val[3].toDouble();
      }
    }

    return values.reversed.toList();
  }

  bool differenceOfDays(int dx, List<int> arr) {
    var n = DateTime.now();
    var d = DateTime(arr[0], arr[1], arr[2]);

    return n.subtract(Duration(days: dx)).difference(d).inDays == 0;
  }
}
