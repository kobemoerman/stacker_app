import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackr/animation/tween_rectangle.dart';
import 'package:stackr/decoration/round_shadow.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/locale/localization.dart';
import 'package:stackr/screens/sheet_dowload.dart';
import 'package:stackr/screens/sheet_information.dart';
import 'package:stackr/screens/sheet_profile.dart';
import 'package:stackr/widgets/appbar_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import '../constants.dart';
import '../model/user_inherited.dart';
import '../screens/sheet_language.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const double SHEET_SIZE = 425;

  bool _temp;
  bool isEditing = false;

  ScrollController _scrollCtrl;

  ProfileSheet profileSheet;

  _editProfile() async {
    isEditing = !isEditing;

    var pos = _scrollCtrl.offset < SHEET_SIZE ? SHEET_SIZE : 0.0;

    await _scrollCtrl.animateTo(pos,
        duration: Duration(milliseconds: 250), curve: Curves.ease);

    profileSheet = new ProfileSheet(key: UniqueKey(), callback: _editProfile);

    setState(() {});
  }

  _contactUs(BuildContext context) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'studystackr@gmail.com',
      query: 'subject=Stackr Feedback&body=App Version 3.23',
    );

    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _termsOfUse(BuildContext context) {
    final _local = UserData.of(context).local;
    var header = _local.settingsTerms;
    var file = 'toc.txt';

    _displayInformation(context, header, file);
  }

  _privacyPolicy(BuildContext context) {
    final _local = UserData.of(context).local;
    var header = _local.settingsPrivacy;
    var file = 'privacy.txt';

    _displayInformation(context, header, file);
  }

  _displayInformation(context, header, file) {
    showBarModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InformationSheet(header: header, file: file),
    );
  }

  _downloadStack(BuildContext context) async {
    var list = await UserData.of(context).tables;
    showBarModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DownloadSheet(stacks: list),
    );
  }

  _changeLanguage(BuildContext context) {
    showBarModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSheet(),
    );
  }

  void darkMode(bool value) {
    Provider.of<ThemeState>(context, listen: false).theme =
        value ? ThemeType.DARK : ThemeType.LIGHT;

    UserData.of(context).updateThemeColor();
  }

  void enableNotification(bool value) {
    setState(() => _temp = value);
  }

  void _scrollListener() async {
    int dir = _scrollCtrl.position.userScrollDirection.index;
    double offset = _scrollCtrl.offset;

    if (offset < 0.0) {
      _scrollCtrl.jumpTo(0.0);
      return;
    }

    if (offset < SHEET_SIZE) {
      if (!isEditing && dir == ScrollDirection.forward.index) {
        _scrollCtrl.jumpTo(SHEET_SIZE);
      }

      if (isEditing && dir == ScrollDirection.reverse.index) {
        isEditing = false;
        await _scrollCtrl.animateTo(SHEET_SIZE,
            duration: Duration(milliseconds: 250), curve: Curves.ease);
      }

      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _temp = false;
    _scrollCtrl = ScrollController(initialScrollOffset: SHEET_SIZE);
    _scrollCtrl.addListener(() => _scrollListener());

    profileSheet = new ProfileSheet(key: UniqueKey(), callback: _editProfile);
  }

  @override
  Widget build(BuildContext context) {
    final _local = UserData.of(context).local;
    final _width = MediaQuery.of(context).size.width;

    List<Widget> _pref = [
      _sectionHeader(_local.preferencesHeader),
      _itemTile(_local.settingsLanguage, language, _changeLanguage),
      _itemSwitch(_local.settingsDark, dark,
          Provider.of<ThemeState>(context).theme == ThemeType.DARK, darkMode)
    ];

    List<Widget> _dwnld = [
      _sectionHeader(_local.downloadHeader),
      _itemTile(
          _local.settingsDownload, Icon(Icons.file_download), _downloadStack),
    ];

    List<Widget> _notif = [
      _sectionHeader(_local.notificationHeader),
      _itemSwitch(
          _local.settingsNotification, notification, _temp, enableNotification)
    ];

    List<Widget> _supp = [
      _sectionHeader(_local.supportHeader),
      _itemTile(_local.settingsTerms, terms, _termsOfUse),
      _itemTile(_local.settingsPrivacy, privacy, _privacyPolicy),
      _itemTile(_local.settingsHelp, help, _contactUs),
    ];

    return Scaffold(
      appBar: PageAppBar(
        color: Theme.of(context).cardColor,
        height: 72.0,
        elevation: 7.5,
        title: _local.settingsHeader,
        textColor: Theme.of(context).textSelectionColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: SHEET_SIZE,
                color: UserData.of(context).primaryColor,
                child: profileSheet,
              ),
              Container(
                color: Theme.of(context).backgroundColor,
                width: _width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20.0),
                    Center(child: userProfile()),
                    const SizedBox(height: 10.0),
                    _section(_pref),
                    _section(_dwnld),
                    _section(_notif),
                    _section(_supp),
                    SizedBox(height: MediaQuery.of(context).size.height / 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userProfile() {
    final data = UserData.of(context);

    var name = Text(
      data.user.name,
      style: Theme.of(context).textTheme.bodyText2,
    );

    var image = Container(
      decoration: RoundShadow(
        focus: true,
        brightness: Theme.of(context).brightness,
      ).shadow,
      child: CircleAvatar(
        radius: 22.5,
        backgroundImage: data.profile,
      ),
    );

    return Hero(
      tag: 'edit_name_tween',
      createRectTween: (begin, end) => RectangleTween(begin: begin, end: end),
      child: Container(
        height: 70.0,
        width: double.infinity,
        margin: const EdgeInsets.all(20.0),
        decoration: CardDecoration(
          radius: 20.0,
          brightness: Theme.of(context).brightness,
        ).shadow,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.0),
            onTap: () => _editProfile(),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment(0.9, 0.0),
                  child: Icon(Icons.edit, color: data.primaryColor),
                ),
                Align(
                  alignment: Alignment(-0.8, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      image,
                      const SizedBox(width: 15.0),
                      name,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Material _itemTile(var str, Icon icon, Function ontap) {
    final data = UserData.of(context);

    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: IconTheme(
          child: icon,
          data: IconThemeData(color: data.primaryColor),
        ),
        title: Transform.translate(
          offset: Offset(-20, 0),
          child: Text(str, style: Theme.of(context).textTheme.bodyText2),
        ),
        trailing: arrowRight,
        onTap: () => ontap(context),
      ),
    );
  }

  Widget _itemSwitch(var str, Icon icon, bool val, Function func) {
    final data = UserData.of(context);

    return SwitchListTile(
      title: Transform.translate(
        offset: Offset(-20, 0),
        child: Text(str, style: Theme.of(context).textTheme.bodyText2),
      ),
      secondary: IconTheme(
        child: icon,
        data: IconThemeData(color: data.primaryColor),
      ),
      value: val,
      activeColor: UserData.of(context).primaryColor,
      onChanged: (bool value) => func(value),
    );
  }

  Widget _sectionHeader(var str) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      child: Text(str, style: Theme.of(context).textTheme.headline2),
    );
  }

  Column _section(final List<Widget> c) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: c);
}
