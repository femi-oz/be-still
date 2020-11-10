import 'package:be_still/models/http_exception.dart';
import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/models/user.model.dart';
import 'package:be_still/models/user_prayer.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:be_still/utils/app_dialog.dart';
import 'package:be_still/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../../../utils/app_theme.dart';

class GroupAdminPrayerMenu extends StatefulWidget {
  final PrayerModel prayer;

  @override
  GroupAdminPrayerMenu(this.prayer);

  @override
  _GroupAdminPrayerMenuState createState() => _GroupAdminPrayerMenuState();
}

class _GroupAdminPrayerMenuState extends State<GroupAdminPrayerMenu> {
  BuildContext bcontext;

  var _key = GlobalKey<State>();

  void _onHide() async {
    try {
      UserModel _user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      BeStilDialog.showLoading(
        bcontext,
        _key,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .hidePrayer(widget.prayer.id, _user);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(_key);
      Navigator.of(context).pushReplacementNamed(PrayerScreen.routeName);
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(_key);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(_key);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  void _onHideFromGroup() async {
    try {
      BeStilDialog.showLoading(
        bcontext,
        _key,
      );
      await Provider.of<PrayerProvider>(context, listen: false)
          .hidePrayerFromAllMembers(
              widget.prayer.id, !widget.prayer.hideFromAllMembers);
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(_key);
      Navigator.of(context).pushReplacementNamed(PrayerScreen.routeName);
    } on HttpException catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(_key);
      BeStilDialog.showErrorDialog(context, e.message);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 300));
      BeStilDialog.hideLoading(_key);
      BeStilDialog.showErrorDialog(context, StringUtils.errorOccured);
    }
  }

  Widget build(BuildContext context) {
    setState(() => this.bcontext = context);
    UserModel _user =
        Provider.of<UserProvider>(context, listen: false).currentUser;
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
                    UserPrayerModel userPrayer = UserPrayerModel(
                      userId: _user.id,
                      status: 'Active',
                      sequence: null,
                      prayerId: widget.prayer.id,
                      isFavorite: false,
                      createdBy: widget.prayer.createdBy,
                      createdOn: DateTime.now(),
                      modifiedBy: widget.prayer.modifiedBy,
                      modifiedOn: DateTime.now(),
                    );
                    Provider.of<PrayerProvider>(context, listen: false)
                        .addPrayerToMyList(userPrayer);
                    Navigator.of(context)
                        .pushReplacementNamed(PrayerScreen.routeName);
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.toolsBtnBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.add,
                          color: context.brightBlue2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Add to my List',
                            style: TextStyle(
                              color: context.brightBlue2,
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
                        color: context.toolsBtnBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.share,
                          color: context.brightBlue2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Share',
                            style: TextStyle(
                              color: context.brightBlue2,
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
                        color: context.toolsBtnBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          color: context.brightBlue2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Reminder',
                            style: TextStyle(
                              color: context.brightBlue2,
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
                  onTap: _onHide,
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.toolsBtnBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.remove_red_eye,
                          color: context.brightBlue2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Hide',
                            style: TextStyle(
                              color: context.brightBlue2,
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
                  onTap: _onHideFromGroup,
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.toolsBtnBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.remove_red_eye,
                          color: context.brightBlue2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            widget.prayer.hideFromAllMembers
                                ? 'Show in Group'
                                : 'Hide From Group',
                            style: TextStyle(
                              color: context.brightBlue2,
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
                        color: context.toolsBtnBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.message,
                          color: context.brightBlue2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Message Requestor',
                            style: TextStyle(
                              color: context.brightBlue2,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: context.inputFieldText,
          ),
        ],
      ),
    );
  }
}
