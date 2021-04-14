import 'package:flutter/material.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/model/studystack.dart';
import 'package:stackr/model/user_inherited.dart';
import 'package:stackr/widgets/card_feature.dart';
import 'package:stackr/widgets/card_stats.dart';

const int _kPages = 2;

class FeaturedView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffold;
  final double height;

  const FeaturedView({Key key, this.height, @required this.scaffold})
      : assert(height != null),
        super(key: key);

  @override
  _FeaturedViewState createState() => _FeaturedViewState();
}

class _FeaturedViewState extends State<FeaturedView> {
  double _percent;
  String _cards;
  String _study;
  List<StudyStack> _tables = [];

  int _pageActive = 0;
  PageController _pageCtrl;

  _pageListener() {
    int next = _pageCtrl.page.round();

    if (_pageActive != next) setState(() => _pageActive = next);
  }

  @override
  void initState() {
    super.initState();

    _pageCtrl = PageController(viewportFraction: 0.9);
    _pageCtrl.addListener(() => _pageListener());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var data = UserData.of(context);

    _tables = data.featured;
    _cards = data.cards;
    _study = data.study;
    _percent = data.percent;
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: widget.height - 25.0,
          child: PageView.builder(
            key: Key('featured_widgets'),
            controller: _pageCtrl,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: _kPages,
            itemBuilder: _itemBuilder,
          ),
        ),
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: activePage(),
        ),
      ],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    bool active = index == _pageActive;

    Widget child;
    switch (index) {
      case 0:
        child = FeaturedCard(
          scaffold: widget.scaffold,
          tables: this._tables,
          cards: this._cards,
          study: this._study,
          percent: this._percent,
        );
        break;
      case 1:
        child = StatisticsCard(radius: 20.0);
        break;
    }

    return featureWidget(active, child);
  }

  Widget activePage() {
    final _color = UserData.of(context).primaryColor;
    final _theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_kPages, (idx) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          height: 7.5,
          width: idx == _pageActive ? 15.0 : 7.5,
          decoration: CardDecoration(
            focus: true,
            radius: 5.0,
            color: idx == _pageActive ? _color : _theme.unselectedWidgetColor,
            brightness: _theme.brightness,
          ).shadow,
        );
      }),
    );
  }

  Widget featureWidget(bool active, Widget child) {
    // final double blur = active ? 5.0 : 1.0;
    // final double offset = active ? 2.5 : 1.0;
    final double top = active ? 20.0 : 50.0;

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
      margin: EdgeInsets.fromLTRB(5.0, top / 2, 5.0, top / 2),
      decoration: CardDecoration(
        radius: 20.0,
        color: Theme.of(context).cardColor,
        brightness: Theme.of(context).brightness,
      ).shadow,
      child: Center(child: child),
    );
  }
}
