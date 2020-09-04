import 'package:be_still/src/Enums/prayer_list.enum.dart';
import 'package:flutter/material.dart';
import 'package:be_still/src/widgets/Theme/app_theme.dart';

class PrayerMenuItem extends StatefulWidget {
  final Function action;
  final Function openTools;
  final bool showIcon;
  final bool showActiveColor;
  final String title;
  PrayerMenuItem({
    this.action,
    this.showIcon,
    this.title,
    this.openTools,
    this.showActiveColor,
  });
  @override
  _PrayerMenuItemState createState() => _PrayerMenuItemState();
}

class _PrayerMenuItemState extends State<PrayerMenuItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.action,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.showActiveColor
                      ? context.brightBlue
                      : context.prayerMenuInactive,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.all(0),
                height: 15,
                child: widget.showIcon
                    ? IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          color: context.brightBlue,
                        ),
                        padding: EdgeInsets.all(0),
                        onPressed: widget.openTools,
                      )
                    : Container(),
              ),
            ],
          ),
          SizedBox(width: 40.0),
        ],
      ),
    );
  }
}
