import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackr/constants.dart';
import 'package:stackr/locale/localization.dart';
import 'package:stackr/model/studystack.dart';
import 'package:stackr/model/user.dart';

import '../locale/localization.dart';
import 'db_helper.dart';

import '../utils/list_operation.dart';
import '../utils/string_operation.dart';

class UserData extends StatefulWidget {
  final Widget child;
  final AppLocalization local;
  final SharedPreferences preferences;

  const UserData(
      {@required this.child, @required this.local, @required this.preferences});

  static UserDataState of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<_InheritedUserData>()).data;

  @override
  UserDataState createState() => UserDataState(this.preferences, this.local);
}

class UserDataState extends State<UserData> {
  AppLocalization local;
  final SharedPreferences preferences;

  UserDataState(this.preferences, this.local);

  DBHelper dbClient;

  User user = new User('', null);
  Color primaryColor = themeDarkColor[0];
  ImageProvider profile;

  double percent = 0.0;
  String cards = '0';
  String study = '';
  List<StudyStack> featured = [];

  Future<List<StudyStack>> tables;

  refresh() => setState(() {});

  dynamic getFromDisk(key) => this.preferences.get(key);
  dynamic saveToDisk<T>(String key, T content) async {
    print('(TRACE) LocalStorageService:saveToDisk. key: $key value: $content');

    if (content is String) {
      await preferences.setString(key, content);
    }
    if (content is bool) {
      await preferences.setBool(key, content);
    }
    if (content is int) {
      await preferences.setInt(key, content);
    }
    if (content is double) {
      await preferences.setDouble(key, content);
    }
    if (content is List<String>) {
      await preferences.setStringList(key, content);
    }
  }

  void updateThemeColor() async {
    final brightness = Theme.of(context).brightness;
    final index = getFromDisk('theme_color') ?? 0;

    this.primaryColor = getThemeColor(index, brightness);

    refresh();
  }

  featuredStudy(List<StudyStack> list) => list
      .map((e) => e.table.formatTable().last)
      .toList()
      .getOccurences()
      .join(', ');

  featuredCards(List<StudyStack> list) =>
      list.map((e) => e.cards).toList().fold(0, (p, c) => p + c).toString();

  String base64String(Uint8List data) => base64Encode(data);

  ImageProvider imageFromBase64String(String base64String) =>
      base64String == null
          ? AssetImage('assets/profile.jpeg')
          : MemoryImage(base64Decode(base64String));

  void generateTableList({String filter = ''}) {
    if (this.dbClient == null) this.dbClient = new DBHelper();

    this.tables = dbClient.tableList(filter.toLowerCase());
  }

  void saveImage(String value) {
    user.photoUrl = value;
    saveToDisk('profile_photo', value);

    setState(() {
      profile = imageFromBase64String(user.photoUrl);
    });
  }

  void saveName(String value) {
    user.name = value;

    saveToDisk('profile_name', value);
    this.refresh();
  }

  void saveFeatured(List<String> list, int time, double value) async {
    await saveToDisk('featured_stack', list);
    await saveToDisk('featured_progress', value);
    await saveToDisk('featured_time', time);

    updateFeatured();
  }

  updateFeatured() async {
    percent = getFromDisk('featured_progress') ?? 0.0;

    List<StudyStack> _tables = [];
    var _study = getFromDisk('featured_stack') ?? [];
    for (var i = 0; i < _study.length; i++) {
      var amount = await dbClient.tableLength(name: _study[i]);
      _tables.add(StudyStack(_study[i], amount));
    }

    setState(() {
      if (_tables.isNotEmpty) {
        study = featuredStudy(_tables);
        cards = featuredCards(_tables);
      } else {
        study = local.featuredEmptyHeader;

        cards = '0';
      }
      featured = _tables;
    });
  }

  updateLanguage(String tag, String subtag) async {
    saveToDisk('lang_tag', tag);
    saveToDisk('lang_subtag', subtag);

    local = await AppLocalization.load(Locale(tag, subtag));

    this.refresh();
  }

  initUser() {
    var _name = getFromDisk('profile_name') ?? 'Student';
    var _photo = getFromDisk('profile_photo');

    var _color = getFromDisk('theme_color') ?? 0;

    setState(() {
      user = User(_name, _photo);
      profile = imageFromBase64String(user.photoUrl);
      primaryColor = getThemeColor(_color, Theme.of(context).brightness);
    });
  }

  @override
  void initState() {
    super.initState();
    initUser();
    generateTableList();
    updateFeatured();
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedUserData(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedUserData extends InheritedWidget {
  final UserDataState data;

  _InheritedUserData({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedUserData old) => true;
}
