import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stackr/animation/tween_rectangle.dart';
import 'package:stackr/decoration/round_shadow.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/screens/sheet_dowload.dart';
import 'package:stackr/screens/sheet_information.dart';
import 'package:stackr/screens/sheet_profile.dart';
import 'package:stackr/widgets/appbar_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import '../constants.dart';
import '../model/user_inherited.dart';
import '../screens/sheet_language.dart';

const double _kSize = 425.0;
const Cubic _cScroll = Curves.easeIn;
const Duration _dScroll = Duration(milliseconds: 250);

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _temp;
  bool isEditing = false;

  ProfileSheet profileSheet;
  ScrollController _scrollCtrl;

  _editProfile() async {
    isEditing = !isEditing;

    var _pos = _scrollCtrl.offset < _kSize ? _kSize : 0.0;
    await _scrollCtrl.animateTo(_pos, duration: _dScroll, curve: _cScroll);

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

  void _setDarkMode(bool value) {
    final _client = UserData.of(context);

    Provider.of<ThemeState>(context, listen: false).theme =
        value ? ThemeType.DARK : ThemeType.LIGHT;
    _client.updateThemeColor();
  }

  void _enableNotification(bool value) {
    setState(() => _temp = value);
  }

  void _scrollListener() async {
    int dir = _scrollCtrl.position.userScrollDirection.index;
    double offset = _scrollCtrl.offset;

    if (offset < 0.0) {
      _scrollCtrl.jumpTo(0.0);
      return;
    }

    if (offset > _kSize) return;

    if (!isEditing && dir == ScrollDirection.forward.index) {
      _scrollCtrl.jumpTo(_kSize);
    }

    if (isEditing && dir == ScrollDirection.reverse.index) {
      isEditing = false;
      await _scrollCtrl.animateTo(_kSize, duration: _dScroll, curve: _cScroll);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _temp = false;
    _scrollCtrl = ScrollController(initialScrollOffset: _kSize);
    _scrollCtrl.addListener(() => _scrollListener());

    profileSheet = new ProfileSheet(key: UniqueKey(), callback: _editProfile);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _local = UserData.of(context).local;

    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;

    final _mode = Provider.of<ThemeState>(context).theme;

    List<Widget> _pref = [
      _sectionHeader(_local.preferencesHeader),
      _itemTile(_local.settingsLanguage, language, _changeLanguage),
      _itemSwitch(
          _local.settingsDark, dark, _mode == ThemeType.DARK, _setDarkMode)
    ];

    List<Widget> _dwnld = [
      _sectionHeader(_local.downloadHeader),
      _itemTile(_local.settingsDownload, download, _downloadStack),
    ];

    List<Widget> _notif = [
      _sectionHeader(_local.notificationHeader),
      _itemSwitch(
          _local.settingsNotification, notification, _temp, _enableNotification)
    ];

    List<Widget> _supp = [
      _sectionHeader(_local.supportHeader),
      _itemTile(_local.settingsTerms, terms, _termsOfUse),
      _itemTile(_local.settingsPrivacy, privacy, _privacyPolicy),
      _itemTile(_local.settingsHelp, help, _contactUs),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _theme.backgroundColor,
      appBar: PageAppBar(
        color: _theme.cardColor,
        height: 72.0,
        elevation: 7.5,
        title: _local.settingsHeader,
        textColor: _theme.textSelectionColor,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: _kSize,
                color: UserData.of(context).primaryColor,
                child: this.profileSheet,
              ),
              Container(
                color: _theme.backgroundColor,
                width: _width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Center(child: userProfile()),
                    ),
                    _section(_pref),
                    _section(_dwnld),
                    _section(_notif),
                    _section(_supp),
                    SizedBox(height: _height / 6),
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
    final _theme = Theme.of(context);
    final _client = UserData.of(context);

    var _name = Text(
      _client.user.name,
      style: Theme.of(context).textTheme.bodyText2,
    );

    var _image = Container(
      decoration: RoundShadow(
        focus: true,
        brightness: _theme.brightness,
      ).shadow,
      child: CircleAvatar(radius: 22.5, backgroundImage: _client.image),
    );

    var _profile = Align(
      alignment: Alignment(-0.8, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_image, const SizedBox(width: 15.0), _name],
      ),
    );

    var _edit = Align(
      alignment: Alignment(0.9, 0.0),
      child: Icon(Icons.edit, color: _client.primaryColor),
    );

    return Hero(
      tag: 'edit_name_tween',
      createRectTween: (begin, end) => RectangleTween(begin: begin, end: end),
      child: Container(
        height: 70.0,
        width: double.infinity,
        margin: const EdgeInsets.all(20.0),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => _editProfile(),
            child: Stack(children: [_edit, _profile]),
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        decoration: CardDecoration(
          radius: 20.0,
          brightness: Theme.of(context).brightness,
        ).shadow,
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
