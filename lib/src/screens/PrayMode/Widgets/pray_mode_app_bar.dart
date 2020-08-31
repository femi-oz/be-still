import 'package:be_still/src/Data/prayer.data.dart';
import 'package:flutter/material.dart';
import '../../../widgets/Theme/app_theme.dart';

class PrayModeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final current;

  PrayModeAppBar({this.current, Key key})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _PrayModeAppBarState createState() => _PrayModeAppBarState();
}

class _PrayModeAppBarState extends State<PrayModeAppBar> {
  final totalPrayers = prayerData.length;
  @override
  Widget build(BuildContext context) {
    final current = widget.current;
    return Container(
      color: Theme.of(context).appBarTheme.color,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Container(
          child: Row(
            children: <Widget>[
              Text(
                '7:30 AM',
                style: TextStyle(color: context.brightBlue2, fontSize: 12),
              ),
            ],
          ),
        ),
        title: Text(
          '$current OF $totalPrayers',
          style: TextStyle(color: context.brightBlue2, fontSize: 12),
        ),
        actions: <Widget>[
          Row(
            children: <Widget>[
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: context.brightBlue2,
                      size: 24,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
