import 'package:be_still/data/user.data.dart';
import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/screens/prayer/Widgets/prayer_quick_acccess.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'group_quick_access.dart';

class PrayerCard extends StatelessWidget {
  final PrayerModel prayer;

  final groupId;

  final activeList;

  PrayerCard(this.prayer, this.groupId, this.activeList);
  @override
  Widget build(BuildContext context) {
    final _currentUser = Provider.of<UserProvider>(context).currentUser;
    return GestureDetector(
      onLongPressEnd: (LongPressEndDetails details) {
        var y = details.globalPosition.dy;
        showModalBottomSheet(
          context: context,
          barrierColor: context.prayerMenuStart.withOpacity(0.3),
          backgroundColor: context.prayerMenuStart.withOpacity(0.5),
          isScrollControlled: true,
          builder: (BuildContext context) {
            return (prayer.userId == _currentUser.id)
                // &&
                //         activeList != PrayerActiveScreen.personal)
                ? PrayerQuickAccess(y: y, prayer: prayer)
                : GroupPrayerQuickAccess(y: y, prayer: prayer);
          },
        );
      },
      onTap: () {
        Navigator.of(context).pushNamed(
          PrayerDetails.routeName,
          arguments: RouteArguments(
            prayer.id,
            groupId,
          ),
        );
        print(groupId);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          color: context.prayerCardBorder,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        child: Container(
          margin: EdgeInsetsDirectional.only(start: 1, bottom: 1, top: 1),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.prayerCardBg,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(9),
              topLeft: Radius.circular(9),
            ),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        // TODO
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            prayer.userId != _currentUser.id
                                ? Text(
                                    prayer.createdBy,
                                    style: TextStyle(
                                      color: context.brightBlue,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  )
                                : Container(),
                            Row(
                              children: <Widget>[
                                // prayer.hasReminder
                                //     ? Row(
                                //         children: <Widget>[
                                //           Icon(
                                //             Icons.calendar_today,
                                //             size: 12,
                                //             color: context.prayerReminderIcon,
                                //           ),
                                //           Container(
                                //             margin: EdgeInsets.symmetric(
                                //               horizontal: 10,
                                //             ),
                                //             child: Text(
                                //               '|',
                                //               style: TextStyle(
                                //                 color: context.prayerCardBorder,
                                //                 fontSize: 10,
                                //               ),
                                //             ),
                                //           )
                                //         ],
                                //       )
                                //     : Container(),
                                // Row(
                                //   children: prayer.tags.map((tag) {
                                //     return Text(
                                //       tag.toUpperCase(),
                                //       style: TextStyle(
                                //         color: context.prayerCardTags,
                                //         fontSize: 10,
                                //       ),
                                //     );
                                //   }).toList(),
                                // ),
                                // prayer.tags.length > 0
                                //     ? Container(
                                //         margin: EdgeInsets.symmetric(
                                //           horizontal: 10,
                                //         ),
                                //         child: Text(
                                //           '|',
                                //           style: TextStyle(
                                //               color: context.prayerCardBorder),
                                //         ),
                                //       )
                                //     : Container(),
                                Text(
                                  DateFormat('MM.dd.yyyy')
                                      .format(prayer.createdOn),
                                  style: TextStyle(
                                    color: context.prayerCardPrayer,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                color: context.prayerDivider,
                thickness: 0.5,
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      prayer.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.prayerCardPrayer,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RouteArguments {
  final String id;
  final String groupId;

  RouteArguments(this.id, this.groupId);
}
