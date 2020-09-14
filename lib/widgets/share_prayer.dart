import 'package:be_still/data/group.data.dart';

import 'package:be_still/providers/user_provider.dart';
import 'package:be_still/widgets/share_prayer_to_group.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

class SharePrayer extends StatelessWidget {
  // PrayerModel prayer;
  _emailLink() async {
    const url = 'mailto:?subject=prayer subject&body=prayer body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _textLink() async {
    const url = 'sms:';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final _userProvider = Provider.of<UserProvider>(context);
    final groupsCount = groupData
        .where((gl) => gl.members.contains(_userProvider.user.id))
        .length;
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
                GestureDetector(
                  onTap: _textLink,
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
                            'Text Message',
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
                  onTap: _emailLink,
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
                            'Email',
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
                            'Direct Message',
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
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      barrierColor: context.toolsBg.withOpacity(0.5),
                      backgroundColor: context.toolsBg.withOpacity(0.9),
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return SharePrayerToGroups();
                      },
                    );
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
                          Icons.share,
                          color: context.brightBlue2,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Post to Group(s)',
                                  style: TextStyle(
                                    color: context.brightBlue2,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text('$groupsCount / $groupsCount')
                              ],
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
                            'To my Church',
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
