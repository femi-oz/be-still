import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/notification_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/settings_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/screens/prayer/widgets/prayer_quick_acccess.dart';
import 'package:be_still/screens/prayer_details/prayer_details_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/utils/settings.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:be_still/widgets/custom_long_button.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vibrate/vibrate.dart';
import 'widgets/prayer_card.dart';
import 'package:flutter/services.dart';

class PrayerList extends StatefulWidget {
  @override
  _PrayerListState createState() => _PrayerListState();
}

class _PrayerListState extends State<PrayerList> {
  bool _isInit = true;
  bool _canVibrate = true;

  void _getPrayers() async {
    await BeStilDialog.showLoading(context);
    try {
      final _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      await _preLoadData();
      final options =
          Provider.of<PrayerProvider>(context, listen: false).filterOptions;
      final settings =
          Provider.of<SettingsProvider>(context, listen: false).settings;
      await Provider.of<PrayerProvider>(context, listen: false).setPrayers(
          _user?.id,
          options.isArchived ? settings.archiveSortBy : settings.defaultSortBy);
      await Future.delayed(Duration(milliseconds: 100));
      BeStilDialog.hideLoading(context);
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 100));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 100));
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  Future<void> _preLoadData() async {
    UserModel _user =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    //load settings
    await Provider.of<SettingsProvider>(context, listen: false)
        .setPrayerSettings(_user.id);
    await Provider.of<SettingsProvider>(context, listen: false)
        .setSettings(_user.id);
    await Provider.of<SettingsProvider>(context, listen: false)
        .setSharingSettings(_user.id);

    //get all users
    await Provider.of<UserProvider>(context, listen: false)
        .setAllUsers(_user.id);

    // get all local notifications
    await Provider.of<NotificationProvider>(context, listen: false)
        .setLocalNotifications(_user.id);
  }

  void onTapCard(prayerData) async {
    await BeStilDialog.showLoading(context, '');
    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayer(prayerData.userPrayer.id);
      await Future.delayed(const Duration(milliseconds: 300),
          () => BeStilDialog.hideLoading(context));
      Navigator.of(context).pushNamed(PrayerDetails.routeName);
    } on HttpException catch (e) {
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.hideLoading(context);
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  void _setVibration() async => _canVibrate = await Vibrate.canVibrate;

  void _vibrate() async {
    // HapticFeedback.selectionClick();

    if (_canVibrate) Vibrate.vibrate();
  }

  void onLongPressCard(prayerData, details) async {
    _vibrate();
    try {
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayer(prayerData.userPrayer.id);
      var y = details.globalPosition.dy;
      await Future.delayed(
        const Duration(milliseconds: 300),
        () => showModalBottomSheet(
          context: context,
          barrierColor: AppColors.addPrayerBg.withOpacity(0.5),
          backgroundColor: AppColors.addPrayerBg.withOpacity(0.9),
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
    if (Settings.isAppInit) {
      final status = await Permission.contacts.status;
      if (status.isUndetermined) {
        await Permission.contacts.request().then((p) =>
            Settings.enabledContactPermission = p == PermissionStatus.granted);
      }
      Settings.isAppInit = false;
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _setVibration();
      _getPermissions();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _getPrayers();
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle('MY LIST');
      });
      setState(() => _isInit = false);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var prayers = Provider.of<PrayerProvider>(context).filteredPrayers;
    final currentPrayerType =
        Provider.of<PrayerProvider>(context).currentPrayerType;
    return WillPopScope(
      onWillPop: () => null,
      child: Container(
        padding: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundColor,
          ),
          image: DecorationImage(
            image: AssetImage(StringUtils.backgroundImage(true)),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
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
                      ))
                  : Container(
                      child: Column(
                        children: <Widget>[
                          ...prayers
                              .map((e) => GestureDetector(
                                  onTap: () => onTapCard(e),
                                  onLongPressEnd:
                                      (LongPressEndDetails details) =>
                                          onLongPressCard(e, details),
                                  child: PrayerCard(
                                    prayerData: e,
                                  )))
                              .toList(),
                        ],
                      ),
                    ),
              SizedBox(height: 5),
              currentPrayerType == PrayerType.archived ||
                      currentPrayerType == PrayerType.answered
                  ? Container()
                  : LongButton(
                      onPress: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntryScreen(screenNumber: 2),
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
    );
  }
}
