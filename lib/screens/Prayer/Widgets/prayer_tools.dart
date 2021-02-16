import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/menu-button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrayerFilters extends StatefulWidget {
  @override
  _PrayerFiltersState createState() => _PrayerFiltersState();
}

class _PrayerFiltersState extends State<PrayerFilters> {
  String status;
  bool isSnoozed;
  bool isAnswered;
  bool isArchived;

  Widget build(BuildContext context) {
    var filterOptions = Provider.of<PrayerProvider>(context).filterOptions;
    status = filterOptions.status;
    isSnoozed = filterOptions.isSnoozed;
    isAnswered = filterOptions.isAnswered;
    isArchived = filterOptions.isArchived;
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: FlatButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(AppIcons.bestill_back_arrow,
                  color: AppColors.lightBlue3),
              label: Text(
                'BACK',
                style: TextStyle(
                  color: AppColors.lightBlue3,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'VIEW',
                        style: AppTextStyles.boldText18
                            .copyWith(color: AppColors.lightBlue3),
                      ),
                      SizedBox(height: 15),
                      MenuButton(
                        isActive: filterOptions.status == Status.active,
                        onPressed: () => setState(
                          () {
                            status = status == Status.active
                                ? Status.inactive
                                : Status.active;
                            Provider.of<PrayerProvider>(context, listen: false)
                                .filterPrayers(
                              isAnswered: isAnswered,
                              isArchived: isArchived,
                              isSnoozed: isSnoozed,
                              status: status,
                            );
                          },
                        ),
                        text: Status.active.toUpperCase(),
                      ),
                      MenuButton(
                        isActive: filterOptions.isSnoozed == true,
                        onPressed: () => null,
                        // setState(
                        //   () async {
                        //     isSnoozed = !isSnoozed;
                        //     status = Status.inactive;
                        //     await Provider.of<PrayerProvider>(context,
                        //             listen: false)
                        //         .filterPrayers(
                        //       isAnswered: isAnswered,
                        //       isArchived: isArchived,
                        //       isSnoozed: isSnoozed,
                        //       status: status,
                        //     );
                        //   },
                        // );
                        text: 'SNOOZED',
                      ),
                      MenuButton(
                        isActive: filterOptions.isArchived == true,
                        onPressed: () => setState(
                          () async {
                            isArchived = !isArchived;
                            await Provider.of<PrayerProvider>(context,
                                    listen: false)
                                .filterPrayers(
                              isAnswered: isAnswered,
                              isArchived: isArchived,
                              isSnoozed: isSnoozed,
                              status: status,
                            );
                          },
                        ),
                        text: 'ARCHIVED',
                      ),
                      MenuButton(
                        isActive: filterOptions.isAnswered == true,
                        onPressed: () => setState(
                          () async {
                            isAnswered = !isAnswered;
                            await Provider.of<PrayerProvider>(context,
                                    listen: false)
                                .filterPrayers(
                                    isAnswered: isAnswered,
                                    isArchived: isArchived,
                                    isSnoozed: isSnoozed,
                                    status: status);
                          },
                        ),
                        text: 'ANSWERED',
                      ),
                      Provider.of<PrayerProvider>(context).currentPrayerType ==
                              PrayerType.group
                          ? MenuButton(
                              isActive: false,
                              onPressed: () => null,
                              text: 'GROUP SETTINGS',
                            )
                          : Container(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
