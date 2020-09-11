import 'package:be_still/data/notification.data.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/pray_mode/pray_mode_screen.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:flutter/material.dart';

// import 'app_icons_icons.dart';

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
    return AppBar(
      title: Text(''),
      leading: IconButton(
        icon: Icon(
          Icons.close,
          color: context.inputFieldText,
          size: 24,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => null,
          child: Text(
            "CLEAR ALL",
            style: TextStyle(
              color: context.appBarActive,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.24),
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
