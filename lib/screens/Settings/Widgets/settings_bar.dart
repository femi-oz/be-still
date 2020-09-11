import 'package:be_still/data/notification.data.dart';
import 'package:be_still/providers/app_provider.dart';
import 'package:be_still/screens/notifications/notifications_screen.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/utils/app_icons.dart';
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
            color: context.settingsTitle,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          )),
      centerTitle: true,
      leading: notificationData.length > 0
          ? FlatButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                barrierColor: context.toolsBg,
                backgroundColor: context.toolsBg,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return MultiProvider(providers: [
                    ChangeNotifierProvider(create: (ctx) => AppProvider()),
                  ], child: NotificationsScreen());
                },
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Icon(
                    Icons.notifications,
                    color: context.prayerCardTags,
                  ),
                  Container(
                    child: Text(
                      notificationData.length.toString(),
                      style: TextStyle(fontSize: 5, color: Colors.white),
                    ),
                  )
                ],
              ),
            )
          : IconButton(
              icon: Icon(
                Icons.notifications_none,
                color: context.appBarInactive,
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
                color: context.appBarActive,
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
