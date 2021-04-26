import 'package:be_still/screens/Settings/Widgets/settings_bar.dart';
import 'package:be_still/screens/grow_my_prayer_life/devotion_and_reading_plans.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class GrowMyPrayerLifeScreen extends StatefulWidget {
  static const routeName = 'grow-prayer';

  @override
  _GrowMyPrayerLifeScreenState createState() => _GrowMyPrayerLifeScreenState();
}

class _GrowMyPrayerLifeScreenState extends State<GrowMyPrayerLifeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SettingsAppBar(title: ''),
      endDrawer: CustomDrawer(),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
          image: DecorationImage(
            image: AssetImage(StringUtils.backgroundImage()),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Grow My Prayer Life',
                      style: AppTextStyles.boldText28
                          .copyWith(color: AppColors.blueTitle),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text(
                        'Prayer is a conversation with God. The primary way God speaks to us is through his written Word, the Bible. ',
                        style: AppTextStyles.regularText16b
                            .copyWith(color: AppColors.prayerTextColor),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text(
                        'The first step in growing your prayer life is to learn God’s voice through reading his Word. Selecting the correct translation of the Bible is important to understanding what God is saying to you.',
                        style: AppTextStyles.regularText16b
                            .copyWith(color: AppColors.prayerTextColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            child: DevotionPlans(),
                          ),
                        ),
                        // Navigator.of(context)
                        //     .pushNamed(DevotionPlans.routeName);

                        child: Text(
                          'DEVOTIONALS & READING PLANS',
                          style: AppTextStyles.boldText20
                              .copyWith(color: AppColors.lightBlue4),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
