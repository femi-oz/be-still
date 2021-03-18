import 'package:be_still/enums/status.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
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
  var options = [];

  void setOption(status) async {
    var settings = Provider.of<SettingsProvider>(context).settings;
    if (options.contains(status)) {
      if (options.length > 0) options.remove(status);
    } else {
      options.add(status);
      Provider.of<PrayerProvider>(context).setPrayerFilterOptions(options);
    }
    String heading = '';
    if (options.contains(Status.answered)) {
      heading = 'ANSWERED LIST';
      Provider.of<PrayerProvider>(context)
          .filterPrayers(sortBy: settings.defaultSortBy);
    }
    if (options.contains(Status.snoozed)) {
      heading = 'SNOOZED LIST';
      Provider.of<PrayerProvider>(context)
          .filterPrayers(sortBy: settings.defaultSortBy);
    }
    if (options.contains(Status.archived)) {
      heading = 'ARCHIVED LIST';
      Provider.of<PrayerProvider>(context)
          .filterPrayers(sortBy: settings.archiveSortBy);
    }
    if (options.contains(Status.active)) {
      heading = 'MY LIST';
      Provider.of<PrayerProvider>(context)
          .filterPrayers(sortBy: settings.defaultSortBy);
    }

    await Provider.of<MiscProvider>(context, listen: false)
        .setPageTitle(heading);
  }

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
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
                        isActive: options.contains(Status.active),
                        onPressed: () => setOption(Status.active),
                        text: Status.active.toUpperCase(),
                      ),
                      MenuButton(
                        isActive: options.contains(Status.snoozed),
                        onPressed: () => setOption(Status.snoozed),
                        text: Status.snoozed.toUpperCase(),
                      ),
                      MenuButton(
                        isActive: options.contains(Status.archived),
                        onPressed: () => setOption(Status.archived),
                        text: Status.archived.toUpperCase(),
                      ),
                      MenuButton(
                        isActive: options.contains(Status.answered),
                        onPressed: () => setOption(Status.answered),
                        text: Status.answered.toUpperCase(),
                      ),
                      // Provider.of<PrayerProvider>(context).currentPrayerType ==
                      //         PrayerType.group
                      //     ? MenuButton(
                      //         isActive: false,
                      //         onPressed: () => null,
                      //         text: 'GROUP SETTINGS',
                      //       )
                      //     : Container(),
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
