import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/pray_mode/pray_mode_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomAppBar({Key key})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(''),
      leading: IconButton(
        icon: Icon(
          Icons.notifications_none,
          color: AppColors.grey,
          size: 24,
        ),
        onPressed: null,
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPrayer(
                isEdit: false,
                isGroup: false,
              ),
            ),
          ),
          child: Text(
            "ADD A PRAYER",
            style: AppTextStyles.boldText20.copyWith(
              color: AppColors.getAppBarColor(true),
            ),
          ),
        ),
        FlatButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(PrayerMode.routeName),
          child: Text(
            "PRAY",
            style: AppTextStyles.boldText20.copyWith(
              color: AppColors.getAppBarColor(true),
            ),
          ),
        ),
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                AppIcons.menu,
                color: AppColors.getAppBarColor(true),
                // size: 24,
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
