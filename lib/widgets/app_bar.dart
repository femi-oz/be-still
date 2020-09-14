import 'package:be_still/data/notification.data.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/pray_mode/pray_mode_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/screens/notifications/notifications_screen.dart';
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
    return AppBar(
      title: Text(''),
      leading: notificationData.length > 0
          ? FlatButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                barrierColor: context.toolsBg,
                backgroundColor: context.toolsBg,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return MultiProvider(providers: [
                    ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
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
        FlatButton(
          onPressed: () => Navigator.of(context).pushNamed(
            AddPrayer.routeName,
            arguments: AddRouteArguments(false, null),
          ),
          child: Text(
            "ADD A PRAYER",
            style: TextStyle(
              color: context.appBarActive,
              fontSize: 16,
            ),
          ),
        ),
        FlatButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(PrayerMode.routeName),
          child: Text(
            "PRAY",
            style: TextStyle(
              color: context.appBarActive,
              fontSize: 16,
            ),
          ),
        ),
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                AppIcons.menu,
                color: context.appBarActive,
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
