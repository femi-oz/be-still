import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:provider/provider.dart';

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
              Text(widget.title.capitalize(),
                  style: widget.isActive
                      ? AppTextStyles.boldText20
                      : AppTextStyles.boldText20.copyWith(
                          color: AppColors.getPrayerMenuColor(
                              Provider.of<ThemeProvider>(context)
                                  .isDarkModeEnabled))),
              Container(
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.all(0),
                height: 15,
                child: widget.isActive
                    ? IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          color: AppColors.lightBlue3,
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
