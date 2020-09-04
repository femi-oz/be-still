import 'package:be_still/src/Data/group.data.dart';
import 'package:be_still/src/Providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Theme/app_theme.dart';

class SharePrayerToGroups extends StatefulWidget {
  @override
  _SharePrayerToGroupsState createState() => _SharePrayerToGroupsState();
}

class _SharePrayerToGroupsState extends State<SharePrayerToGroups> {
  String selectedGroup;
  @override
  Widget build(BuildContext context) {
    final _app = Provider.of<AppProvider>(context);

    final groups = groupData.where((gl) => gl.members.contains(_app.user.id));
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: FlatButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: context.toolsBackBtn),
                    label: Text(
                      'BACK',
                      style: TextStyle(
                        color: context.toolsBackBtn,
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
                              selectedGroup = group.id;
                            });
                          },
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedGroup == group.id
                                  ? context.toolsActiveBtn.withOpacity(0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                color: context.toolsBtnBorder,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    group.name,
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
                        ))
                    .toList(),
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
