import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/model/fb_helper.dart';
import 'package:stackr/model/studystack.dart';
import 'package:stackr/model/user_inherited.dart';
import 'package:stackr/widgets/button_icon.dart';
import 'package:stackr/widgets/searchbar.dart';
import 'package:stackr/widgets/sliver_header.dart';
import '../utils/string_operation.dart';

class DownloadSheet extends StatefulWidget {
  final List<StudyStack> stacks;

  const DownloadSheet({Key key, @required this.stacks}) : super(key: key);

  @override
  _DownloadSheetState createState() => _DownloadSheetState();
}

class _DownloadSheetState extends State<DownloadSheet> {
  final _storage = FirebaseStorage.instance.ref();

  bool _isInit = false;
  bool _isDownloading = false;

  final _list = List<String>();
  final _filter = List<String>();
  final _stacks = List<String>();
  final _selected = <String, bool>{};

  void filterListener(String text) {
    _filter.clear();
    _list.forEach((e) {
      var format = e.formatTable();
      var str = '${format.first} ${format.last}';

      if (str.toLowerCase().contains(text)) _filter.add(e);
    });

    setState(() => _filter);
  }

  Future<ListResult> _getData() {
    return _storage.child('Medicine').listAll();
  }

  void _downloadData() {
    setState(() => _isDownloading = true);
    final temp = List<String>();

    _selected.forEach((key, value) {
      if (!value) temp.add(key);
    });

    FBHelper(context).downloadList(temp, _storage).then((value) {
      _isDownloading = false;
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.stacks.forEach((e) => _stacks.add(e.table));
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (_list.isNotEmpty) return;

    var _db = await _getData();

    for (Reference ref in _db.items) {
      String table = FirebaseStorage.instance.ref(ref.fullPath).name;

      _list.add(table);
      _filter.add(table);

      var str = table.substring(0, table.length - 4);
      if (!_selected.containsKey(table) && _stacks.contains(str)) {
        _selected[table] = true;
      }
    }

    setState(() => _isInit = true);
  }

  @override
  Widget build(BuildContext context) {
    final _connecting = Theme.of(context).brightness == Brightness.light
        ? 'assets/connecting_light.json'
        : 'assets/connecting_dark.json';

    Widget _body = Container(
      alignment: Alignment.center,
      child: Lottie.asset(_connecting, height: 75, width: 75),
    );

    if (_isInit) _body = dataBuilder(_filter);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _body,
            pageHeader(),
            searchBuilder(),
            _isDownloading ? downloadOverlay() : null,
          ].where((e) => e != null).toList(),
        ),
      ),
    );
  }

  Widget get seperator => Container(
        height: 0.5,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 15.0),
        color: Theme.of(context).unselectedWidgetColor.withOpacity(0.4),
      );

  Widget searchBuilder() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 45.0),
        child: SearchExpand(
            side: Side.LEFT, callback: filterListener, radius: 10.0),
      ),
    );
  }

  Widget dataBuilder(List<String> list) {
    return CustomScrollView(
      key: Key('scroll_download'),
      physics: BouncingScrollPhysics(),
      slivers: [
        /// HEADER
        SliverPadding(
          padding: const EdgeInsets.only(top: 62.0),
          sliver: SliverPersistentHeader(
            pinned: false,
            delegate: listHeader(),
          ),
        ),

        /// LIST VIEW
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 125.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => listItem(list[index]),
              childCount: list.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget downloadOverlay() {
    return Container(
      color: Colors.black45,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
      child: Lottie.asset('assets/loading.json', width: 150, height: 150),
    );
  }

  Container pageHeader() {
    final local = UserData.of(context).local;
    final theme = Theme.of(context).textTheme;

    final leading = ButtonIcon(
      icon: Icons.cloud_download,
      size: 24,
      onTap: () => _downloadData(),
    );

    final title = Text(local.avilableStackHeader, style: theme.headline3);

    return Container(
      height: 56.0,
      child: Stack(
        children: [
          ClipRect(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 5.0),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Container(
            height: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [leading, title],
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: seperator),
        ],
      ),
    );
  }

  PersistentHeader listHeader() {
    final theme = Theme.of(context);
    final data = UserData.of(context);

    var header = Text(
      'Medicine',
      style: theme.textTheme.headline2.copyWith(color: Colors.white),
    );

    return PersistentHeader(
      height: 50.0,
      color: Colors.transparent,
      widget: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.only(left: 10.0),
        alignment: Alignment.centerLeft,
        decoration: CardDecoration(
          focus: true,
          radius: 10.0,
          color: data.primaryColor,
          brightness: theme.brightness,
        ).shadow,
        child: header,
      ),
    );
  }

  Widget listItem(String item) {
    final format = item.formatTable();

    var header = Text(
      format.last,
      style: Theme.of(context).textTheme.bodyText1,
    );

    var child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      height: 50.0,
      width: double.infinity,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [header, isSelected(item)],
      ),
    );

    return Container(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: () => setState(() {
            bool isSelected = _selected[item] ?? false;
            if (!isSelected) {
              if (_selected.containsKey(item)) {
                _selected.remove(item);
              } else {
                _selected[item] = false;
              }
            }
          }),
          child: Column(
            children: [child, seperator],
          ),
        ),
      ),
    );
  }

  Widget isSelected(String item) {
    final color = UserData.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
      child: AnimatedOpacity(
        curve: Curves.decelerate,
        duration: Duration(milliseconds: 250),
        opacity: _selected.containsKey(item) ? 1.0 : 0.0,
        child: Icon(Icons.check, color: color),
      ),
    );
  }
}
