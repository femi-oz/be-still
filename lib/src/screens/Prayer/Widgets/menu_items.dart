import 'package:flutter/material.dart';
import 'package:be_still/src/widgets/Theme/app_theme.dart';

class PrayerMenuItem extends StatefulWidget {
  final Function action;
  final Function openTools;
  final bool isActive;
  final String title;
  PrayerMenuItem({
    this.action,
    this.title,
    this.openTools,
    this.isActive,
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
                  color: widget.isActive
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
                child: widget.isActive
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
