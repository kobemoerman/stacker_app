import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';
import 'package:stackr/screens/page_study.dart';
import 'package:stackr/widgets/textfield_platform.dart';

import '../model/studystack.dart';
import '../model/user_inherited.dart';
import '../widgets/searchbar.dart';
import '../widgets/appbar_home.dart';
import '../widgets/sliver_header.dart';
import '../widgets/gridview_home.dart';
import '../widgets/pageview_feature.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSearching = false;

  double _opacity = 0.0;

  FocusNode _focus;
  ScrollController _scrollCtrl;
  TextEditingController _textCtrl;

  var study = <String, StudyStack>{};
  var data = <StudyStack>[];

  void _scrollListener() async {
    int dir = _scrollCtrl.position.userScrollDirection.index;
    double offset = _scrollCtrl.offset;

    if (offset < 0.0) offset = 0.0;

    double _pos;
    bool _anim = false;
    if (dir == ScrollDirection.reverse.index) {
      if (offset > 0.0 && offset < 200.0) {
        _anim = true;
        _pos = 250.0;
        _opacity = 1.0;
      }
    } else {
      if (offset < 250.0 && offset > 50.0) {
        _anim = true;
        _pos = 0.0;
        _opacity = 0.0;
      }
    }

    double _max = MediaQuery.of(context).size.height / 3;
    if (_anim &&
        _scrollCtrl.hasClients &&
        _scrollCtrl.position.maxScrollExtent > _max) {
      await _scrollCtrl.animateTo(_pos,
          duration: Duration(milliseconds: 75), curve: Curves.easeIn);
      setState(() => _opacity);
    }
  }

  void _searchListener() async {
    var maxPos = _scrollCtrl.position.maxScrollExtent;

    if (_focus.hasFocus) {
      await _scrollCtrl.animateTo(maxPos > 250.0 ? 250.0 : maxPos,
          duration: Duration(milliseconds: 100), curve: Curves.ease);

      setState(() {});
    }
  }

  void _textListener() {
    var data = UserData.of(context);

    setState(() => data.generateTableList(filter: _textCtrl.text));
  }

  @override
  void initState() {
    super.initState();

    _focus = FocusNode();
    _focus.addListener(() => _searchListener());
    _scrollCtrl = ScrollController();
    _scrollCtrl.addListener(() => _scrollListener());
    _textCtrl = TextEditingController();
    _textCtrl.addListener(() => _textListener());
  }

  @override
  void dispose() {
    super.dispose();
    _scrollCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _client = UserData.of(context);
    final _theme = Theme.of(context);

    final appBarWidget = HomeAppBar(color: _theme.backgroundColor);

    final featureWidget =
        SliverPersistentHeader(pinned: false, delegate: _feature());

    final titleWidget = SliverToBoxAdapter(child: _gridFilter());

    return Scaffold(
      backgroundColor: _theme.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
          },
          child: Stack(
            children: [
              FutureBuilder<List<StudyStack>>(
                future: _client.tables,
                builder: (context, snapshot) {
                  data = snapshot.hasData ? snapshot.data : [];

                  return CustomScrollView(
                    key: Key('scroll_home'),
                    controller: _scrollCtrl,
                    physics: BouncingScrollPhysics(),
                    slivers: <Widget>[
                      /// APP BAR
                      appBarWidget,

                      /// FEATURED PAGE VIEW
                      featureWidget,

                      /// LIST TITLE
                      SliverPadding(
                        padding: const EdgeInsets.all(15.0),
                        sliver: titleWidget,
                      ),

                      /// GRID VIEW
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        sliver: DynamicGridView(data, study),
                      ),

                      /// BOTTOM SPACE
                      SliverToBoxAdapter(child: SizedBox(height: 75.0))
                    ],
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 100.0,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      /// GRADIENT
                      IgnorePointer(child: bottomGradient()),
                      Align(
                        alignment: Alignment.centerRight,

                        /// STUDYING BUTTON
                        child: startStudying(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedOpacity bottomGradient() {
    var gradient =
        MediaQuery.of(context).viewInsets.bottom == 0.0 ? _opacity : 0.0;

    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: gradient,
      child: Container(
        height: 100.0,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              UserData.of(context).primaryColor.withOpacity(0.25),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Container startStudying() {
    AnimatedContainer animation = AnimatedContainer(
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 250),
      alignment: Alignment.center,
      height: study.isEmpty ? 0.0 : 52.0,
      width: study.isEmpty ? 0.0 : 52.0,
      padding: const EdgeInsets.all(10.0),
      child: FittedBox(
        child: Icon(Icons.arrow_forward_ios_sharp, color: Colors.white),
      ),
    );

    return Container(
      margin: EdgeInsets.only(right: (study.isEmpty ? 0.0 : 10.0)),
      child: OpenContainer(
        transitionDuration: Duration(milliseconds: 600),
        closedShape: CircleBorder(),
        closedColor: UserData.of(context).primaryColor,
        closedElevation: 4.0,
        transitionType: ContainerTransitionType.fade,
        onClosed: (_) => study.clear(),
        closedBuilder: (context, openContainer) => Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: openContainer,
            child: animation,
          ),
        ),
        openBuilder: (context, closeContainer) {
          var list = study.entries.map((e) => e.value).toList();

          return StudyPage(init: true, table: list);
        },
      ),
    );
  }

  Row _gridFilter() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() {
                if (isSearching) _textCtrl.clear();
                isSearching = !isSearching;
              }),
              child: Icon(
                Icons.search,
                key: UniqueKey(),
                color: UserData.of(context).primaryColor,
              ),
            ),
          ),
        ),
        SearchOverride(
          begin: Offset(-2.0, 0.0),
          child: isSearching ? _search() : _title(),
        ),
      ],
    );
  }

  Widget _title() {
    return Container(
      width: double.infinity,
      child: Text('STACKS', style: Theme.of(context).textTheme.headline1),
    );
  }

  Widget _search() {
    return TextFieldPlatform(
      controller: _textCtrl,
      hint: 'Search for a stack...',
      maxLines: 1,
      focusNode: _focus,
    );
  }

  PersistentHeader _feature() {
    return PersistentHeader(
      color: Theme.of(context).backgroundColor,
      height: 225.0,
      widget: FeaturedView(height: 225.0),
    );
  }
}
