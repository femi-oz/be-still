import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/app_theme.dart';
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
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return AppBar(
      title: Text(''),
      leading: IconButton(
        icon: Icon(
          Icons.close,
          color: AppColors.getTextFieldText(_themeProvider.isDarkModeEnabled),
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
              color: AppColors.getAppBarColor(_themeProvider.isDarkModeEnabled),
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
                color:
                    AppColors.getAppBarColor(_themeProvider.isDarkModeEnabled),
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
