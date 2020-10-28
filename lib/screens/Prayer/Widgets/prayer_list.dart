import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../add_prayer/add_prayer_screen.dart';
import 'prayer_card.dart';
import 'package:be_still/utils/app_theme.dart';

class PrayerList extends StatelessWidget {
  final activeList;
  final List<PrayerModel> prayers;
  final GroupModel group;

  @override
  PrayerList({this.activeList, this.prayers, this.group});
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
                    'You don\'t have any prayer in your List.',
                    style: AppTextStyles.regularText13,
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: <Widget>[
                    ...prayers
                        .map(
                          (p) => PrayerCard(prayer: p, activeList: activeList),
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
                  group: group,
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
                      ? context.brightBlue2.withOpacity(0.8) //TODO
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
                    icon: Icon(Icons.add, color: AppColors.offWhite4),
                    label: Text(
                      'Add New Prayer',
                      style: AppTextStyles.boldText20.copyWith(
                        color: AppColors.offWhite4,
                      ),
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
