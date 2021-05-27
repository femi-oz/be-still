import 'dart:ui';
import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/prayer_card.dart';
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
import 'package:flutter/cupertino.dart';
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
  final bool isSearchMode;
  final Function switchSearchMode;
  PrayerList(
    this.setCurrentIndex,
    this.keyButton,
    this.keyButton2,
    this.keyButton3,
    this.keyButton4,
    this.keyButton5,
    this.isSearchMode,
    this.switchSearchMode,
  );
  @override
  _PrayerListState createState() => _PrayerListState();
}

class _PrayerListState extends State<PrayerList> {
  bool _isInit = true;
  final refreshKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void didChangeDependencies() {
    if (_isInit) {
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
        Settings.isAppInit = false;
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

  Future<void> _getPrayers() async {
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      final searchQuery =
          Provider.of<MiscProvider>(context, listen: false).searchQuery;
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayerTimePrayers(_user.id);
      if (searchQuery.isNotEmpty) {
        Provider.of<PrayerProvider>(context, listen: false)
            .searchPrayers(searchQuery, _user.id);
      } else {
        await Provider.of<PrayerProvider>(context, listen: false)
            .setPrayers(_user?.id);
      }
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

  @override
  Widget build(BuildContext context) {
    final userId =
        Provider.of<UserProvider>(context, listen: false).currentUser.id;
    Provider.of<PrayerProvider>(context, listen: false)
        .checkPrayerValidity(userId);
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
            isSearchMode: widget.isSearchMode,
            switchSearchMode: (bool val) => widget.switchSearchMode(val),
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.backgroundColor[0].withOpacity(0.9),
                        AppColors.backgroundColor[1].withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      prayers.length == 0
                          ? Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 60,
                                      right: 100,
                                      top: 60,
                                      bottom: 60),
                                  child: Opacity(
                                    opacity: 0.3,
                                    child: Text(
                                      'No Prayers in My List',
                                      style: AppTextStyles.demiboldText34,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: LongButton(
                                    onPress: () =>
                                        widget.setCurrentIndex(1, true),
                                    text: 'Add New Prayer',
                                    backgroundColor: AppColors.addprayerBgColor
                                        .withOpacity(0.9),
                                    textColor: AppColors.addprayerTextColor,
                                    icon: AppIcons.bestill_add_btn,
                                  ),
                                ),
                              ],
                            )
                          : Expanded(
                              child: RefreshIndicator(
                                key: refreshKey,
                                onRefresh: () => _getPrayers(),
                                child: ListView.builder(
                                  key: new PageStorageKey('prayerList'),
                                  padding: EdgeInsets.only(
                                      top: 20.0, bottom: 100.0, left: 20.0),
                                  itemCount: prayers.length + 1,
                                  itemBuilder: (context, i) {
                                    if (i == prayers.length)
                                      return Column(
                                        children: [
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
