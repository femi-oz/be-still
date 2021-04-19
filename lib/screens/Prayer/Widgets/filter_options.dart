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
  // List<String> options = [];
  String errorMessage = '';
  void setOption(status) async {
    errorMessage = '';
    var settings =
        Provider.of<SettingsProvider>(context, listen: false).settings;

    // if (options.contains(status)) {
    //   if (options.length > 1)
    //     options.remove(status);
    //   else
    //     errorMessage = 'At least one filter must be selected';
    // } else {
    //   options.add(status);
    // }

    Provider.of<PrayerProvider>(context, listen: false)
        .setPrayerFilterOptions(status);
    Provider.of<PrayerProvider>(context, listen: false).filterPrayers();
    // if (status == Status.archived) {
    //   Provider.of<PrayerProvider>(context, listen: false)
    //       .filterPrayers();
    // } else {
    //   Provider.of<PrayerProvider>(context, listen: false)
    //       .filterPrayers(settings.defaultSortBy);
    // }
    String heading =
        // options.length > 1 || options.length == 0
        //     ? 'MY PRAYERS'
        //     :
        '${status == Status.active ? 'MY PRAYERS' : status.toUpperCase()}';
    await Provider.of<MiscProvider>(context, listen: false)
        .setPageTitle(heading);
    setState(() {});
    Navigator.of(context).pop();
  }

  Widget build(BuildContext context) {
    var status = Provider.of<PrayerProvider>(context).filterOption;
    return Container(
      padding: EdgeInsets.only(top: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  isActive: status == Status.all,
                  onPressed: () => setOption(Status.all),
                  text: Status.all.toUpperCase(),
                ),
                MenuButton(
                  isActive: status == Status.active,
                  onPressed: () => setOption(Status.active),
                  text: Status.active.toUpperCase(),
                ),
                MenuButton(
                  isActive: status == Status.snoozed,
                  onPressed: () => setOption(Status.snoozed),
                  text: Status.snoozed.toUpperCase(),
                ),
                MenuButton(
                  isActive: status == Status.archived,
                  onPressed: () => setOption(Status.archived),
                  text: Status.archived.toUpperCase(),
                ),
                MenuButton(
                  isActive: status == Status.answered,
                  onPressed: () => setOption(Status.answered),
                  text: Status.answered.toUpperCase(),
                ),
                SizedBox(height: 30),
                Text(
                  errorMessage,
                  style: AppTextStyles.regularText11
                      .copyWith(color: AppColors.red),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
