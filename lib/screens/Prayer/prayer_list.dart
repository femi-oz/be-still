import 'dart:ui';
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
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:be_still/widgets/initial_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibrate/vibrate.dart';

class PrayerList extends StatefulWidget {
  final Function setCurrentIndex;
  final GlobalKey keyButton;
  final GlobalKey keyButton2;
  final GlobalKey keyButton3;
  final GlobalKey keyButton4;
  final GlobalKey keyButton5;
  PrayerList(
    this.setCurrentIndex,
    this.keyButton,
    this.keyButton2,
    this.keyButton3,
    this.keyButton4,
    this.keyButton5,
  );
  @override
  _PrayerListState createState() => _PrayerListState();
}

class _PrayerListState extends State<PrayerList> {
  bool _isInit = true;
  bool _canVibrate = true;
  final refreshKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _setVibration();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        var status =
            Provider.of<PrayerProvider>(context, listen: false).filterOption;
        String heading =
            '${status == Status.active ? 'MY PRAYERS' : status.toUpperCase()}';
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle(heading);
        if (Settings.isAppInit)
          TutorialTarget.showTutorial(
            context,
            widget.keyButton,
            widget.keyButton2,
            widget.keyButton3,
            widget.keyButton4,
            widget.keyButton5,
          );
        setState(() => _isInit = false);
      });
    }
    super.didChangeDependencies();
  }

  Future<void> onTapCard(prayerData) async {
    BeStilDialog.showLoading(context, '');
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

  bool _isSearchMode = false;
  void _switchSearchMode(bool value) => _isSearchMode = value;

  Future<void> refresh() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final prayers = Provider.of<PrayerProvider>(context).filteredPrayers;
    final currentPrayerType =
        Provider.of<PrayerProvider>(context).currentPrayerType;
    return WillPopScope(
      onWillPop: () => null,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Scaffold(
          appBar: CustomAppBar(
            showPrayerActions: true,
            isSearchMode: _isSearchMode,
            switchSearchMode: (bool val) => _switchSearchMode(val),
            globalKey: widget.keyButton5,
          ),
          body: Container(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(StringUtils.backgroundImage),
                    alignment: Alignment.bottomCenter,
                    fit: BoxFit.cover,
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
                    mainAxisSize: MainAxisSize.min,
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
                          : Expanded(
                              child: RefreshIndicator(
                                key: refreshKey,
                                onRefresh: () => refresh(),
                                child: ListView.builder(
                                  itemCount: prayers.length + 1,
                                  itemBuilder: (context, i) {
                                    if (i == prayers.length)
                                      return Column(
                                        children: [
                                          SizedBox(height: 5),
                                          currentPrayerType ==
                                                      PrayerType.archived ||
                                                  currentPrayerType ==
                                                      PrayerType.answered
                                              ? Container()
                                              : LongButton(
                                                  onPress: () => widget
                                                      .setCurrentIndex(1, true),
                                                  text: 'Add New Prayer',
                                                  backgroundColor: AppColors
                                                      .addprayerBgColor
                                                      .withOpacity(0.9),
                                                  textColor: AppColors
                                                      .addprayerTextColor,
                                                  icon:
                                                      AppIcons.bestill_add_btn,
                                                ),
                                          SizedBox(height: 80),
                                        ],
                                      );
                                    else
                                      return GestureDetector(
                                          onTap: () => onTapCard(prayers[i]),
                                          child: PrayerCard(
                                            prayerData: prayers[i],
                                            timeago: DateFormatter(prayers[i]
                                                    .prayer
                                                    .modifiedOn)
                                                .format(),
                                          ));
                                  },
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
