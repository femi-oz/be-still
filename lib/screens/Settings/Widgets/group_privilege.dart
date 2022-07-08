import 'package:be_still/models/group.model.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';

class GroupPrivilegeSettings extends StatelessWidget {
  final String status;

  final GroupUserModel user;

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
                      color: AppColors.lightBlue4,
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
                    user.userId ?? ''.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.lightBlue4,
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
                      color: AppColors.lightBlue4,
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
                  color: AppColors.red,
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
                      color: AppColors.red,
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
                  color: AppColors.cardBorder,
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
                      color: AppColors.lightBlue4,
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
