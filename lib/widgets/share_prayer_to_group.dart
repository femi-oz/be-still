import 'package:be_still/models/user.model.dart';
import 'package:be_still/providers/group_provider.dart';
import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/utils/app_icons.dart';
import 'package:be_still/utils/essentials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SharePrayerToGroups extends StatefulWidget {
  @override
  _SharePrayerToGroupsState createState() => _SharePrayerToGroupsState();
}

class _SharePrayerToGroupsState extends State<SharePrayerToGroups> {
  List selectedGroups = [];

  void _getGroup() async {
    UserModel _user =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    await Provider.of<GroupProvider>(context, listen: false)
        .setAllGroups(_user.id);
  }

  bool _isInit = true;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _getGroup();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final groups = Provider.of<GroupProvider>(context).allGroups;

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          IconButton(
            icon: Icon(
              AppIcons.bestill_close,
            ),
            onPressed: () {
              Navigator.of(context).pop(selectedGroups);
            },
            color: AppColors.textFieldText,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: AppColors.lightBlue5),
                    label: Text(
                      'BACK',
                      style: TextStyle(
                        color: AppColors.lightBlue5,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                ...groups
                    .map((group) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedGroups.add(group.group.id);
                            });
                          },
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedGroups.contains(group.group.id)
                                  ? AppColors.activeButton.withOpacity(0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                color: AppColors.lightBlue6,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    group.group.name,
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
                        ))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
