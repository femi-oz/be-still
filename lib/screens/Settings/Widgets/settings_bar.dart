import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          style: TextStyle(
            color: Settings.isDarkMode ? AppColors.darkBlue3 : AppColors.grey2,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          )),
      centerTitle: true,
      leading:
          // TODO
          //notificationData.length > 0
          //     ? FlatButton(
          //         onPressed: () => showModalBottomSheet(
          //           context: context,
          //           barrierColor: AppColors.detailBackgroundColor,
          //           backgroundColor: AppColors.detailBackgroundColor,
          //           isScrollControlled: true,
          //           builder: (BuildContext context) {
          //             return MultiProvider(providers: [
          //               ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
          //             ], child: NotificationsScreen());
          //           },
          //         ),
          //         child: Stack(
          //           alignment: Alignment.center,
          //           children: <Widget>[
          //             Icon(
          //               Icons.notifications,
          //               color: AppColors.red,
          //             ),
          //             Container(
          //               child: Text(
          //                 notificationData.length.toString(),
          //                 style: TextStyle(fontSize: 5, color: Colors.white),
          //               ),
          //             )
          //           ],
          //         ),
          //       )
          // :
          IconButton(
        icon: Icon(
          Icons.notifications_none,
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
                AppIcons.menu,
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
