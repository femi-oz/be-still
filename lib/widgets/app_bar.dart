import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/pray_mode/pray_mode_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    bool isDark = Provider.of<ThemeProvider>(context).isDarkModeEnabled;
    return AppBar(
      backgroundColor: AppColors.appBarBg(isDark),
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
              ),
            ),
          ),
          child: Text(
            "ADD A PRAYER",
            style: AppTextStyles.boldText20.copyWith(
              color: AppColors.getAppBarColor(isDark),
            ),
          ),
        ),
        FlatButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(PrayerMode.routeName),
          child: Text(
            "PRAY",
            style: AppTextStyles.boldText20.copyWith(
              color: AppColors.getAppBarColor(isDark),
            ),
          ),
        ),
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                AppIcons.menu,
                color: AppColors.getAppBarColor(isDark),
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
