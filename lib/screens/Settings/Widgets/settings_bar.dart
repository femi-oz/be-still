import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:flutter/material.dart';

class SettingsAppBar extends StatefulWidget implements PreferredSizeWidget {
  SettingsAppBar({Key key})
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
      title: Text('SETTINGS',
          style: AppTextStyles.boldText28.copyWith(
              color:
                  Settings.isDarkMode ? AppColors.darkBlue3 : AppColors.grey2)),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          AppIcons.bestill_notifications,
          color: AppColors.grey,
          size: 24,
        ),
        onPressed: null,
      ),
      actions: <Widget>[
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                AppIcons.bestill_main_menu,
                color: AppColors.grey,
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
