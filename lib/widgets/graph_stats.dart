import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stackr/model/stats_helper.dart';
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
      child: LineChart(
        LineChartData(
          lineTouchData: _lineTouchData,
          gridData: _gridData,
          titlesData: _titlesData,
          borderData: _borderData,
          minX: 0,
          maxX: 8,
          minY: 0,
          lineBarsData: [_lineBarsData],
        ),
      ),
    );
  }

  LineTouchData get _lineTouchData {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Theme.of(context).backgroundColor,
        getTooltipItems: _retrieveToolTipItems,
      ),
      handleBuiltInTouches: true,
      enabled: widget.detailed,
    );
  }

  FlGridData get _gridData {
    return FlGridData(
      show: true,
      drawHorizontalLine: false,
      drawVerticalLine: true,
    );
  }

  FlTitlesData get _titlesData {
    return FlTitlesData(
      bottomTitles: SideTitles(
        showTitles: true,
        getTitles: (value) {
          if (value == 0 || value == 8) return '';
          return _retrieveTitles(value.round() - 1);
        },
        getTextStyles: (value) => Theme.of(context).textTheme.bodyText2,
        margin: 10.0,
      ),
      leftTitles: SideTitles(showTitles: false),
    );
  }

  FlBorderData get _borderData {
    return FlBorderData(show: false);
  }

  LineChartBarData get _lineBarsData {
    List<double> values = StatsHelper.of(context).getOverview();

    return LineChartBarData(
      preventCurveOverShooting: true,
      spots: [
        FlSpot(1, values[0]),
        FlSpot(2, values[1]),
        FlSpot(3, values[2]),
        FlSpot(4, values[3]),
        FlSpot(5, values[4]),
        FlSpot(6, values[5]),
        FlSpot(7, values[6]),
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

  List<LineTooltipItem> _retrieveToolTipItems(List<LineBarSpot> lineSpot) {
    final _style = Theme.of(context).textTheme;

    var spot = lineSpot.map(
        (spot) => LineTooltipItem('${spot.y.round()} min', _style.bodyText2));

    return spot.toList();
  }

  String _retrieveTitles(int index) {
    var now = DateTime.now().subtract(Duration(days: 6 - index));

    return DateFormat('EEEE').format(now)[0].toUpperCase();
  }
}
