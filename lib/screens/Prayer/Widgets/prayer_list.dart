import 'package:be_still/Models/prayer.model.dart';
import 'package:be_still/Providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../add_prayer/add_prayer_screen.dart';
import 'prayer_card.dart';
import 'package:be_still/widgets/Theme/app_theme.dart';

class PrayerList extends StatelessWidget {
  final activeList;
  final List<PrayerModel> prayers;
  final groupId;

  @override
  PrayerList({this.activeList, this.groupId, this.prayers});
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);

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
