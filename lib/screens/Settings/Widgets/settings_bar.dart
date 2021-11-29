import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/screens/notifications/notifications_screen.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final notifications =
        Provider.of<NotificationProvider>(context).notifications;
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
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
      centerTitle: true,
      actions: <Widget>[
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationsScreen(),
            ),
          ),
          child: Container(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                        notifications.length != 0
                            ? Icons.notifications
                            : Icons.notifications_none,
                        size: 30,
                        color: notifications.length != 0
                            ? AppColors.red
                            : AppColors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsScreen(),
                      ),
                    ),
                  ),
                  notifications.length != 0
                      ? Padding(
                          padding: EdgeInsets.only(
                              right: notifications.length == 1
                                  ? 2
                                  : notifications.length > 9
                                      ? 1
                                      : 0),
                          child: Text(notifications.length.toString(),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600)),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
