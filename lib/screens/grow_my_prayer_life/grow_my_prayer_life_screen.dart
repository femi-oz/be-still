import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/devotional_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/screens/grow_my_prayer_life/devotion_and_reading_plans.dart';
import 'package:be_still/screens/grow_my_prayer_life/recommended_bibles_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
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
      await Provider.of<MiscProvider>(context, listen: false)
          .setPageTitle('GROW MY PRAYER LIFE');
      _getDevotionals();
    });
    super.didChangeDependencies();
  }

  _getDevotionals() async {
    await BeStilDialog.showLoading(context, '');
    try {
      await Provider.of<DevotionalProvider>(context, listen: false).getBibles();
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
        height: MediaQuery.of(context).size.height,
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
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Grow My Prayer Life',
                style: TextStyle(
                    color: AppColors.lightBlue3,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      'Prayer is a conversation with God. The primary way God speaks to us is through his written Word, the Bible. The first step in growing your prayer life is to learn God’s voice through reading his Word. Selecting the correct translation of the Bible is important to understanding what God is saying to you.',
                      style: TextStyle(
                        color: AppColors.textFieldText,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 40, right: 20, left: 20),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(RecommenededBibles.routeName);
                          },
                          child: Text(
                            'RECOMMENDED BIBLES',
                            style: TextStyle(
                                color: AppColors.lightBlue4,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(DevotionPlans.routeName);
                          },
                          child: Text(
                            'DEVOTIONAL AND READING PLANS',
                            style: TextStyle(
                                color: AppColors.lightBlue4,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                  //   child: Column(
                  //     children: <Widget>[
                  //       GestureDetector(
                  //         onTap: () {},
                  //         child: Text(
                  //           'MY PRAYER GOALS',
                  //           style: TextStyle(
                  //               color: AppColors.lightBlue4,
                  //               fontSize: 18,
                  //               fontWeight: FontWeight.w500),
                  //           textAlign: TextAlign.left,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
