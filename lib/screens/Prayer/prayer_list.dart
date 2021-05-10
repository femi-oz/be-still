import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/prayer_card.dart';
import 'package:be_still/screens/prayer/widgets/prayer_quick_acccess.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/date_format.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/navigation.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:be_still/widgets/initial_tutorial.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vibrate/vibrate.dart';

class PrayerList extends StatefulWidget {
  @override
  _PrayerListState createState() => _PrayerListState();
}

class _PrayerListState extends State<PrayerList> {
  bool _isInit = true;
  bool _canVibrate = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _setVibration();
      _getPermissions();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _getPrayers();
        var status =
            Provider.of<PrayerProvider>(context, listen: false).filterOption;
        String heading =
            '${status == Status.active ? 'MY PRAYERS' : status.toUpperCase()}';
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle(heading);
      });
      setState(() => _isInit = false);
    }
    super.didChangeDependencies();
  }

  Future<void> _getPrayers() async {
    await BeStilDialog.showLoading(context);
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      final searchQuery =
          Provider.of<MiscProvider>(context, listen: false).searchQuery;
      if (searchQuery.isNotEmpty) {
        Provider.of<PrayerProvider>(context, listen: false)
            .searchPrayers(searchQuery, _user.id);
      } else {
        await Provider.of<PrayerProvider>(context, listen: false)
            .setPrayers(_user?.id);
      }

      BeStilDialog.hideLoading(context);
      showModalBottomSheet(
          backgroundColor: AppColors.backgroundColor[0].withOpacity(0.5),
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 100, horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Welcome',
                      style: AppTextStyles.boldText20
                          .copyWith(color: AppColors.prayerTextColor)),
                  Text(
                      'Welcome to Be Still!  Here\'s aquick tour that will get you started.\n\nThe Be Still app can organize all your prayers and lead you through your own personal prayer time.\n\nTap Next to begin the tour, or Skip Tour to begin using Be Still right away',
                      style: AppTextStyles.boldText16
                          .copyWith(color: AppColors.prayerTextColor)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            final miscProvider = Provider.of<MiscProvider>(
                                context,
                                listen: false);
                            TutorialTarget.showTutorial(
                              context: context,
                              keyButton2: miscProvider.keyButton2,
                              keyButton3: miscProvider.keyButton3,
                              keyButton: miscProvider.keyButton,
                              keyButton4: miscProvider.keyButton4,
                              keyButton5: miscProvider.keyButton5,
                            );
                          },
                          child: Text('Next',
                              style: AppTextStyles.boldText16
                                  .copyWith(color: AppColors.prayerTextColor))),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Skip',
                              style: AppTextStyles.boldText16
                                  .copyWith(color: AppColors.prayerTextColor))),
                    ],
                  )
                ],
              ),
            );
          });
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  Future<void> onTapCard(prayerData) async {
    await BeStilDialog.showLoading(context, '');
    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayer(prayerData.userPrayer.id);
      await Future.delayed(const Duration(milliseconds: 300),
          () => BeStilDialog.hideLoading(context));
      Navigator.push(context, SlideRightRoute(page: PrayerDetails()));
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  Future<void> _setVibration() async => _canVibrate = await Vibrate.canVibrate;

  void _vibrate() => _canVibrate ? Vibrate.feedback(FeedbackType.medium) : null;

  Future<void> onLongPressCard(prayerData, details) async {
    _vibrate();
    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayer(prayerData.userPrayer.id);
      final y = details.globalPosition.dy;
      await Future.delayed(
        const Duration(milliseconds: 300),
        () => showModalBottomSheet(
          context: context,
          barrierColor: AppColors.addPrayerBg.withOpacity(0.5),
          backgroundColor: AppColors.addPrayerBg.withOpacity(0.5),
          isScrollControlled: true,
          builder: (BuildContext context) {
            return PrayerQuickAccess(
              y: y,
              prayerData: prayerData,
            );
          },
        ),
      );
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  void _getPermissions() async {
    try {
      if (Settings.isAppInit) {
        await Permission.contacts.request().then((p) =>
            Settings.enabledContactPermission = p == PermissionStatus.granted);
        Settings.isAppInit = false;
      }
    } catch (e, s) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(context, e, user, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayers = Provider.of<PrayerProvider>(context).filteredPrayers;
    final currentPrayerType =
        Provider.of<PrayerProvider>(context).currentPrayerType;
    return WillPopScope(
      onWillPop: () => null,
      child: Container(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(StringUtils.backgroundImage),
                  alignment: Alignment.bottomCenter,
                ),
              ),
              child: Container(
                padding: EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundColor[0].withOpacity(0.85),
                      AppColors.backgroundColor[1].withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    prayers.length == 0
                        ? Container(
                            padding: EdgeInsets.only(
                                left: 60, right: 100, top: 60, bottom: 60),
                            child: Opacity(
                              opacity: 0.3,
                              child: Text(
                                'No Prayers in My List',
                                style: AppTextStyles.demiboldText34,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Column(
                            children: <Widget>[
                              ...prayers.map((e) {
                                final _timeago =
                                    DateFormatter(e.prayer.modifiedOn).format();
                                return GestureDetector(
                                  onTap: () => onTapCard(e),
                                  child: PrayerCard(
                                    prayerData: e,
                                    timeago: _timeago,
                                    keyButton: prayers.indexOf(e) == 0
                                        ? Provider.of<MiscProvider>(context,
                                                listen: false)
                                            .keyButton5
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                    SizedBox(height: 5),
                    currentPrayerType == PrayerType.archived ||
                            currentPrayerType == PrayerType.answered
                        ? Container()
                        : LongButton(
                            onPress: () => Provider.of<MiscProvider>(context,
                                    listen: false)
                                .setCurrentPage(2),
                            text: 'Add New Prayer',
                            backgroundColor:
                                AppColors.addprayerBgColor.withOpacity(0.9),
                            textColor: AppColors.addprayerTextColor,
                            icon: AppIcons.bestill_add_btn,
                          ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
