import 'package:be_still/src/widgets/Theme/app_theme.dart';
import 'package:be_still/src/widgets/app_icons_icons.dart';
import 'package:flutter/material.dart';

class SettingsAppBar extends StatefulWidget implements PreferredSizeWidget {
  SettingsAppBar({Key key})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _SettingsAppBarState createState() => _SettingsAppBarState();
}

class _SettingsAppBarState extends State<SettingsAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('SETTINGS',
          style: TextStyle(
            color: context.settingsTitle,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          )),
      centerTitle: true,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: context.appBarInactive,
              size: 24,
            ),
            onPressed: () => null,
          );
        },
      ),
      actions: <Widget>[
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                AppIcons.menu,
                color: context.appBarActive,
                size: 24,
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          },
        ),
      ],
    );
  }
}
