import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../add_prayer/add_prayer_screen.dart';
import 'prayer_card.dart';

class PrayerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final data = Provider.of<PrayerProvider>(context).filteredPrayers;
    final currentPrayerType =
        Provider.of<PrayerProvider>(context).currentPrayerType;
    return Container(
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
                    padding: EdgeInsets.only(
                      top: 20,
                      left: 20,
                      bottom: 80,
                    ),
                    child: Column(
                      children: <Widget>[
                        ...data
                            .map((e) => PrayerCard(prayer: e.prayer))
                            .toList(),
                      ],
                    ),
                  ),
            // currentPrayerType == PrayerType.archived ||
            //         currentPrayerType == PrayerType.answered
            //     ? Container()
            //     : InkWell(
            //         onTap: () => Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => AddPrayer(isEdit: false),
            //           ),
            //         ),
            //         child: Container(
            //           width: double.infinity,
            //           margin: EdgeInsets.only(top: 10),
            //           decoration: BoxDecoration(
            //             color: AppColors.darkBlue,
            //             borderRadius: BorderRadius.only(
            //               bottomLeft: Radius.circular(10),
            //               topLeft: Radius.circular(10),
            //             ),
            //           ),
            //           child: Container(
            //             width: double.infinity,
            //             margin: EdgeInsetsDirectional.only(
            //                 start: 1, bottom: 1, top: 1),
            //             decoration: BoxDecoration(
            //               color: _themeProvider.isDarkModeEnabled
            //                   ? AppColors.lightBlue3.withOpacity(0.8)
            //                   : AppColors.lightBlue3,
            //               borderRadius: BorderRadius.only(
            //                 bottomLeft: Radius.circular(9),
            //                 topLeft: Radius.circular(9),
            //               ),
            //             ),
            //             child: Align(
            //               alignment: Alignment.centerLeft,
            //               child: FlatButton.icon(
            //                 onPressed: null,
            //                 icon: Icon(Icons.add, color: AppColors.offWhite4),
            //                 label: Text(
            //                   'Add New Prayer',
            //                   style: AppTextStyles.boldText20.copyWith(
            //                     color: AppColors.offWhite4,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
          ],
        ),
      ),
    );
  }
}
