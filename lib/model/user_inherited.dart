import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackr/constants.dart';
import 'package:stackr/locale/localization.dart';
import 'package:stackr/model/studystack.dart';
import 'package:stackr/model/user.dart';

import 'db_helper.dart';
import 'language.dart';

import '../utils/list_operation.dart';
import '../utils/string_operation.dart';

class UserData extends StatefulWidget {
  final Widget child;
  final SharedPreferences preferences;

  const UserData({@required this.child, @required this.preferences});

  static UserDataState of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<_InheritedUserData>()).data;

  @override
  UserDataState createState() => UserDataState(this.preferences);
}

class UserDataState extends State<UserData> {
  final SharedPreferences preferences;

  UserDataState(this.preferences);

  DBHelper dbClient;

  User user = new User('', null);
  Color primaryColor = themeDarkColor[0];
  ImageProvider profile;

  Language language;

  double percent = 0.0;
  String cards = '0';
  String study = 'Start studying';
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

  void updateLanguage(String tag, String subtag) {
    language.tag = saveToDisk('lang_tag', tag);
    language.subtag = saveToDisk('lang_subtag', subtag);
    AppLocalization.load(Locale(tag, subtag));

    this.refresh();
  }

  void updateThemeColor() async {
    final brightness = Theme.of(context).brightness;
    final index = getFromDisk('theme_color') ?? 0;

    this.primaryColor = getThemeColor(index, brightness);

    refresh();
  }

  featuredStudy(List<StudyStack> list) => list
      .map((e) => e.table.formatTable().first)
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

    this.tables = dbClient.tableList(dbClient.study, filter.toLowerCase());
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
      var amount = await dbClient.tableLength(table: _study[i]);
      _tables.add(StudyStack(_study[i], amount));
    }

    setState(() {
      if (_tables.isNotEmpty) {
        study = featuredStudy(_tables);
        cards = featuredCards(_tables);
      } else {
        study = 'Start studying';
        cards = '0';
      }
      featured = _tables;
    });
  }

  initUser() {
    var _name = getFromDisk('profile_name') ?? 'Student';
    var _photo = getFromDisk('profile_photo');

    var _tag = getFromDisk('lang_tag') ?? 'en';
    var _subtag = getFromDisk('lang_subtag') ?? 'UK';

    var _color = getFromDisk('theme_color') ?? 0;

    setState(() {
      user = User(_name, _photo);
      language = Language(_tag, _subtag);
      profile = imageFromBase64String(user.photoUrl);
      primaryColor = getThemeColor(_color, Theme.of(context).brightness);
      AppLocalization.load(Locale(_tag, _subtag));
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
