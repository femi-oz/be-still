import 'package:be_still/Data/group.data.dart';
import 'package:be_still/Data/prayer.data.dart';
import 'package:be_still/Providers/app_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/prayer_card.dart';
import 'package:be_still/screens/PrayerDetails/Widgets/other_member_prayer_menu.dart';
import 'package:be_still/screens/PrayerDetails/Widgets/update_view.dart';
import 'package:be_still/widgets/Theme/app_theme.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Widgets/group_admin_prayer_menu.dart';
import 'Widgets/no_update_view.dart';
import 'Widgets/prayer_menu.dart';

class PrayerDetails extends StatelessWidget {
  static const routeName = '/prayer-details';
  @override
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);
    final RouteArguments args = ModalRoute.of(context).settings.arguments;
    final prayer = prayerData.singleWhere((prayer) => prayer.id == args.id);
    final isUserPrayer =
        args.groupId.toString() == 'null' || prayer.user == _app.user.id;
    final isGroupAdmin = args.groupId.toString() == 'null'
        ? false
        : groupData.singleWhere((g) => g.id == args.groupId.toString()).admin ==
                _app.user.id
            ? true
            : false;
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.mainBgStart,
              context.mainBgEnd,
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton.icon(
                    padding: EdgeInsets.all(0),
                    icon: Icon(
                      Icons.arrow_back,
                      color: context.toolsBackBtn,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    label: Text(
                      'BACK',
                      style: TextStyle(
                        color: context.toolsBackBtn,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  prayer.hasReminder
                      ? Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: context.toolsBackBtn,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Text(
                                prayer.reminder,
                                style: TextStyle(
                                  color: context.toolsBackBtn,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.prayerDetailsCardStart,
                      context.prayerDetailsCardEnd,
                    ],
                  ),
                  border: Border.all(
                    color: context.prayerDetailsCardBorder,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: prayer.updates.length > 0
                    ? UpdateView(prayer)
                    : NoUpdateView(prayer),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: context.brightBlue,
              ),
              onPressed: () => showModalBottomSheet(
                context: context,
                barrierColor: context.toolsBg.withOpacity(0.5),
                backgroundColor: context.toolsBg.withOpacity(0.9),
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return isUserPrayer
                      ? PrayerMenu(prayer)
                      : prayer.isAddedFromGroup && isGroupAdmin
                          ? GroupAdminPrayerMenu(prayer)
                          : prayer.isAddedFromGroup && !isGroupAdmin
                              ? OtherMemberPrayerMenu(prayer)
                              : Container();
                },
              ),
            ),
          ],
        ),
      ),
      endDrawer: CustomDrawer(),
    );
  }
}
