import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stackr/animation/route_hero.dart';
import 'package:stackr/animation/tween_rectangle.dart';
import 'package:stackr/constants.dart';
import 'package:stackr/decoration/card_shadow.dart';
import 'package:stackr/locale/localization.dart';
import 'package:stackr/model/user_inherited.dart';
import 'package:stackr/widgets/textfield_platform.dart';

class ProfileSheet extends StatefulWidget {
  final Function callback;

  const ProfileSheet({Key key, this.callback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  File imageFile;

  Future selectImage(ImageSource source, UserDataState data) async {
    PickedFile pickedFile = await ImagePicker().getImage(source: source);

    final bytes = await pickedFile.readAsBytes();

    data.saveImage(data.base64String(bytes));

    widget.callback();
  }

  @override
  Widget build(BuildContext context) {
    final data = UserData.of(context);
    final brightness = Theme.of(context).brightness;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: sectionHeader(UserData.of(context).local.editPicHeader),
        ),
        itemPicture(data),
        sectionHeader(UserData.of(context).local.editNameHeader),
        itemName(data),
        sectionHeader(UserData.of(context).local.editThemeHeader),
        Container(height: 80.0, child: itemList(brightness)),
      ],
    );
  }

  Widget itemList(brightness) {
    return ListView.builder(
      itemCount: themeLightColor.length,
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          height: 60.0,
          width: 60.0,
          child: themeCard(index),
          decoration: CardDecoration(
            focus: true,
            radius: 10.0,
            color: brightness == Brightness.light
                ? themeLightColor[index]
                : themeDarkColor[index],
            brightness: brightness,
          ).shadow,
        );
      },
    );
  }

  Widget themeCard(int index) {
    var data = UserData.of(context);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          data.saveToDisk('theme_color', index);
          data.updateThemeColor();
        },
        child: Container(),
      ),
    );
  }

  Widget sectionHeader(var str) {
    final style =
        Theme.of(context).textTheme.headline2.copyWith(color: Colors.white);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
      child: Text(str, style: style),
    );
  }

  Widget itemPicture(UserDataState data) {
    AppLocalization loc = UserData.of(context).local;

    final camera = Icon(Icons.camera_alt);
    final gallery = Icon(Icons.image);

    List<Widget> items = [
      pictureType(loc.editPicCamera, camera, ImageSource.camera, data),
      pictureType(loc.editPicGallery, gallery, ImageSource.gallery, data),
    ];

    return Column(children: items);
  }

  Widget itemName(UserDataState data) {
    final _local = UserData.of(context).local;
    final style = Theme.of(context).textTheme.bodyText2;

    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: IconTheme(
          data: IconThemeData(color: Colors.white),
          child: Icon(Icons.person),
        ),
        title: Transform.translate(
          offset: Offset(-20, 0),
          child: Text(_local.editUsername,
              style: style.copyWith(color: Colors.white)),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          color: Colors.white54,
        ),
        onTap: () =>
            Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return EditNamePopup(function: widget.callback);
        })),
      ),
    );
  }

  Widget pictureType(var str, Icon icon, ImageSource src, UserDataState data) {
    final style =
        Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.white);

    return ListTile(
      leading: IconTheme(
        data: IconThemeData(color: Colors.white),
        child: icon,
      ),
      title: Transform.translate(
        offset: Offset(-20, 0),
        child: Text(str, style: style),
      ),
      trailing: Icon(
        Icons.keyboard_arrow_right,
        color: Colors.white54,
      ),
      onTap: () => selectImage(src, data),
    );
  }
}

class EditNamePopup extends StatelessWidget {
  static const int MAX_LEN = 40;

  final Function function;
  final nameCtrl = TextEditingController();

  EditNamePopup({Key key, @required this.function}) : super(key: key);

  void selectName(UserDataState data, BuildContext context) {
    if (nameCtrl.text.length <= MAX_LEN && nameCtrl.text.length > 0) {
      data.saveName(nameCtrl.text);
      function();
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment(0.0, -0.4),
      child: Hero(
        tag: 'edit_name_tween',
        createRectTween: (begin, end) => RectangleTween(begin: begin, end: end),
        child: Material(
          color: Theme.of(context).cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(15.0),
              margin: const EdgeInsets.all(20.0),
              height: 150.0,
              width: double.infinity,
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: _header(context, textTheme),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: _completeAction(context, textTheme),
                  ),
                  Align(
                    alignment: Alignment(0, 0.5),
                    child: _userTextField(context, textTheme),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(context, textTheme) {
    final _local = UserData.of(context).local;
    return Text(_local.editUsername, style: textTheme.headline2);
  }

  Widget _completeAction(context, textTheme) {
    final data = UserData.of(context);

    final text = Text('ok',
        style: textTheme.headline2.copyWith(color: data.primaryColor));

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(5.0),
        onTap: () => selectName(data, context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: text,
        ),
      ),
    );
  }

  Widget _userTextField(context, textTheme) {
    final _data = UserData.of(context);

    return TextFieldPlatform(
      controller: nameCtrl,
      hint: _data.user.name,
      maxLines: 1,
      maxLength: MAX_LEN,
    );
  }
}
