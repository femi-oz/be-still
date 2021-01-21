import 'package:be_still/screens/grow_my_prayer_life/devotion_and_reading_plans.dart';
import 'package:be_still/screens/grow_my_prayer_life/recommended_bibles_screen.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class GrowMyPrayerLifeScreen extends StatelessWidget {
  static const routeName = 'grow-prayer';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
          image: DecorationImage(
            image: AssetImage(Settings.isDarkMode
                ? 'assets/images/background-pattern-dark.png'
                : 'assets/images/background-pattern.png'),
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
                      'Curabitur non nulla sit amet nisl tempus convallis quis ac lectus. Donec sollicitudin molestie malesuada. Proin eget tortor risus. Vestibulum ante ipsum primis in faucibus',
                      style: TextStyle(
                        color: AppColors.textFieldText,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      'Quisque velit nisi, pretium ut lacinia in, elementum id enim. Mauris blandit aliquet elit, eget tincidunt nibh pulvinar a. Sed porttitor lectus nibh. Quisque velit nisi, pretium ut lacinia in, elementum id enim. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;',
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
                  Container(
                    margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'MY PRAYER GOALS',
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
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
