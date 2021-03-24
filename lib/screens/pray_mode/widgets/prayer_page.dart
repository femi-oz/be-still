import 'package:be_still/models/prayer.model.dart';

import 'package:be_still/screens/pray_mode/Widgets/no_update_view.dart';
import 'package:be_still/screens/pray_mode/Widgets/update_view.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class PrayerView extends StatelessWidget {
  final CombinePrayerStream data;

  PrayerView(this.data);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: data.updates.length > 0 ? UpdateView(data) : NoUpdateView(data),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.84,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.prayeModeBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
