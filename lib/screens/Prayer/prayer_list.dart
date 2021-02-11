import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/misc_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
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
import 'widgets/prayer_card.dart';

class PrayerList extends StatefulWidget {
  @override
  _PrayerListState createState() => _PrayerListState();
}

class _PrayerListState extends State<PrayerList> {
  void _getPrayers() async {
    await BeStilDialog.showLoading(context, '');
    try {
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;

      await Provider.of<GroupProvider>(context, listen: false)
          .setUserGroups(_user.id);
      await Provider.of<GroupProvider>(context, listen: false)
          .setAllGroups(_user.id);

      await Provider.of<PrayerProvider>(context, listen: false)
          .setHiddenPrayers(_user.id);
      await Provider.of<PrayerProvider>(context, listen: false)
          .setPrayers(_user?.id);
      Future.delayed(const Duration(milliseconds: 1000), () {
        BeStilDialog.hideLoading(context);
      });
    } on HttpException catch (e) {
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      BeStilDialog.showErrorDialog(context, e.toString());
    }
  }

  _getPermissions() async {
    if (Settings.isAppInit) {
      var status = await Permission.contacts.status;
      if (status.isUndetermined) {
        await Permission.contacts.request();
      }
      Settings.isAppInit = false;
    }
  }

  bool _isInit = true;

  BuildContext selectedContext;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getPermissions();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Provider.of<MiscProvider>(context, listen: false)
            .setPageTitle('MY LIST');
        _getPrayers();
      });
      _isInit = false;
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
                                  onTap: () async {
                                    await Provider.of<PrayerProvider>(context,
                                            listen: false)
                                        .setPrayer(e.prayer.id);
                                    await Provider.of<PrayerProvider>(context,
                                            listen: false)
                                        .setPrayerUpdates(e.prayer.id);
                                    Navigator.of(context)
                                        .pushNamed(PrayerDetails.routeName);
                                    // Navigator.push(
                                    //   context,
                                    //   new MaterialPageRoute(
                                    //     builder: (context) => new PrayerDetails(),
                                    //   ),
                                    // );
                                  },
                                  onLongPressEnd:
                                      (LongPressEndDetails details) async {
                                    await Provider.of<PrayerProvider>(context,
                                            listen: false)
                                        .setPrayer(e.prayer.id);
                                    await Provider.of<PrayerProvider>(context,
                                            listen: false)
                                        .setPrayerUpdates(e.prayer.id);
                                    var y = details.globalPosition.dy;
                                    showModalBottomSheet(
                                      context: context,
                                      barrierColor: AppColors.addPrayerBg
                                          .withOpacity(0.5),
                                      backgroundColor: AppColors.addPrayerBg
                                          .withOpacity(0.9),
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return PrayerQuickAccess(
                                          y: y,
                                          prayer: e.prayer,
                                        );
                                      },
                                    );
                                  },
                                  child: PrayerCard(prayer: e.prayer)))
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