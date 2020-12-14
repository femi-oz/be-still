import 'package:be_still/enums/prayer_list.enum.dart';
import 'package:be_still/models/group.model.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/theme_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/screens/prayer_details/widgets/group_admin_prayer_menu.dart';
import 'package:be_still/screens/prayer_details/widgets/no_update_view.dart';
import 'package:be_still/screens/prayer_details/widgets/other_member_prayer_menu.dart';
import 'package:be_still/screens/prayer_details/widgets/prayer_menu.dart';
import 'package:be_still/screens/prayer_details/widgets/update_view.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrayerDetails extends StatefulWidget {
  static const routeName = 'prayer-details';

  @override
  _PrayerDetailsState createState() => _PrayerDetailsState();
}

class _PrayerDetailsState extends State<PrayerDetails> {
  // GroupUserModel groupUser;

  List<PrayerUpdateModel> updates = [];

  Widget _buildMenu() {
    UserModel _user =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    PrayerModel prayer = Provider.of<PrayerProvider>(context).currentPrayer;
    var group = Provider.of<GroupProvider>(context, listen: false).currentGroup;
    var isGroupAdmin = false;
    if (group != null) {
      isGroupAdmin = group.groupUsers
              .firstWhere((user) => user.userId == _user.id, orElse: () => null)
              ?.isAdmin ??
          false;
    }
    var isGroup = Provider.of<PrayerProvider>(context).currentPrayerType !=
        PrayerType.userPrayers;
    if ((isGroup && isGroupAdmin) ||
        (!isGroup && isGroupAdmin && prayer.groupId != '0')) {
      return GroupAdminPrayerMenu(prayer);
    } else if ((isGroup && !isGroupAdmin) ||
        (!isGroup && !isGroupAdmin && prayer.groupId != '0')) {
      return OtherMemberPrayerMenu(prayer);
    } else if ((!isGroup && prayer.groupId == '0')) {
      return PrayerMenu(prayer, updates, context);
    } else {
      return PrayerMenu(prayer, updates, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    return
        // Scaffold(
        //   appBar: CustomAppBar(),
        //   body:
        Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.getBackgroudColor(_themeProvider.isDarkModeEnabled),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton.icon(
                  padding: EdgeInsets.all(0),
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.lightBlue4,
                  ),
                  onPressed: () => Navigator.pop(context),
                  label: Text(
                    'BACK',
                    style: AppTextStyles.boldText20.copyWith(
                      color: AppColors.getPrayerPrimaryColor(
                          _themeProvider.isDarkModeEnabled),
                    ),
                  ),
                ),
                // prayer.hasReminder
                //     ? Row(
                //         children: <Widget>[
                //           Icon(
                //             Icons.calendar_today,
                //             size: 14,
                //             color: AppColors.lightBlue5,
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(left: 10),
                //             child: Text(
                //               prayer.reminder,
                //               style: TextStyle(
                //                 color: AppColors.lightBlue5,
                //               ),
                //             ),
                //           ),
                //         ],
                //       )
                //     : Container(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.getDetailBgColor(
                      _themeProvider.isDarkModeEnabled),
                ),
                border: Border.all(
                  color: AppColors.getPrayerPrimaryColor(
                      _themeProvider.isDarkModeEnabled),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child:
                  Provider.of<PrayerProvider>(context).prayerUpdates.length > 0
                      ? UpdateView()
                      : NoUpdateView(),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: AppColors.lightBlue3,
            ),
            onPressed: () => showModalBottomSheet(
              context: context,
              barrierColor: AppColors.getDetailBgColor(
                      _themeProvider.isDarkModeEnabled)[1]
                  .withOpacity(0.5),
              backgroundColor: AppColors.getDetailBgColor(
                      _themeProvider.isDarkModeEnabled)[1]
                  .withOpacity(0.9),
              isScrollControlled: true,
              builder: (BuildContext context) {
                return _buildMenu();
              },
            ),
          ),
        ],
        // ),
      ),
      // endDrawer: CustomDrawer(),
    );
  }
}

class PrayerDetailsRouteArguments {
  final String id;
  final bool isGroup;

  PrayerDetailsRouteArguments({
    this.id,
    this.isGroup,
  });
}
