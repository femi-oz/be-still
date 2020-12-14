import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PrayerCard extends StatelessWidget {
  final PrayerModel prayer;

  PrayerCard({
    this.prayer,
  });
  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    // final _activeList = Provider.of<PrayerProvider>(context).currentPrayerType;
    final _user = Provider.of<UserProvider>(context).currentUser;
    return Container(
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
          color:
              AppColors.getPrayerCardBgColor(_themeProvider.isDarkModeEnabled),
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
                          prayer.userId != _user.id
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
                    prayer.description,
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
    );
  }
}
