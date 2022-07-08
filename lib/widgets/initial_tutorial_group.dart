import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialTargetGroup {
  static TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  void showTutorial(
    context,
    _keyButton,
  ) async {
    await analytics.logTutorialBegin();

    targets
        .add(TargetFocus(identify: "groups", keyTarget: _keyButton, contents: [
      TargetContent(
          align: ContentAlign.custom,
          customPosition: CustomTargetContentPosition(
            bottom: 100,
          ),
          child: _buildBody(
            context,
            'GROUPS',
            StringUtils.groupTipList2,
          ))
    ]));

    tutorialCoachMark = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: AppColors.darkBlue,
      textSkip: "SKIP",
      hideSkip: true,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () async {
        print("finish");
        Settings.hasCreatedGroupPrayer = true;
        await analytics.logTutorialComplete();
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onSkip: () {
        print("skip");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
    )..show();
  }

  Widget _buildBody(BuildContext context, String title, String prefix) {
    return GestureDetector(
        onHorizontalDragUpdate: (details) {
          tutorialCoachMark?.finish();
        },
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => tutorialCoachMark?.skip(),
                        icon: Icon(
                          AppIcons.bestill_close,
                          color: AppColors.grey4,
                        ),
                      )
                    ],
                  ),
                  Text(
                    title,
                    style: AppTextStyles.boldText18
                        .copyWith(color: AppColors.lightBlue3),
                  ),
                  Container(
                    padding: EdgeInsets.all(25),
                    child: new RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                        children: <TextSpan>[
                          new TextSpan(
                              text: prefix,
                              style: AppTextStyles.regularText14.copyWith(
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w400))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      child: InkWell(
                          onTap: () {
                            tutorialCoachMark?.finish();
                            Settings.hasCreatedGroupPrayer = true;
                          },
                          child: Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    AppColors.lightBlue2,
                                    AppColors.lightBlue3,
                                  ],
                                ),
                              ),
                              child: Column(children: <Widget>[
                                Text(
                                  'LET\'S GO',
                                  style: AppTextStyles.boldText24
                                      .copyWith(color: Colors.white),
                                  textAlign: TextAlign.center,
                                )
                              ]))))
                ]))));
  }
}
