import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/screens/grow_my_prayer_life/devotion_and_reading_plans.dart';
import 'package:be_still/screens/grow_my_prayer_life/recommended_bibles_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class GrowMyPrayerLifeScreen extends StatefulWidget {
  static const routeName = 'grow-prayer';

  @override
  _GrowMyPrayerLifeScreenState createState() => _GrowMyPrayerLifeScreenState();
}

class _GrowMyPrayerLifeScreenState extends State<GrowMyPrayerLifeScreen> {
  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<MiscProvider>(context, listen: false).setPageTitle('');
      _getDevotionals();
    });
    super.didChangeDependencies();
  }

  _getDevotionals() async {
    await BeStilDialog.showLoading(context, '');
    try {
      await Provider.of<DevotionalProvider>(context, listen: false)
          .getDevotionals();
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
        ),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.835,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(StringUtils.backgroundImage()),
                alignment: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 30),
                Row(
                  children: [
                    SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Container(
                        //   child: GestureDetector(
                        //     onTap: () => Navigator.pushReplacement(
                        //       context,
                        //       PageTransition(
                        //         type: PageTransitionType.leftToRightWithFade,
                        //         child: RecommenededBibles(),
                        //       ),
                        //     ),
                        //     // Navigator.of(context)
                        //     //     .pushNamed(RecommenededBibles.routeName);

                        //     child: Text(
                        //       'RECOMMENDED BIBLES',
                        //       style: AppTextStyles.boldText20
                        //           .copyWith(color: AppColors.lightBlue4),
                        //       textAlign: TextAlign.left,
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: 30),
                        Container(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              PageTransition(
                                type: PageTransitionType.leftToRightWithFade,
                                child: DevotionPlans(),
                              ),
                            ),
                            // Navigator.of(context)
                            //     .pushNamed(DevotionPlans.routeName);

                            child: Text(
                              'DEVOTIONALS & READING PLANS',
                              style: AppTextStyles.boldText20
                                  .copyWith(color: AppColors.lightBlue4),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        // SizedBox(height: 30),
                        // Container(
                        //   child: GestureDetector(
                        //     onTap: () => null,
                        //     child: Text(
                        //       'MY PRAYER GOALS',
                        //       style: AppTextStyles.boldText20
                        //           .copyWith(color: AppColors.lightBlue4),
                        //       textAlign: TextAlign.left,
                        //     ),
                        //   ),
                        // ),
                      ],
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
