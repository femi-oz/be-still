import 'package:be_still/models/notification.model.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/screens/notifications/notifications_screen.dart';
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
    List<PushNotificationModel> notifications =
        Provider.of<NotificationProvider>(context).notifications;
    return AppBar(
      title: Text('SETTINGS',
          style: AppTextStyles.boldText28.copyWith(
              color:
                  Settings.isDarkMode ? AppColors.darkBlue3 : AppColors.grey2)),
      centerTitle: true,
      leading: InkWell(
          onTap: () => null,
          // Navigator.of(context).pushNamed(NotificationsScreen.routeName),
          child: Icon(
            Icons.notifications_none,
            color: AppColors.grey,
          )
          // onTap: () =>
          //     Navigator.of(context).pushNamed(NotificationsScreen.routeName),
          // child: notifications.length == 0
          //     ? Icon(
          //         AppIcons.bestill_notifications,
          //         color: AppColors.grey,
          //         size: 18,
          //       )
          //     : Stack(
          //         alignment: Alignment.center,
          //         children: [
          //           Icon(
          //             AppIcons.bestill_notifications,
          //             color: AppColors.red,
          //             size: 18,
          //           ),
          //           Text(
          //             notifications.length.toString(),
          //             style: TextStyle(
          //               color: Colors.white,
          //               fontSize: 11,
          //             ),
          //             textAlign: TextAlign.center,
          //           ),
          //         ],
          //       ),
          ),
      actions: <Widget>[
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                AppIcons.bestill_main_menu,
                color: AppColors.grey,
                size: 18,
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
