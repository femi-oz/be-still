import 'package:be_still/src/Data/group.data.dart';
import 'package:be_still/src/Enums/prayer_list.enum.dart';
import 'package:be_still/src/Models/prayer.model.dart';
import 'package:be_still/src/Providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Data/prayer.data.dart';
import '../../AddPrayer/add_prayer_screen.dart';
import 'prayer_card.dart';
import 'package:be_still/src/widgets/Theme/app_theme.dart';

class PrayerList extends StatelessWidget {
  final activeList;
  final searchParam;
  final groupId;

  @override
  PrayerList(this.activeList, this.groupId, this.searchParam);
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);
    final List<PrayerModel> emptyList = [];
    var prayers = activeList == PrayerListType.personal
        ? prayerData.where(
            (p) => _app.user.prayerList.contains(p.id) && p.status == 'active')
        : activeList == PrayerListType.archived
            ? prayerData.where((p) =>
                _app.user.prayerList.contains(p.id) && p.status == 'archived')
            : activeList == PrayerListType.answered
                ? prayerData.where((p) =>
                    _app.user.prayerList.contains(p.id) &&
                    p.status == 'answered')
                : activeList == PrayerListType.group
                    ? prayerData.where((p) => GROUP_DATA
                        .singleWhere((g) => g.id == groupId)
                        .prayerList
                        .contains(p.id))
                    : emptyList;

    var filteredPrayers =
        prayers.where((p) => p.content.contains(searchParam.text));
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        bottom: 200,
      ),
      child: Column(
        children: <Widget>[
          filteredPrayers.length < 1
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
                    ...filteredPrayers
                        .map(
                          (p) => PrayerCard(p, groupId, activeList),
                        )
                        .toList(),
                  ],
                ),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(
              AddPrayer.routeName,
              arguments: AddRouteArguments(false, null),
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
                  color: _app.isDarkModeEnabled
                      ? context.mainBgStart.withOpacity(0.8)
                      : context.brightBlue,
                  // border: Border.all(
                  //   color: !_app.isDarkModeEnabled
                  //       ? Colors.transparent
                  //       : context.brightBlue,
                  // ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(9),
                    topLeft: Radius.circular(9),
                  ),
                  // borderRadius: BorderRadius.circular(9),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FlatButton.icon(
                    onPressed: null,
                    icon: Icon(Icons.add,
                        color: !_app.isDarkModeEnabled
                            ? Colors.white
                            : context.brightBlue),
                    label: Text(
                      'Add New Prayer',
                      style: TextStyle(
                          color: !_app.isDarkModeEnabled
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
