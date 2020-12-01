import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/screens/prayer/Widgets/prayer_quick_acccess.dart';
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'group_quick_access.dart';

class PrayerCard extends StatelessWidget {
  final PrayerModel prayer;

  PrayerCard({
    this.prayer,
  });
  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final _activeList = Provider.of<PrayerProvider>(context).currentPrayerType;
    return GestureDetector(
      onLongPressEnd: (LongPressEndDetails details) {
        var y = details.globalPosition.dy;
        showModalBottomSheet(
          context: context,
          barrierColor:
              AppColors.getPrayerMenu(_themeProvider.isDarkModeEnabled)[0]
                  .withOpacity(0.3),
          backgroundColor:
              AppColors.getPrayerMenu(_themeProvider.isDarkModeEnabled)[0]
                  .withOpacity(0.5),
          isScrollControlled: true,
          builder: (BuildContext context) {
            return (_activeList == PrayerType.group ||
                    (_activeList != PrayerType.group && prayer.groupId != '0'))
                ? GroupPrayerQuickAccess(y: y, prayer: prayer)
                : PrayerQuickAccess(y: y, prayer: prayer);
          },
        );
      },
      onTap: () async {
        await Provider.of<PrayerProvider>(context, listen: false)
            .setPrayer(prayer.id);
        await Provider.of<PrayerProvider>(context, listen: false)
            .setPrayerUpdates(prayer.id);
        // await Provider.of<GroupProvider>(context, listen: false)
        //     .setGroupUsers(prayer.groupId);
        Navigator.of(context).pushNamed(PrayerDetails.routeName);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 7.0),
        decoration: BoxDecoration(
          color: AppColors.getCardBorder(_themeProvider.isDarkModeEnabled),
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
            color: AppColors.getPrayerCardBgColor(
                _themeProvider.isDarkModeEnabled),
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
                            prayer.groupId != '0'
                                ? Text(
                                    prayer.creatorName,
                                    style: AppTextStyles.regularText14.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.lightBlue4,
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
                                //         color: AppColors.red,
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
                                  style: AppTextStyles.regularText16b.copyWith(
                                    fontSize: 14,
                                    color: AppColors.getPrayerMenuColor(
                                      !_themeProvider.isDarkModeEnabled,
                                    ),
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
                color: AppColors.getDivider(_themeProvider.isDarkModeEnabled),
                thickness: 0.5,
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      prayer.description.capitalize(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regularText18b.copyWith(
                        color: AppColors.getPrayerMenuColor(
                          !_themeProvider.isDarkModeEnabled,
                        ),
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
