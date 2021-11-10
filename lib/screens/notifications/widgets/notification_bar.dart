import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationBar extends StatefulWidget implements PreferredSizeWidget {
  final context;

  NotificationBar({Key key, this.context})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  NotificationBarState createState() => NotificationBarState();
}

class NotificationBarState extends State<NotificationBar> {
  @override
  Widget build(BuildContext context) {
    final data = Provider.of<NotificationProvider>(context).notifications;
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: AppColors.appBarBackground,
          ),
        ),
      ),
      centerTitle: true,
      title: data.length > 0
          ? TextButton(
              onPressed: () =>
                  Provider.of<NotificationProvider>(context, listen: false)
                      .clearNotification(),
              child: Text(
                "CLEAR ALL",
                style: AppTextStyles.boldText16
                    .copyWith(color: AppColors.bottomNavIconColor),
              ),
            )
          : Text('Notifications',
              style: AppTextStyles.boldText16
                  .copyWith(color: AppColors.bottomNavIconColor)),
      leading: IconButton(
        icon: Icon(
          AppIcons.bestill_close,
          color: AppColors.textFieldText,
          size: 24,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      // actions: <Widget>[
      //   ,
      //   SizedBox(width: MediaQuery.of(context).size.width * 0.4),
      // Builder(
      //   builder: (BuildContext context) {
      //     return IconButton(
      //       icon: Icon(
      //         AppIcons.bestill_main_menu,
      //         color: AppColors.bottomNavIconColor,
      //         size: 18,
      //       ),
      //       onPressed: () {
      //         Scaffold.of(context).openEndDrawer();
      //       },
      //     );
      //   },
      // ),
      // ],
    );
  }
}
