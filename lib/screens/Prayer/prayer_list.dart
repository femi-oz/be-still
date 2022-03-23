import 'package:be_still/controllers/app_controller.dart';
import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/enums/status.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/v2/prayer.model.dart';
import 'package:be_still/providers/v2/misc_provider.dart';
import 'package:be_still/providers/v2/prayer_provider.dart';
import 'package:be_still/providers/v2/user_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/prayer_card.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/date_format.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:be_still/widgets/initial_tutorial.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PrayerList extends StatefulWidget {
  // final Function setCurrentIndex;
  final GlobalKey keyButton;
  final GlobalKey keyButton2;
  final GlobalKey keyButton3;
  final GlobalKey keyButton4;
  final GlobalKey keyButton5;
  final GlobalKey keyButton6;
  final bool isSearchMode;
  final Function switchSearchMode;
  PrayerList(
    // this.setCurrentIndex,
    this.keyButton,
    this.keyButton2,
    this.keyButton3,
    this.keyButton4,
    this.keyButton5,
    this.keyButton6,
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
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        try {
          var status = Provider.of<PrayerProviderV2>(context, listen: false)
              .filterOption;
          String heading =
              '${status == Status.active ? 'MY PRAYERS' : status.toUpperCase()}';
          await Provider.of<MiscProviderV2>(context, listen: false)
              .setPageTitle(heading);
          final userId = FirebaseAuth.instance.currentUser?.uid;
          await Provider.of<MiscProviderV2>(context, listen: false)
              .setSearchMode(false);
          await Provider.of<MiscProviderV2>(context, listen: false)
              .setSearchQuery('');
          await Provider.of<PrayerProviderV2>(context, listen: false)
              .searchPrayers('', userId ?? '');
          if (Settings.isAppInit)
            TutorialTarget().showTutorial(
              context,
              widget.keyButton,
              widget.keyButton2,
              widget.keyButton3,
              widget.keyButton4,
              widget.keyButton5,
              widget.keyButton6,
            );
          Settings.isAppInit = false;
        } catch (e, s) {
          BeStilDialog.hideLoading(context);
          final user =
              Provider.of<UserProviderV2>(context, listen: false).currentUser;
          BeStilDialog.showErrorDialog(
              context, StringUtils.getErrorMessage(e), user, s);
        }

        setState(() => _isInit = false);
      });
    }
    super.didChangeDependencies();
  }

  Future<void> onTapCard(PrayerDataModel prayerData) async {
    BeStilDialog.showLoading(context, '');
    try {
      Provider.of<PrayerProviderV2>(context, listen: false)
          .setCurrentPrayerId(prayerData.id ?? '');
      await Future.delayed(const Duration(milliseconds: 300),
          () => BeStilDialog.hideLoading(context));
      AppController appController = Get.find();
      appController.setCurrentPage(7, true, 0);
      // Navigator.push(context, SlideRightRoute(page: PrayerDetails()));
    } on HttpException catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      BeStilDialog.hideLoading(context);
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  Future<void> _getPrayers() async {
    try {
      final _user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      final searchQuery =
          Provider.of<MiscProviderV2>(context, listen: false).searchQuery;

      if (searchQuery.isNotEmpty) {
        Provider.of<PrayerProviderV2>(context, listen: false)
            .searchPrayers(searchQuery, _user.id ?? '');
      } else {
        await Provider.of<PrayerProviderV2>(context, listen: false).setPrayers(
            (_user.prayers ?? []).map((e) => e.prayerId ?? '').toList());
      }
    } on HttpException catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    } catch (e, s) {
      final user =
          Provider.of<UserProviderV2>(context, listen: false).currentUser;
      BeStilDialog.showErrorDialog(
          context, StringUtils.getErrorMessage(e), user, s);
    }
  }

  String get message {
    final filterOption = Provider.of<PrayerProviderV2>(context).filterOption;

    if (filterOption.toLowerCase() == Status.active.toLowerCase()) {
      return 'You do not have any active prayers.';
    } else if (filterOption.toLowerCase() == Status.answered.toLowerCase()) {
      return 'You do not have any answered prayers.';
    } else if (filterOption.toLowerCase() == Status.archived.toLowerCase()) {
      return 'You do not have any archived prayers.';
    } else if (filterOption.toLowerCase() == Status.snoozed.toLowerCase()) {
      return 'You do not have any snoozed prayers.';
    } else if (filterOption.toLowerCase() == Status.following.toLowerCase()) {
      return 'You do not have any followed prayers.';
    } else {
      return 'You do not have any prayers.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayers = Provider.of<PrayerProviderV2>(context).filteredPrayers;

    final currentPrayerType =
        Provider.of<PrayerProviderV2>(context).currentPrayerType;
    return WillPopScope(
      onWillPop: () async => false,
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
                          ? Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 100, vertical: 60),
                                    child: Opacity(
                                      opacity: 0.3,
                                      child: Text(
                                        message,
                                        style: AppTextStyles.demiboldText34,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 20.0),
                                    child: LongButton(
                                      onPress: () {
                                        try {
                                          AppController appController =
                                              Get.find();
                                          Provider.of<PrayerProviderV2>(context,
                                                  listen: false)
                                              .setEditMode(false, true);
                                          appController.setCurrentPage(
                                              1, true, 0);
                                        } on HttpException catch (e, s) {
                                          BeStilDialog.hideLoading(context);

                                          final user =
                                              Provider.of<UserProviderV2>(
                                                      context,
                                                      listen: false)
                                                  .currentUser;
                                          BeStilDialog.showErrorDialog(
                                              context,
                                              StringUtils.getErrorMessage(e),
                                              user,
                                              s);
                                        } catch (e, s) {
                                          BeStilDialog.hideLoading(context);
                                          final user =
                                              Provider.of<UserProviderV2>(
                                                      context,
                                                      listen: false)
                                                  .currentUser;
                                          BeStilDialog.showErrorDialog(
                                              context,
                                              StringUtils.getErrorMessage(e),
                                              user,
                                              s);
                                        }
                                      },
                                      text: 'Add New Prayer',
                                      backgroundColor: AppColors
                                          .addPrayerBgColor
                                          .withOpacity(0.9),
                                      textColor: AppColors.addPrayerTextColor,
                                      icon: AppIcons.bestill_add_btn,
                                    ),
                                  ),
                                ],
                              ),
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
                                                  onPress: () {
                                                    try {
                                                      AppController
                                                          appController =
                                                          Get.find();
                                                      Provider.of<PrayerProviderV2>(
                                                              context,
                                                              listen: false)
                                                          .setEditMode(
                                                              false, true);
                                                      appController
                                                          .setCurrentPage(
                                                              1, true, 0);
                                                    } on HttpException catch (e, s) {
                                                      BeStilDialog.hideLoading(
                                                          context);
                                                      final user = Provider.of<
                                                                  UserProviderV2>(
                                                              context,
                                                              listen: false)
                                                          .currentUser;
                                                      BeStilDialog.showErrorDialog(
                                                          context,
                                                          StringUtils
                                                              .getErrorMessage(
                                                                  e),
                                                          user,
                                                          s);
                                                    } catch (e, s) {
                                                      BeStilDialog.hideLoading(
                                                          context);
                                                      final user = Provider.of<
                                                                  UserProviderV2>(
                                                              context,
                                                              listen: false)
                                                          .currentUser;
                                                      BeStilDialog.showErrorDialog(
                                                          context,
                                                          StringUtils
                                                              .getErrorMessage(
                                                                  e),
                                                          user,
                                                          s);
                                                    }
                                                  },
                                                  text: 'Add New Prayer',
                                                  backgroundColor: AppColors
                                                      .addPrayerBgColor
                                                      .withOpacity(0.9),
                                                  textColor: AppColors
                                                      .addPrayerTextColor,
                                                  icon:
                                                      AppIcons.bestill_add_btn,
                                                ),
                                        ],
                                      );
                                    else
                                      return GestureDetector(
                                          onTap: () => onTapCard(prayers[i]),
                                          child: PrayerCard(
                                            prayer: prayers[i],
                                            timeago: DateFormatter(
                                                    (prayers[i]).modifiedDate ??
                                                        DateTime.now())
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
