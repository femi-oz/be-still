import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialTarget {
  static List<TargetFocus> targets = [];
  static TutorialCoachMark tutorialCoachMark;
  static void showTutorial({context}) {
    final miscProvider = Provider.of<MiscProvider>(context, listen: false);
    targets.add(TargetFocus(
        identify: "more",
        keyTarget: miscProvider.keyButton4,
        contents: [
          TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 0,
                bottom: 0,
              ),
              child: _buildBody(
                  context,
                  'Help',
                  'Tap the buttons at the bottom of each screen to create prayers, show your prayer list, and start prayer time.\n\nTap the More menu and then tap Help to reach the online user\'s guide for Be Still',
                  0))
        ]));
    targets.add(TargetFocus(
        identify: "add",
        keyTarget: miscProvider.keyButton2,
        contents: [
          TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 0,
                bottom: 0,
              ),
              child: _buildBody(
                  context,
                  'Add Prayer',
                  'Tap Add to create a new prayer and add it to your prayer list.\n\nYou can enter a description of your prayer that names the people or things you wish to pray for.',
                  1))
        ]));
    targets.add(TargetFocus(
        identify: "list",
        keyTarget: miscProvider.keyButton,
        contents: [
          TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 0,
                bottom: 0,
              ),
              child: _buildBody(
                  context,
                  'My Prayer List',
                  'Tap List at any time to view all the prayers in your current prayer list.\n\nYou can search your prayers for specific words or names, and you can filter your list to display only prayers of a certain type.',
                  2))
        ]));
    targets.add(TargetFocus(
        identify: "pray",
        keyTarget: miscProvider.keyButton3,
        contents: [
          TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                top: 0,
                bottom: 0,
              ),
              child: _buildBody(
                  context,
                  'Prayer Time',
                  'Tap Prayer Time to begin your own prayer time.\n\nDuring prayer time, all your active prayers will be displayed as a sequence of prayer cards that will help you remember the people and things you wish to pray for.',
                  3))
        ]));
    targets.add(TargetFocus(
        identify: "options",
        keyTarget: miscProvider.keyButton5,
        contents: [
          TargetContent(
              align: ContentAlign.custom,
              customPosition: CustomTargetContentPosition(
                // top: 0,
                bottom: 0,
              ),
              child: _buildBody(
                  context,
                  'Prayer Actions',
                  'Your prayer list contains prayers that can be swiped left or right to display common actions, such as marking a prayer as answered, archiving it, or snoozing it so it is temporarily does not appear in your prayer time.\n\nThat\'s it!  If you ever need assistance, remember to tap the More button and then Help.',
                  4))
        ]));

    tutorialCoachMark = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: AppColors.backgroundColor[0],
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

  static Widget _buildBody(
      BuildContext context, String title, String content, int id) {
    return Container(
        padding:
            EdgeInsets.symmetric(vertical: id < 4 ? 100 : 0, horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.boldText20
                          .copyWith(color: AppColors.prayerTextColor),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Text(content,
                    style: AppTextStyles.boldText16
                        .copyWith(color: AppColors.prayerTextColor)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                id > 0
                    ? TextButton(
                        child: Text('Prev',
                            style: AppTextStyles.boldText16
                                .copyWith(color: AppColors.prayerTextColor)),
                        onPressed: () => tutorialCoachMark.previous(),
                      )
                    : TextButton(
                        onPressed: () => tutorialCoachMark.show(),
                        child: Text('Skip',
                            style: AppTextStyles.boldText16
                                .copyWith(color: AppColors.prayerTextColor))),
                id < 4
                    ? TextButton(
                        child: Text('Next',
                            style: AppTextStyles.boldText16
                                .copyWith(color: AppColors.prayerTextColor)),
                        onPressed: () => tutorialCoachMark.next(),
                      )
                    : TextButton(
                        onPressed: () => tutorialCoachMark.skip(),
                        child: Text(
                          'End',
                          style: AppTextStyles.boldText16
                              .copyWith(color: AppColors.prayerTextColor),
                        ),
                      )
              ],
            ),
          ],
        ));
  }
}
