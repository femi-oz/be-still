import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class SettingsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  SettingsAppBar({this.title = 'SETTINGS', Key key})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  get provider => null;

  @override
  _SettingsAppBarState createState() => _SettingsAppBarState();
}

class _SettingsAppBarState extends State<SettingsAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Container(),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: AppColors.appBarBackground,
          ),
        ),
      ),
      title: Text(
        widget.title,
        style: TextStyle(
          color: AppColors.bottomNavIconColor,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.notifications_none,
                color: AppColors.white,
              ),
              onPressed: () => null,
            );
          },
        ),
      ],
    );
  }
}
