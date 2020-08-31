import 'package:be_still/src/Models/prayer.model.dart';
import 'package:be_still/src/screens/PrayMode/Widgets/no_update_view.dart';
import 'package:be_still/src/screens/PrayMode/Widgets/update_view.dart';
import 'package:flutter/material.dart';
import './../../../../src/widgets/Theme/app_theme.dart';

class PrayerPage extends StatelessWidget {
  final PrayerModel prayer;

  PrayerPage(this.prayer);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      color: context.prayModeBg,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child:  prayer.updates.length > 0
                ? UpdateView(prayer)
                : NoUpdateView(prayer),
        ),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.84,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.prayModeCardBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
