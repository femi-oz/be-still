import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/prayer/widgets/prayer_card.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupPrayers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final data = Provider.of<PrayerProvider>(context).filteredPrayers;
    final currentPrayerType =
        Provider.of<PrayerProvider>(context).currentPrayerType;
    return Container(
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.getBackgroudColor(_themeProvider.isDarkModeEnabled),
        ),
        image: DecorationImage(
          image: AssetImage(
              StringUtils.getBackgroundImage(_themeProvider.isDarkModeEnabled)),
          alignment: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            data.length == 0
                ? Container(
                    padding: EdgeInsets.all(60),
                    child: Text(
                      'You don\'t have any prayer in your List.',
                      style: AppTextStyles.regularText13,
                      textAlign: TextAlign.center,
                    ),
                  )
                : Container(
                    child: Column(
                      children: <Widget>[
                        ...data
                            .map((e) => GestureDetector(
                                onTap: () async {
                                  await Provider.of<PrayerProvider>(context,
                                          listen: false)
                                      .setPrayer(e.prayer.id);
                                  await Provider.of<PrayerProvider>(context,
                                          listen: false)
                                      .setPrayerUpdates(e.prayer.id);
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) => new PrayerDetails(),
                                    ),
                                  );
                                },
                                child: PrayerCard(prayer: e.prayer)))
                            .toList(),
                      ],
                    ),
                  ),
            currentPrayerType == PrayerType.archived ||
                    currentPrayerType == PrayerType.answered
                ? Container()
                : LongButton(
                    onPress: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddPrayer(isEdit: false, isGroup: false),
                      ),
                    ),
                    text: 'Add New Prayer',
                    backgroundColor: _themeProvider.isDarkModeEnabled
                        ? AppColors.getBackgroudColor(
                            _themeProvider.isDarkModeEnabled)[1]
                        : AppColors.lightBlue3,
                    textColor: _themeProvider.isDarkModeEnabled
                        ? AppColors.lightBlue3
                        : Colors.white,
                    icon: Icons.add,
                  ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
