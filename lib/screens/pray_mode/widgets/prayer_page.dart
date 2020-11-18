import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/pray_mode/Widgets/no_update_view.dart';
import 'package:be_still/screens/pray_mode/Widgets/update_view.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../../../utils/app_theme.dart';

class PrayerPage extends StatelessWidget {
  final PrayerModel prayer;

  PrayerPage(this.prayer);
  @override
  Widget build(BuildContext context) {
    var _themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      color: AppColors.getPrayeModeBg(_themeProvider.isDarkModeEnabled),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        // TODO
        // child: prayer.updates.length > 0
        //     ? UpdateView(prayer)
        //     : NoUpdateView(prayer),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.84,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                AppColors.getPrayeModeBorder(_themeProvider.isDarkModeEnabled),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
