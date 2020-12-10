import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({Key key, this.title = 'MY LIST'})
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
      automaticallyImplyLeading: false, // Don't show the leading button
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            child: Icon(
              Icons.notifications_none,
              color: AppColors.getAppBarColor(isDark),
              size: 24,
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            child: Icon(
              AppIcons.search,
              color: AppColors.getAppBarColor(isDark),
              size: 24,
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            child: Icon(
              Icons.filter_list_alt,
              color: AppColors.getAppBarColor(isDark),
              size: 24,
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.15),
          Container(
              child: Text(widget.title,
                  style: TextStyle(
                    color: AppColors.getAppBarColor(isDark),
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  )))
        ],
      ),
      // leadingWidth: MediaQuery.of(context).size.width * 0.5,
      // leading: Row(
      //   children: [

      //   ],
      // ),
      actions: <Widget>[
        //   FlatButton(
        //     onPressed: () => Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => AddPrayer(
        //           isEdit: false,
        //         ),
        //       ),
        //     ),
        //     child: Text(
        //       "ADD A PRAYER",
        //       style: AppTextStyles.boldText20.copyWith(
        //         color: AppColors.getAppBarColor(isDark),
        //       ),
        //     ),
        //   ),
        //   FlatButton(
        //     onPressed: () =>
        //         Navigator.of(context).pushReplacementNamed(PrayerMode.routeName),
        //     child: Text(
        //       "PRAY",
        //       style: AppTextStyles.boldText20.copyWith(
        //         color: AppColors.getAppBarColor(isDark),
        //       ),
        //     ),
        //   ),
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
