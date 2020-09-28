import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/user_prayer.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../add_prayer/add_prayer_screen.dart';
import 'prayer_card.dart';
import 'package:be_still/utils/app_theme.dart';

class PrayerList extends StatelessWidget {
  final activeList;
  final List<CombinePrayerStream> prayers;
  final groupId;

  @override
  PrayerList({this.activeList, this.groupId, this.prayers});
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        bottom: 200,
      ),
      child: Column(
        children: <Widget>[
          prayers.length < 1
              ? Container(
                  padding: EdgeInsets.all(60),
                  child: Text(
                    'No Prayers in My List',
                    style: TextStyle(
                      color: context.prayerNotAvailable,
                      fontSize: 36,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: <Widget>[
                    ...prayers
                        .map(
                          (p) => PrayerCard(p.prayer, activeList),
                        )
                        .toList(),
                  ],
                ),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPrayer(
                  isEdit: false,
                  isGroup: activeList == PrayerActiveScreen.group,
                  groupId: groupId,
                ),
              ),
            ),
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: context.prayerCardBorder,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              child: Container(
                width: double.infinity,
                margin: EdgeInsetsDirectional.only(start: 1, bottom: 1, top: 1),
                decoration: BoxDecoration(
                  color: _themeProvider.isDarkModeEnabled
                      ? context.mainBgStart.withOpacity(0.8)
                      : context.brightBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(9),
                    topLeft: Radius.circular(9),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FlatButton.icon(
                    onPressed: null,
                    icon: Icon(Icons.add,
                        color: !_themeProvider.isDarkModeEnabled
                            ? Colors.white
                            : context.brightBlue),
                    label: Text(
                      'Add New Prayer',
                      style: TextStyle(
                          color: !_themeProvider.isDarkModeEnabled
                              ? Colors.white
                              : context.brightBlue,
                          fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
