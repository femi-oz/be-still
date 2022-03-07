
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/models/v2/update.model.dart';
import 'package:be_still/screens/prayer_time/Widgets/no_update_view.dart';
import 'package:be_still/screens/prayer_time/Widgets/update_view.dart';

import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class PrayerView extends StatelessWidget {
  final PrayerDataModel prayer;

  PrayerView(this.prayer);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: (prayer.updates ?? <UpdateModel>[]).length > 0 ? UpdateView(prayer) : NoUpdateView(prayer),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.84,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.textFieldBackgroundColor,
          border: Border.all(
            color: AppColors.prayerModeBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
