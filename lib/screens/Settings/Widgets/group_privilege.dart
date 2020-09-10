import 'package:be_still/Models/user.model.dart';
import 'package:flutter/material.dart';
import '../../../widgets/Theme/app_theme.dart';

class GroupPrivilegeSettings extends StatelessWidget {
  final String status;

  final UserModel user;

  @override
  GroupPrivilegeSettings(this.status, this.user);
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 40.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 100),
                  child: Text(
                    'Confirm transfer of Admin Privilege to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.brightBlue2,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 100.0, vertical: 20.0),
                  child: Text(
                    user.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.brightBlue2,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 100),
                  child: Text(
                    'Your account will be updated to Moderator',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.brightBlue2,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              height: 30,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.prayerCardTags,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'CONFIRM',
                    style: TextStyle(
                      color: context.prayerCardTags,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              height: 30,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.inputFieldBorder,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'CANCEL',
                    style: TextStyle(
                      color: context.brightBlue2,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
