import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/Prayer/Widgets/prayer_card.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/prayer/widgets/prayer_quick_acccess.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/date_format.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
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
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle('MY PRAYERS');
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
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayers(_user?.id);

      BeStilDialog.hideLoading(context);
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  Future<void> onTapCard(prayerData) async {
    await BeStilDialog.showLoading(context, '');
    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayer(prayerData.userPrayer.id);
      await Future.delayed(const Duration(milliseconds: 300),
          () => BeStilDialog.hideLoading(context));
      Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRightWithFade,
            child: PrayerDetails()),
      );
      // Navigator.of(context).pushNamed(PrayerDetails.routeName);
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.toString());
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
    } on HttpException catch (e) {
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  void _getPermissions() async {
    try {
      if (Settings.isAppInit) {
        final status = await Permission.contacts.status;
        if (status.isUndetermined) {
          await Permission.contacts.request().then((p) => Settings
              .enabledContactPermission = p == PermissionStatus.granted);
        }
        Settings.isAppInit = false;
      }
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(StringUtils.backgroundImage(true)),
                alignment: Alignment.bottomCenter,
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
                                    prayerData: e, timeago: _timeago));
                          }).toList(),
                        ],
                      ),
                SizedBox(height: 5),
                currentPrayerType == PrayerType.archived ||
                        currentPrayerType == PrayerType.answered
                    ? Container()
                    : LongButton(
                        onPress: () => Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.leftToRightWithFade,
                            child: EntryScreen(
                              screenNumber: 2,
                            ),
                          ),
                        ),
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
    );
  }
}
