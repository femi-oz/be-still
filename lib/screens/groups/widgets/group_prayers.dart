import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/screens/add_prayer/add_prayer_screen.dart';
import 'package:be_still/screens/groups/widgets/group_quick_access.dart';
import 'package:be_still/screens/prayer/widgets/prayer_card.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupPrayers extends StatefulWidget {
  @override
  _GroupPrayersState createState() => _GroupPrayersState();
}

class _GroupPrayersState extends State<GroupPrayers> {
  Future<bool> _onWillPop() async {
    await Provider.of<MiscProvider>(context, listen: false)
        .setCurrentPage(0, 3);
    return (NavigationService.instance.goHome(0)) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<PrayerProvider>(context).filteredPrayers;
    final currentPrayerType =
        Provider.of<PrayerProvider>(context).currentPrayerType;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(),
        endDrawer: CustomDrawer(),
        body: Container(
          padding: EdgeInsets.only(left: 20),
          height: MediaQuery.of(context).size.height * 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundColor,
            ),
            image: DecorationImage(
              image: AssetImage(StringUtils.backgroundImage),
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
                                          .setPrayer(e.userPrayer.id);
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (context) =>
                                              new PrayerDetails(),
                                        ),
                                      );
                                    },
                                    onLongPressEnd:
                                        (LongPressEndDetails details) {
                                      var y = details.globalPosition.dy;
                                      showModalBottomSheet(
                                        context: context,
                                        barrierColor: AppColors.addPrayerBg
                                            .withOpacity(0.5),
                                        backgroundColor: AppColors.addPrayerBg
                                            .withOpacity(0.9),
                                        isScrollControlled: true,
                                        builder: (BuildContext context) {
                                          return GroupPrayerQuickAccess(
                                              y: y, prayer: e);
                                        },
                                      );
                                    },
                                    child: PrayerCard(
                                      prayerData: e,
                                      timeago: '',
                                    )))
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
                                AddPrayer(isEdit: false, isGroup: true),
                          ),
                        ),
                        text: 'Add New Prayer',
                        backgroundColor: Settings.isDarkMode
                            ? AppColors.backgroundColor[1]
                            : AppColors.lightBlue3,
                        textColor: Settings.isDarkMode
                            ? AppColors.lightBlue3
                            : Colors.white,
                        icon: AppIcons.bestill_add,
                      ),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
