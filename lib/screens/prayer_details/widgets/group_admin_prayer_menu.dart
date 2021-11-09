import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/prayer_provider.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/entry_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class GroupAdminPrayerMenu extends StatefulWidget {
  final PrayerModel prayer;

  @override
  GroupAdminPrayerMenu(this.prayer);

  @override
  _GroupAdminPrayerMenuState createState() => _GroupAdminPrayerMenuState();
}

class _GroupAdminPrayerMenuState extends State<GroupAdminPrayerMenu> {
  BuildContext bcontext;

  void _onHide() async {
    try {
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showLoading(
        bcontext,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .hidePrayer(widget.prayer.id, _user);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } on HttpException catch (_) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    }
  }

  void _onHideFromGroup() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
      );
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } on HttpException catch (_) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(context);
    }
  }

  Widget build(BuildContext context) {
    setState(() => this.bcontext = context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(EntryScreen.routeName);
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          AppIcons.bestill_add,
                          color: AppColors.lightBlue4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Add to my List',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          AppIcons.bestill_share,
                          color: AppColors.lightBlue4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Share',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightBlue6,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          AppIcons.bestill_reminder,
                          color: AppColors.lightBlue4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Reminder',
                            style: TextStyle(
                              color: AppColors.lightBlue4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // GestureDetector(
                //   onTap: _onHide,
                //   child: Container(
                //     height: 50,
                //     padding: EdgeInsets.symmetric(horizontal: 20),
                //     width: double.infinity,
                //     margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                //     decoration: BoxDecoration(
                //       border: Border.all(
                //         color: AppColors.lightBlue6,
                //         width: 1,
                //       ),
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: Row(
                //       children: <Widget>[
                //         Icon(
                //           AppIcons.bestill_hide,
                //           color: AppColors.lightBlue4,
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 10.0),
                //           child: Text(
                //             'Hide',
                //             style: TextStyle(
                //               color: AppColors.lightBlue4,
                //               fontSize: 14,
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // GestureDetector(
                //   onTap: _onHideFromGroup,
                //   child: Container(
                //     height: 50,
                //     padding: EdgeInsets.symmetric(horizontal: 20),
                //     width: double.infinity,
                //     margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                //     decoration: BoxDecoration(
                //       border: Border.all(
                //         color: AppColors.lightBlue6,
                //         width: 1,
                //       ),
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: Row(
                //       children: <Widget>[
                //         Icon(
                //           AppIcons.bestill_hide,
                //           color: AppColors.lightBlue4,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // GestureDetector(
                //   onTap: () {},
                //   child: Container(
                //     height: 50,
                //     padding: EdgeInsets.symmetric(horizontal: 20),
                //     width: double.infinity,
                //     margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                //     decoration: BoxDecoration(
                //       border: Border.all(
                //         color: AppColors.lightBlue6,
                //         width: 1,
                //       ),
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: Row(
                //       children: <Widget>[
                //         Icon(
                //           AppIcons.bestill_message,
                //           color: AppColors.lightBlue4,
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(left: 10.0),
                //           child: Text(
                //             'Message Requestor',
                //             style: TextStyle(
                //               color: AppColors.lightBlue4,
                //               fontSize: 14,
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              AppIcons.bestill_close,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: AppColors.textFieldText,
          ),
        ],
      ),
    );
  }
}
