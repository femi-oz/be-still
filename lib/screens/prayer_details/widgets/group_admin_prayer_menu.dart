import 'package:be_still/models/prayer.model.dart';
import 'package:be_still/providers/prayer_provider.dart';
import 'package:be_still/screens/prayer/prayer_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../../../utils/app_theme.dart';

class GroupAdminPrayerMenu extends StatelessWidget {
  final PrayerModel prayer;

  @override
  GroupAdminPrayerMenu(this.prayer);
  Widget build(BuildContext context) {
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
                  onTap: () async {
                    await Provider.of<PrayerProvider>(context, listen: false)
                        .hidePrayer(prayer.id, !prayer.hideFromMe);
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
                          Icons.remove_red_eye,
                          color: context.brightBlue2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            prayer.hideFromMe ? 'Show' : 'Hide',
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
                  onTap: () async {
                    await Provider.of<PrayerProvider>(context, listen: false)
                        .hidePrayerFromAllMembers(
                            prayer.id, !prayer.hideFromAllMembers);
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
                          Icons.remove_red_eye,
                          color: context.brightBlue2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            prayer.hideFromAllMembers
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
