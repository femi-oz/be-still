import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialTarget {
  static TutorialCoachMark tutorialCoachMark;
  static void showTutorial(
      context, _keyButton, _keyButton2, _keyButton3, _keyButton4, _keyButton5) {
    List<TargetFocus> targets = [];
    targets.add(TargetFocus(
        identify: "welcome",
        targetPosition: TargetPosition(Size.zero, Offset.zero),
        contents: [
          TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                bottom: 100,
              ),
              child: _buildBody(
                context,
                'Welcome to Be Still!',
                1,
                null,
                "Next Tip",
                StringUtils.quickTipWelcome,
                StringUtils.quickTipWelcome2,
              ))
        ]));
    targets.add(TargetFocus(identify: "list", keyTarget: _keyButton, contents: [
      TargetContent(
          align: ContentAlign.custom,
          customPosition: CustomTargetContentPosition(
            bottom: 100,
          ),
          child: _buildBody(
            context,
            'MY LIST',
            2,
            null,
            " List",
            "Tap",
            StringUtils.quickTipList,
          ))
    ]));
    targets.add(TargetFocus(
        identify: "quick_actions",
        targetPosition: TargetPosition(Size.zero, Offset.zero),
        contents: [
          TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 70,
              ),
              child: _buildBody(
                  context,
                  'PRAYER QUICK ACTIONS',
                  3,
                  "assets/images/quick-access.png",
                  '',
                  StringUtils.quickTipQuickAccess,
                  ''))
        ]));
    targets.add(
        TargetFocus(identify: "filters", keyTarget: _keyButton5, contents: [
      TargetContent(
          align: ContentAlign.custom,
          customPosition: CustomTargetContentPosition(
            top: 70,
          ),
          child: _buildBody(
            context,
            'FILTERS',
            4,
            null,
            " Filters",
            "Use",
            StringUtils.quickTipFilters,
          ))
    ]));
    targets.add(
        TargetFocus(identify: "add_prayer", keyTarget: _keyButton2, contents: [
      TargetContent(
          align: ContentAlign.custom,
          customPosition: CustomTargetContentPosition(
            bottom: 100,
          ),
          child: _buildBody(
            context,
            'ADD A PRAYER',
            5,
            null,
            " Add",
            "Tap",
            StringUtils.quickTipAdd,
          ))
    ]));
    targets.add(
        TargetFocus(identify: "pray_mode", keyTarget: _keyButton3, contents: [
      TargetContent(
          align: ContentAlign.custom,
          customPosition: CustomTargetContentPosition(
            bottom: 100,
          ),
          child: _buildBody(context, 'PRAYER MODE', 6, null, '',
              StringUtils.quickTipPray, ''))
    ]));
    targets
        .add(TargetFocus(identify: "more", keyTarget: _keyButton4, contents: [
      TargetContent(
          align: ContentAlign.custom,
          customPosition: CustomTargetContentPosition(
            bottom: 100,
          ),
          child: _buildBody(context, 'MORE', 7, null, ' More', 'Tap the',
              StringUtils.quickTipMore))
    ]));

    tutorialCoachMark = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: AppColors.darkBlue,
      textSkip: "SKIP",
      hideSkip: true,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        print("finish");
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

  static Widget _buildBody(BuildContext context, String title, int id,
      String image, String boldText, String suffix, String prefix) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        int sensitivity = 8;
        if (details.delta.dx > sensitivity) {
          if (id > 1) tutorialCoachMark.previous();
        } else if (details.delta.dx < -sensitivity) {
          if (id < 7) tutorialCoachMark.next();
        }
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
                    onPressed: () => tutorialCoachMark.skip(),
                    icon: Icon(
                      AppIcons.bestill_close,
                      color: AppColors.grey4,
                    ),
                  )
                ],
              ),
              id == 1
                  ? Column(
                      children: [
                        Container(
                            height: 100,
                            width: 100,
                            child: Image.asset(StringUtils.logo)),
                        SizedBox(height: 10),
                      ],
                    )
                  : Container(),
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
                          text: suffix,
                          style: AppTextStyles.regularText14.copyWith(
                              color: AppColors.darkBlue,
                              fontWeight: FontWeight.w400)),
                      new TextSpan(
                          text: boldText,
                          style: AppTextStyles.regularText14.copyWith(
                              color: AppColors.darkBlue,
                              fontWeight: FontWeight.bold)),
                      new TextSpan(
                          text: prefix,
                          style: AppTextStyles.regularText14.copyWith(
                              color: AppColors.darkBlue,
                              fontWeight: FontWeight.w400))
                    ],
                  ),
                ),
              ),
              image != null ? Image.asset(image) : Container(),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: InkWell(
                  onTap: () => id == 7
                      ? tutorialCoachMark.skip()
                      : tutorialCoachMark.next(),
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
                    child: Column(
                      children: <Widget>[
                        Text(
                          id == 7 ? 'LET\'S GO' : 'NEXT TIP',
                          style: AppTextStyles.boldText24
                              .copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  '$id/7',
                  style: AppTextStyles.regularText12.copyWith(
                      color: AppColors.darkBlue, height: 1, fontSize: 10),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
