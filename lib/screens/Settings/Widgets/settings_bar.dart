import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
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
    // List<PushNotificationModel> notifications =
    //     Provider.of<NotificationProvider>(context).notifications;
    return AppBar(
      title: Text(widget.title,
          style: AppTextStyles.boldText28.copyWith(
              height: 1.5,
              color:
                  Settings.isDarkMode ? AppColors.darkBlue3 : AppColors.grey2)),
      centerTitle: true,
      leading: InkWell(
          onTap: () => null,
          // Navigator.of(context).pushNamed(NotificationsScreen.routeName),
          child:
              // notifications.length == 0
              //     ?
              Icon(
            AppIcons.bestill_notifications,
            color: AppColors.grey,
            size: 18,
          )
          // : Stack(
          //     alignment: Alignment.center,
          //     children: [
          //       Icon(
          //         AppIcons.bestill_notifications,
          //         color: AppColors.red,
          //         size: 18,
          //       ),
          //       Text(
          //         notifications.length.toString(),
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 11,
          //         ),
          //         textAlign: TextAlign.center,
          //       ),
          //     ],
          //   ),
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
