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
import 'package:be_still/utils/app_theme.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:be_still/widgets/app_bar.dart';
import 'package:be_still/widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrayerDetails extends StatefulWidget {
  static const routeName = '/prayer-details';

  @override
  _PrayerDetailsState createState() => _PrayerDetailsState();
}

class _PrayerDetailsState extends State<PrayerDetails> {
  GroupUserModel groupUser;

  bool isGroupAdmin;

  List<PrayerUpdateModel> updates = [];

  Widget _buildMenu(PrayerDetailsRouteArguments args, PrayerModel prayer) {
    if ((args.isGroup && isGroupAdmin) ||
        (!args.isGroup && isGroupAdmin && prayer.groupId != '0')) {
      return GroupAdminPrayerMenu(prayer);
    } else if ((args.isGroup && !isGroupAdmin) ||
        (!args.isGroup && !isGroupAdmin && prayer.groupId != '0')) {
      return OtherMemberPrayerMenu(prayer);
    } else if ((!args.isGroup && prayer.groupId == '0')) {
      return PrayerMenu(prayer, updates);
    } else {
      return PrayerMenu(prayer, updates); //TODO
    }
  }

  void _setData(PrayerModel prayer) async {
    UserModel _user =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    if (prayer.groupId != '0') {
      await Provider.of<GroupProvider>(context, listen: false)
          .getGroupUsers(prayer.groupId)
          .then((users) {
        groupUser = users.where((user) => user.userId == _user.id).toList()[0];
        isGroupAdmin = groupUser.isAdmin;
      });
    } else {
      isGroupAdmin = false;
    }
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   Provider.of<ThemeProvider>(context, listen: false)
  //       .changeTheme(ThemeMode.dark);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final _themeProvider = Provider.of<ThemeProvider>(context);
    final PrayerDetailsRouteArguments args =
        ModalRoute.of(context).settings.arguments;
    PrayerModel prayer;
    return StreamBuilder(
        stream: Provider.of<PrayerProvider>(context).fetchPrayer(args.id),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            prayer = PrayerModel.fromData(snapshot.data);
            _setData(prayer);
            return Scaffold(
              appBar: CustomAppBar(),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.getBackgroudColor(
                        _themeProvider.isDarkModeEnabled),
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
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(PrayerScreen.routeName);
                            },
                            label: Text(
                              'BACK',
                              style: AppTextStyles.boldText20.copyWith(
                                color: AppColors.getAppBarColor(
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
                          //             color: context.toolsBackBtn,
                          //           ),
                          //           Container(
                          //             margin: EdgeInsets.only(left: 10),
                          //             child: Text(
                          //               prayer.reminder,
                          //               style: TextStyle(
                          //                 color: context.toolsBackBtn,
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
                            color: AppColors.darkBlue2,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: StreamBuilder(
                          stream: Provider.of<PrayerProvider>(context)
                              .fetchPrayerUpdate(prayer.id),
                          builder: (context,
                              AsyncSnapshot<List<PrayerUpdateModel>> snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              updates = snapshot.data;
                              return snapshot.data.length > 0
                                  ? UpdateView(prayer, updates)
                                  : NoUpdateView(prayer);
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: context.brightBlue,
                      ),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        barrierColor: context.toolsBg.withOpacity(0.5),
                        backgroundColor: context.toolsBg.withOpacity(0.9),
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return _buildMenu(args, prayer);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              endDrawer: CustomDrawer(),
            );
          } else {
            return Text('No Prayer Available');
          }
        });
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
