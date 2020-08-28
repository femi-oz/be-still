import 'package:be_still/src/screens/AddPrayer/add_prayer_screen.dart';
import 'package:be_still/src/screens/PrayMode/pray_mode_screen.dart';
import 'package:be_still/src/widgets/Theme/app_theme.dart';
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
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: context.appBarInactive,
              size: 24,
            ),
            onPressed: () => null,
          );
        },
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
                Icons.menu,
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
