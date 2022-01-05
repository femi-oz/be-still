import 'package:be_still/enums/status.dart';
import 'package:be_still/providers/group_prayer_provider.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/menu-button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupPrayerFilters extends StatefulWidget {
  @override
  _GroupPrayerFiltersState createState() => _GroupPrayerFiltersState();
}

class _GroupPrayerFiltersState extends State<GroupPrayerFilters> {
  String errorMessage = '';
  void setOption(status) async {
    errorMessage = '';

    Provider.of<GroupPrayerProvider>(context, listen: false)
        .setPrayerFilterOptions(status);
    Provider.of<GroupPrayerProvider>(context, listen: false).filterPrayers();
    final group = Provider.of<GroupProvider>(context, listen: false)
        .currentGroup
        .group
        .name
        .toUpperCase();
    String heading =
        '${status == Status.active ? '$group (ACTIVE)' : "$group (${status.toUpperCase()})"}';
    await Provider.of<MiscProvider>(context, listen: false)
        .setPageTitle(heading);
    setState(() {});
    Navigator.of(context).pop();
  }

  Widget build(BuildContext context) {
    var status = Provider.of<GroupPrayerProvider>(context).filterOption;
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
                // MenuButton(
                //   isActive: status == Status.snoozed,
                //   onPressed: () => setOption(Status.snoozed),
                //   text: Status.snoozed.toUpperCase(),
                // ),
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
                // MenuButton(
                //   isActive: status == Status.following,
                //   onPressed: () => setOption(Status.following),
                //   text: Status.following.toUpperCase(),
                // ),
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
